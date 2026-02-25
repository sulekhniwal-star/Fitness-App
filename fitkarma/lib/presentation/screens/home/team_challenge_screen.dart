import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/team_provider.dart';

class TeamChallengeScreen extends ConsumerWidget {
  const TeamChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamState = ref.watch(teamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Challenges'),
        actions: [
          if (teamState.userTeam == null)
            TextButton.icon(
              onPressed: () => _showCreateTeamDialog(context, ref),
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              label: const Text('New Team'),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // User Team Header
          SliverToBoxAdapter(
            child: teamState.userTeam != null
                ? _buildMyTeamCard(context, teamState.userTeam!)
                : _buildJoinPrompt(context),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Team Leaderboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Team Leaderboard List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final team = teamState.teams[index];
                final avgKarma = team.totalKarma /
                    (team.memberIds.isNotEmpty ? team.memberIds.length : 1);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(team.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${team.memberIds.length} members'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${avgKarma.toInt()} avg',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor),
                      ),
                      const Text('Karma', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  onTap: teamState.userTeam == null
                      ? () => _confirmJoinTeam(context, ref, team)
                      : null,
                );
              },
              childCount: teamState.teams.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildMyTeamCard(BuildContext context, dynamic team) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: AppTheme.primaryColor, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('YOUR TEAM',
                      style: TextStyle(fontSize: 10, letterSpacing: 1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Members', '${team.memberIds.length}'),
              _buildStat('Total Karma', '${team.totalKarma}'),
              _buildStat('World Rank', '#1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildJoinPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.saffronColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.saffronColor.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.group_add, color: AppTheme.saffronColor, size: 48),
          SizedBox(height: 16),
          Text(
            'Health is better when shared!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Join a team to compete in local challenges and represent your workspace.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Health Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: 'Team Name (e.g. Sales Sultans)'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Motto'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref
                    .read(teamProvider.notifier)
                    .createTeam(nameController.text, descController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  void _confirmJoinTeam(BuildContext context, WidgetRef ref, dynamic team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join ${team.name}?'),
        content: const Text('Compete together and pool your Karma points!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              ref.read(teamProvider.notifier).joinTeam(team.id);
              Navigator.pop(context);
            },
            child: const Text('JOIN'),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return AppTheme.saffronColor;
    if (index == 1) return Colors.grey;
    if (index == 2) return Colors.brown;
    return AppTheme.primaryColor.withValues(alpha: 0.5);
  }
}
