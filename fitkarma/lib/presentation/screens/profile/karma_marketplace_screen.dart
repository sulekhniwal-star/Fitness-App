import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/providers/karma_provider.dart';

class KarmaMarketplaceScreen extends ConsumerWidget {
  const KarmaMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karmaPoints = ref.watch(karmaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karma Marketplace'),
      ),
      body: Column(
        children: [
          // Header with Current Balance
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.saffronColor, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.saffronColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'YOUR BALANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      '$karmaPoints',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Karma points represent your dedication to health.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Reward Catalog Label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Rewards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Rewards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: Reward.initialRewards.length,
              itemBuilder: (context, index) {
                final reward = Reward.initialRewards[index];
                final canAfford = karmaPoints >= reward.karmaCost;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reward Icon/Image Placeholder
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getRewardTypeColor(reward.type)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getRewardTypeIcon(reward.type),
                            color: _getRewardTypeColor(reward.type),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Reward Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reward.description,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.stars,
                                          size: 14,
                                          color: AppTheme.saffronColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${reward.karmaCost} pts',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: canAfford
                                        ? () => _confirmRedemption(
                                            context, ref, reward)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canAfford
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade300,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      canAfford ? 'REDEEM' : 'LOCKED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: canAfford
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRedemption(BuildContext context, WidgetRef ref, Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text(
            'Do you want to spend ${reward.karmaCost} Karma points for "${reward.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final success = ref
                  .read(karmaProvider.notifier)
                  .redeemKarma(reward.karmaCost);
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully redeemed: ${reward.title}'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to redeem. Insufficient points.'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  IconData _getRewardTypeIcon(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return Icons.local_offer;
      case RewardType.physical:
        return Icons.inventory_2;
      case RewardType.digital:
        return Icons.auto_awesome;
    }
  }

  Color _getRewardTypeColor(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return AppTheme.accentColor;
      case RewardType.physical:
        return AppTheme.secondaryColor;
      case RewardType.digital:
        return AppTheme.primaryColor;
    }
  }
}
