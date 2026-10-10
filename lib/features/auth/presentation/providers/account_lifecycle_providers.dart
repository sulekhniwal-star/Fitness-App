import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/auth/data/services/account_lifecycle_service_impl.dart';
import 'package:fitkarma/features/auth/domain/services/account_lifecycle_service.dart';
import 'package:fitkarma/features/auth/domain/services/local_data_wipe_coordinator.dart';
import 'package:fitkarma/features/auth/presentation/controllers/account_lifecycle_controller.dart';
import 'package:fitkarma/features/profile/presentation/providers/profile_providers.dart';
import 'package:fitkarma/features/profile/presentation/providers/wellness_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the centralized [ILocalDataWipeCoordinator].
final localDataWipeCoordinatorProvider =
    Provider<ILocalDataWipeCoordinator>((ref) {
  return LocalDataWipeCoordinator();
});

/// Provides the [IAccountLifecycleService] with wired domain dependencies.
final accountLifecycleServiceProvider =
    Provider<IAccountLifecycleService>((ref) {
  final authService = ref.watch(supabaseAuthServiceProvider);
  final wipeCoordinator = ref.watch(localDataWipeCoordinatorProvider);
  final profileRepo = ref.watch(userProfileRepositoryProvider);
  final wellnessRepo = ref.watch(wellnessProfileRepositoryProvider);
  final supabase = ref.watch(supabaseServiceProvider);

  return AccountLifecycleServiceImpl(
    authService: authService,
    wipeCoordinator: wipeCoordinator,
    profileRepository: profileRepo,
    wellnessRepository: wellnessRepo,
    functionsService: supabase.functions,
  );
});

/// State controller provider for Account Lifecycle operations.
final accountLifecycleControllerProvider = StateNotifierProvider.autoDispose<
    AccountLifecycleController, AccountLifecycleState>((ref) {
  final lifecycleService = ref.watch(accountLifecycleServiceProvider);
  return AccountLifecycleController(lifecycleService);
});
