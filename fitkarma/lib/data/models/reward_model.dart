enum RewardType { discount, physical, digital }

class Reward {
  final String id;
  final String title;
  final String description;
  final int karmaCost;
  final String imageUrl;
  final RewardType type;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.karmaCost,
    required this.imageUrl,
    required this.type,
  });

  static const List<Reward> initialRewards = [
    Reward(
      id: 'reward_1',
      title: '1 Month Premium',
      description:
          'Unlock all pro features, voice logging, and advanced analytics for 30 days.',
      karmaCost: 500,
      imageUrl: 'assets/images/rewards/premium.png',
      type: RewardType.digital,
    ),
    Reward(
      id: 'reward_2',
      title: 'FitKarma T-shirt',
      description: 'Official premium cotton t-shirt with the FitKarma logo.',
      karmaCost: 2000,
      imageUrl: 'assets/images/rewards/tshirt.png',
      type: RewardType.physical,
    ),
    Reward(
      id: 'reward_3',
      title: '20% Yoga Mat Discount',
      description:
          'Get 20% off on your next purchase of eco-friendly yoga mats from our partners.',
      karmaCost: 300,
      imageUrl: 'assets/images/rewards/yoga_mat.png',
      type: RewardType.discount,
    ),
    Reward(
      id: 'reward_4',
      title: 'Personalized Meal Plan',
      description:
          'Get a 7-day personalized meal plan tailored specifically to your Dosha and fitness goals.',
      karmaCost: 1000,
      imageUrl: 'assets/images/rewards/meal_plan.png',
      type: RewardType.digital,
    ),
  ];
}
