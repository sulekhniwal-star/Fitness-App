import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../data/providers/auth_provider.dart';
import '../../data/providers/subscription_provider.dart';
import '../../core/sync/sync_service.dart';

class PaymentService {
  final Ref _ref;
  late Razorpay _razorpay;

  PaymentService(this._ref) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout(double amount, String planName) {
    var options = {
      'key': 'rzp_test_mock_key_here', // Mock Test Key
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': 'FitKarma',
      'description': 'FitKarma $planName Subscription',
      'prefill': {
        'contact': _ref.read(authStateProvider).user?.phone ?? '',
        'email': _ref.read(authStateProvider).user?.email ?? ''
      },
      'notes': {
        'plan': planName,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error launching Razorpay: $e');
    }

  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Determine which plan they bought based loosely on amount or notes (mocking logic here)
    // For now we just upgrade to premium

    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    final updatedUser = user.copyWith(subscriptionTier: 'premium');
    _ref.read(authStateProvider.notifier).updateUser(updatedUser);

    // Update subscription provider state
    _ref.read(subscriptionProvider.notifier).setSuccess();

    // Sync user tier upgrade to backend
    _ref.read(syncServiceProvider).enqueueAction(
      collection: 'users',
      operation: 'update',
      recordId: user.id,
      data: {'subscription_tier': 'premium'},
    );

    // Track explicit ledger details for analytics
    _ref.read(syncServiceProvider).enqueueAction(
      collection: 'subscriptions',
      operation: 'create',
      data: {
        'user': user.id,
        'payment_id': response.paymentId ?? 'mocked_transaction_id',
        'plan_name': 'premium',
        'status': 'active',
        'amount':
            0, // In production, pass the explicit captured amount from notes caching
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Failed: ${response.message}");

    _ref
        .read(subscriptionProvider.notifier)
        .setError(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }


  void dispose() {
    _razorpay.clear();
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final service = PaymentService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
