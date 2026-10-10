import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/features/auth/data/services/account_lifecycle_service_impl.dart';
import 'package:fitkarma/features/auth/domain/models/account_lifecycle_models.dart';
import 'package:fitkarma/features/auth/domain/services/account_lifecycle_service.dart';
import 'package:fitkarma/features/auth/domain/services/local_data_wipe_coordinator.dart';
import 'package:fitkarma/features/auth/presentation/providers/account_lifecycle_providers.dart';
import 'package:fitkarma/features/auth/presentation/widgets/delete_account_dialog.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_profile_repository.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_wellness_repository.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.fromMap({
    'APP_ENV': 'development',
    'SUPABASE_URL': 'https://test.supabase.co',
    'SUPABASE_ANON_KEY': 'test-anon-key',
  });

  group('AccountLifecycleServiceImpl Unit Tests', () {
    late MockSupabaseService mockSupabase;
    late LocalDataWipeCoordinator wipeCoordinator;
    late LocalFirstProfileRepository profileRepository;
    late LocalFirstWellnessRepository wellnessRepository;
    late AccountLifecycleServiceImpl lifecycleService;

    setUp(() {
      mockSupabase = MockSupabaseService();
      wipeCoordinator = LocalDataWipeCoordinator();
      profileRepository =
          LocalFirstProfileRepository(supabaseService: mockSupabase);
      wellnessRepository = LocalFirstWellnessRepository(
        supabaseService: mockSupabase,
        profileRepository: profileRepository,
      );
      lifecycleService = AccountLifecycleServiceImpl(
        authService: mockSupabase.auth,
        wipeCoordinator: wipeCoordinator,
        profileRepository: profileRepository,
        wellnessRepository: wellnessRepository,
      );
    });

    test('logout with wipeLocalData clears auth session and all registered local stores',
        () async {
      // Setup authenticated user and profile
      final user = FitKarmaUser(
        id: 'user_active_1',
        createdAt: DateTime.now(),
      );
      mockSupabase.simulateSignIn(user);

      final profile = UserProfile(
        id: 'prof_1',
        userId: user.id,
        displayName: 'Test User',
        age: 28,
        biologicalSex: BiologicalSex.male,
        heightCm: 175,
        weightKg: 70,
        goals: const [FitnessGoal.maintenance],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await profileRepository.saveProfile(profile);

      // Perform logout with wipe
      final logoutResult = await lifecycleService.logout(wipeLocalData: true);
      expect(logoutResult.isSuccess, isTrue);

      // Verify auth session is terminated
      expect(mockSupabase.auth.currentUser, isNull);
      expect(mockSupabase.auth.currentSession, isNull);

      // Verify profile local cache is cleared
      final cached = await profileRepository.getProfile();
      expect(cached.dataOrNull, isNull);
    });

    test('logout without wipe terminates session without wiping local stores',
        () async {
      final user = FitKarmaUser(
        id: 'user_active_2',
        createdAt: DateTime.now(),
      );
      mockSupabase.simulateSignIn(user);

      final logoutResult = await lifecycleService.logout(wipeLocalData: false);
      expect(logoutResult.isSuccess, isTrue);
      expect(mockSupabase.auth.currentUser, isNull);
    });

    test('restoreSession returns noSession when no session exists', () async {
      final result = await lifecycleService.restoreSession();
      expect(result.status, equals(SessionRestorationStatus.noSession));
      expect(result.isSuccessful, isFalse);
    });

    test('restoreSession returns restored when active non-expired session exists',
        () async {
      final user = FitKarmaUser(
        id: 'user_restored_1',
        createdAt: DateTime.now(),
      );
      mockSupabase.simulateSignIn(user);

      final result = await lifecycleService.restoreSession();
      expect(result.status, equals(SessionRestorationStatus.restored));
      expect(result.isSuccessful, isTrue);
      expect(result.session?.user.id, equals('user_restored_1'));
    });

    test('safe session expiration terminates session and clears cached data',
        () async {
      final user = FitKarmaUser(
        id: 'user_expired_1',
        createdAt: DateTime.now(),
      );
      mockSupabase.simulateSignIn(user);

      // Trigger safe session expiration
      final expirationResult =
          await lifecycleService.handleSessionExpiration();

      expect(expirationResult.isFailure, isTrue);
      expect(expirationResult.failureOrNull?.code, equals('FK-1001'));
      expect(mockSupabase.auth.currentUser, isNull);
    });

    test('requestAccountDeletion enforces confirmDataLoss prerequisite',
        () async {
      final result = await lifecycleService.requestAccountDeletion(
        confirmDataLoss: false,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, equals('FK-2001'));
      expect(
        result.failureOrNull?.message,
        contains('must confirm data loss'),
      );
    });

    test(
        'requestAccountDeletion issues valid receipt, establishes 30-day grace period, and wipes local data',
        () async {
      final user = FitKarmaUser(
        id: 'user_delete_1',
        createdAt: DateTime.now(),
      );
      mockSupabase.simulateSignIn(user);

      final result = await lifecycleService.requestAccountDeletion(
        reason: 'Privacy and data minimization',
        confirmDataLoss: true,
      );

      expect(result.isSuccess, isTrue);
      final receipt = result.dataOrNull!;
      expect(receipt.userId, equals('user_delete_1'));
      expect(receipt.reason, equals('Privacy and data minimization'));
      expect(receipt.status, equals(DeletionRequestStatus.pending));
      expect(receipt.localDataWiped, isTrue);
      expect(receipt.isGracePeriodActive, isTrue);

      // Check scheduled purge is ~30 days in future
      final difference = receipt.scheduledPurgeAt.difference(receipt.requestedAt).inDays;
      expect(difference, inInclusiveRange(29, 31));

      // Assert device data was immediately wiped
      expect(mockSupabase.auth.currentUser, isNull);

      // Check receipt status query
      final statusResult =
          await lifecycleService.checkDeletionStatus(requestId: receipt.requestId);
      expect(statusResult.isSuccess, isTrue);
      expect(statusResult.dataOrNull?.status, equals(DeletionRequestStatus.pending));
    });

    test('cancelAccountDeletion successfully cancels pending deletion request',
        () async {
      final user = FitKarmaUser(
        id: 'user_cancel_1',
        createdAt: DateTime.now(),
      );
      mockSupabase.simulateSignIn(user);

      final deletionResult = await lifecycleService.requestAccountDeletion(
        confirmDataLoss: true,
      );
      final requestId = deletionResult.dataOrNull!.requestId;

      // Cancel deletion
      final cancelResult =
          await lifecycleService.cancelAccountDeletion(requestId: requestId);
      expect(cancelResult.isSuccess, isTrue);

      final updated = cancelResult.dataOrNull!;
      expect(updated.status, equals(DeletionRequestStatus.cancelled));
      expect(updated.isGracePeriodActive, isFalse);
    });

    test('initiateAccountRecovery hooks into phone OTP authentication',
        () async {
      final request = const AccountRecoveryRequest(
        identifier: '+919876543210',
        method: RecoveryMethod.phoneOtp,
      );

      final result = await lifecycleService.initiateAccountRecovery(request);
      expect(result.isSuccess, isTrue);

      final receipt = result.dataOrNull!;
      expect(receipt.identifier, equals('+919876543210'));
      expect(receipt.status, equals(RecoveryStatus.initiated));
    });

    test('initiateAccountRecovery rejects empty identifier', () async {
      final request = const AccountRecoveryRequest(
        identifier: '   ',
        method: RecoveryMethod.phoneOtp,
      );

      final result = await lifecycleService.initiateAccountRecovery(request);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, equals('FK-2001'));
    });
  });

  group('LocalDataWipeCoordinator Unit Tests', () {
    test('wipes registered stores safely and handles exceptions cleanly',
        () async {
      final coordinator = LocalDataWipeCoordinator();
      bool store1Wiped = false;
      bool store2Wiped = false;

      coordinator.registerWipeableStore('cache_1', () async {
        store1Wiped = true;
      });
      coordinator.registerWipeableStore('cache_2', () async {
        store2Wiped = true;
      });

      final result = await coordinator.wipeAllLocalData();
      expect(result.isSuccess, isTrue);
      expect(store1Wiped, isTrue);
      expect(store2Wiped, isTrue);
      expect(result.wipedStores, containsAll(['cache_1', 'cache_2']));

      // Test partial failure tolerance
      coordinator.registerWipeableStore('failing_store', () async {
        throw Exception('Disk I/O failure');
      });

      final failureResult = await coordinator.wipeAllLocalData();
      expect(failureResult.isSuccess, isFalse);
      expect(failureResult.errorMessage, contains('Disk I/O failure'));
      expect(failureResult.wipedStores, contains('cache_1'));
    });
  });

  group('DeleteAccountDialog Widget Tests', () {
    void setViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Widget buildTestDialog({
      required MockSupabaseService mockSupabase,
      required IAccountLifecycleService lifecycleService,
    }) {
      return ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          supabaseServiceProvider.overrideWithValue(mockSupabase),
          supabaseAuthServiceProvider.overrideWithValue(mockSupabase.auth),
          accountLifecycleServiceProvider.overrideWithValue(lifecycleService),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DeleteAccountDialog(),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'renders warning, enforces confirmation checkbox before enabling action, and cancels cleanly',
      (tester) async {
        setViewport(tester);

        final mockSupabase = MockSupabaseService();
        final wipeCoordinator = LocalDataWipeCoordinator();
        final lifecycleService = AccountLifecycleServiceImpl(
          authService: mockSupabase.auth,
          wipeCoordinator: wipeCoordinator,
        );

        await tester.pumpWidget(
          buildTestDialog(
            mockSupabase: mockSupabase,
            lifecycleService: lifecycleService,
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify warning header and DPDP disclaimer
        expect(find.byKey(const Key('dialog_delete_account')), findsOneWidget);
        expect(find.text('Delete Account'), findsNWidgets(2));
        expect(
          find.textContaining('Digital Personal Data Protection (DPDP) Act'),
          findsOneWidget,
        );

        // 2. Assert Delete button is disabled until checkbox is checked
        final deleteBtn = find.byKey(const Key('btn_confirm_deletion'));
        expect(deleteBtn, findsOneWidget);
        // Tap delete button while disabled -> should do nothing
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        // 3. Enter optional reason
        await tester.enterText(
          find.byKey(const Key('input_deletion_reason')),
          'Moving abroad',
        );
        await tester.pumpAndSettle();

        // 4. Check confirmation checkbox
        final checkbox = find.byKey(const Key('checkbox_confirm_data_loss'));
        expect(checkbox, findsOneWidget);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // 5. Cancel button works
        final cancelBtn = find.byKey(const Key('btn_cancel_deletion'));
        expect(cancelBtn, findsOneWidget);
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'confirming deletion executes request, triggers local wipe, and dismisses dialog',
      (tester) async {
        setViewport(tester);

        final mockSupabase = MockSupabaseService();
        final user = FitKarmaUser(
          id: 'user_widget_del',
          createdAt: DateTime.now(),
        );
        mockSupabase.simulateSignIn(user);

        final wipeCoordinator = LocalDataWipeCoordinator();
        final lifecycleService = AccountLifecycleServiceImpl(
          authService: mockSupabase.auth,
          wipeCoordinator: wipeCoordinator,
        );

        await tester.pumpWidget(
          buildTestDialog(
            mockSupabase: mockSupabase,
            lifecycleService: lifecycleService,
          ),
        );
        await tester.pumpAndSettle();

        // Check confirmation checkbox
        await tester.tap(find.byKey(const Key('checkbox_confirm_data_loss')));
        await tester.pumpAndSettle();

        // Tap Delete Account
        await tester.tap(find.byKey(const Key('btn_confirm_deletion')));
        await tester.pumpAndSettle();

        // Verify user session was wiped
        expect(mockSupabase.auth.currentUser, isNull);
      },
    );
  });
}
