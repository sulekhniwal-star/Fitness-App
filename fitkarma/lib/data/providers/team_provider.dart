import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/hive_service.dart';
import '../models/team_model.dart';
import '../../core/network/pocketbase_client.dart';
import 'auth_provider.dart';

class TeamState {
  final List<TeamModel> teams;
  final TeamModel? userTeam;
  final bool isLoading;

  TeamState({
    this.teams = const [],
    this.userTeam,
    this.isLoading = false,
  });

  TeamState copyWith({
    List<TeamModel>? teams,
    TeamModel? userTeam,
    bool? isLoading,
  }) {
    return TeamState(
      teams: teams ?? this.teams,
      userTeam: userTeam ?? this.userTeam,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TeamNotifier extends StateNotifier<TeamState> {
  final Ref _ref;

  TeamNotifier(this._ref) : super(TeamState()) {
    _loadTeams();
  }

  void _loadTeams() {
    final teams = HiveService.teamsBox.values.toList();
    if (teams.isNotEmpty) {
      _updateState(teams);
    }
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    state = state.copyWith(isLoading: true);
    try {
      final pb = _ref.read(pocketBaseProvider);
      final result = await pb.collection('teams').getList(sort: '-total_karma');

      final fetchedTeams = result.items
          .map((item) => TeamModel.fromJson(item.toJson()))
          .toList();

      await HiveService.teamsBox.clear();
      await HiveService.teamsBox.addAll(fetchedTeams);

      _updateState(fetchedTeams);
    } catch (e) {
      // Offline mock fallback if collection not found yet
      final teams = HiveService.teamsBox.values.toList();
      if (teams.isEmpty) {
        _seedMockTeams();
      } else {
        _updateState(teams);
      }
    }
  }

  void _seedMockTeams() {
    final mockTeams = [
      TeamModel(
        id: 'team_1',
        name: 'Kabaddi Kings',
        memberIds: ['user_1', 'user_2', 'user_3'],
        totalKarma: 4500,
        description: 'Strength and agility is our creed.',
      ),
      TeamModel(
        id: 'team_2',
        name: 'Yoga Warriors',
        memberIds: ['user_4', 'user_5'],
        totalKarma: 3200,
        description: 'Finding peace through movement.',
      ),
      TeamModel(
        id: 'team_3',
        name: 'Corporate Hustlers',
        memberIds: ['user_6', 'user_7', 'user_8', 'user_9'],
        totalKarma: 8000,
        description: 'Wellness in the boardroom.',
      ),
    ];

    for (var team in mockTeams) {
      HiveService.teamsBox.put(team.id, team);
    }
    _updateState(mockTeams);
  }

  void _updateState(List<TeamModel> teams) {
    final user = _ref.read(authStateProvider).user;
    TeamModel? userTeam;
    if (user != null) {
      try {
        userTeam = teams.firstWhere((t) => t.memberIds.contains(user.id));
      } catch (_) {
        userTeam = null;
      }
    }

    // Sort teams by avg karma
    teams.sort((a, b) {
      final avgA =
          a.totalKarma / (a.memberIds.isNotEmpty ? a.memberIds.length : 1);
      final avgB =
          b.totalKarma / (b.memberIds.isNotEmpty ? b.memberIds.length : 1);
      return avgB.compareTo(avgA);
    });

    state = state.copyWith(teams: teams, userTeam: userTeam, isLoading: false);
  }

  Future<void> createTeam(String name, String description) async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    try {
      final pb = _ref.read(pocketBaseProvider);
      await pb.collection('teams').create(body: {
        'name': name,
        'description': description,
        'members': [user.id],
        'total_karma': user.karmaPoints,
      });
      await fetchTeams();
    } catch (e) {
      // Fallback offline optimistic
      final newTeam = TeamModel(
        id: 'team_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        memberIds: [user.id],
        totalKarma: user.karmaPoints,
      );
      await HiveService.teamsBox.put(newTeam.id, newTeam);
      _loadTeams();
    }
  }

  Future<void> joinTeam(String teamId) async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    final team = HiveService.teamsBox.get(teamId);
    if (team != null && !team.memberIds.contains(user.id)) {
      try {
        final pb = _ref.read(pocketBaseProvider);
        await pb.collection('teams').update(teamId, body: {
          'members+': user.id,
          'total_karma+': user.karmaPoints,
        });
        await fetchTeams();
      } catch (e) {
        // Fallback optimistic
        final updatedMembers = [...team.memberIds, user.id];
        final updatedTeam = team.copyWith(
          memberIds: updatedMembers,
          totalKarma: team.totalKarma + user.karmaPoints,
        );
        await HiveService.teamsBox.put(teamId, updatedTeam);
        _loadTeams();
      }
    }
  }
}

final teamProvider = StateNotifierProvider<TeamNotifier, TeamState>((ref) {
  return TeamNotifier(ref);
});
