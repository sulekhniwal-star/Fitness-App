import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isPremium = user?.subscriptionTier != 'free';
    final subState = ref.watch(subscriptionProvider);

    // Listen for success/error
    ref.listen(subscriptionProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Successful! Welcome to Premium.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                if (isPremium)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppTheme.saffronColor, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You are a Premium Member!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Current Tier: ${user?.subscriptionTier.toUpperCase() ?? "FREE"}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Unlock India’s Best Fitness App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Remove ads, get personal AI meal plans, and more.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildPricingCard(
                  context,
                  ref,
                  title: 'Monthly',
                  price: AppConstants.monthlyPrice,
                  duration: '/month',
                  isPopular: false,
                  planCode: 'monthly',
                ),
                _buildPricingCard(
                  context,
                  ref,
                  title: 'Quarterly',
                  price: AppConstants.quarterlyPrice,
                  duration: '/3 months',
                  isPopular: true,
                  planCode: 'quarterly',
                ),
                _buildPricingCard(
                  context,
                  ref,
                  title: 'Yearly',
                  price: AppConstants.yearlyPrice,
                  duration: '/year',
                  isPopular: false,
                  planCode: 'yearly',
                ),
                _buildPricingCard(
                  context,
                  ref,
                  title: 'Family',
                  price: AppConstants.familyPrice,
                  duration: '/year',
                  subtitle: 'Up to 5 members',
                  isPopular: false,
                  planCode: 'family',
                ),
              ],
            ),
          ),
          if (subState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required double price,
    required String duration,
    String? subtitle,
    required bool isPopular,
    required String planCode,
  }) {
    return Card(
      elevation: isPopular ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${price.toInt()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(duration, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(subscriptionProvider.notifier)
                        .startPayment(price, planCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular
                        ? AppTheme.primaryColor
                        : Colors.grey.shade200,
                    foregroundColor: isPopular ? Colors.white : Colors.black87,
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.saffronColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
