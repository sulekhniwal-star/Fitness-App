import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/payment_service.dart';

class SubscriptionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  SubscriptionState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final Ref _ref;

  SubscriptionNotifier(this._ref) : super(SubscriptionState());

  void startPayment(double amount, String planName) {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      _ref.read(paymentServiceProvider).openCheckout(amount, planName);
      // Reset loading after launch
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSuccess() {
    state = state.copyWith(isLoading: false, isSuccess: true, error: null);
  }

  void setError(String message) {
    state = state.copyWith(isLoading: false, isSuccess: false, error: message);
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref);
});
