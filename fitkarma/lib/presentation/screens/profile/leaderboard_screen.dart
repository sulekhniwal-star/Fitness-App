import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/leaderboard_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../core/network/pocketbase_client.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardProvider);
    final curUser = ref.watch(pocketBaseProvider).authStore.record;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karma Leaderboard'),
        elevation: 0,
      ),
      body: state.isLoading && state.topUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(leaderboardProvider.notifier).fetchLeaderboard(),
              child: Column(
                children: [
                  _buildTopThree(context, state.topUsers),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: state.topUsers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = state.topUsers[index];
                        final isMe = user.id == curUser?.id;
                        return _buildLeaderboardTile(
                            context, user, index + 1, isMe);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTopThree(BuildContext context, List<UserModel> users) {
    if (users.length < 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(context, users[1], 2, 100), // Silver (2nd)
          _buildPodiumItem(context, users[0], 1, 130), // Gold (1st)
          _buildPodiumItem(context, users[2], 3, 100), // Bronze (3rd)
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
      BuildContext context, UserModel user, int rank, double height) {
    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = const Color(0xFFFFD700);
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32);
        break;
      default:
        medalColor = Colors.grey;
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 40 : 32,
              backgroundColor: medalColor.withValues(alpha: 0.2),
              child: CircleAvatar(
                radius: rank == 1 ? 36 : 28,
                backgroundColor: Colors.white,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: rank == 1 ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: medalColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name.split(' ')[0],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          '${user.karmaPoints}',
          style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
      BuildContext context, UserModel user, int rank, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                color: rank <= 3 ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              user.name[0].toUpperCase(),
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isMe ? '${user.name} (You)' : user.name,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${user.karmaPoints} pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
