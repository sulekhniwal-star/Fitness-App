import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/gps_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/network/pocketbase_client.dart';

class ActivityTrackingScreen extends ConsumerWidget {
  const ActivityTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsProvider);

    // Default center if no path yet
    final initialCenter = gpsState.path.isNotEmpty
        ? LatLng(gpsState.path.last.latitude, gpsState.path.last.longitude)
        : const LatLng(20.5937, 78.9629); // Center of India

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fitkarma.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: gpsState.path
                        .map((p) => LatLng(p.latitude, p.longitude))
                        .toList(),
                    color: AppTheme.primaryColor,
                    strokeWidth: 5,
                  ),
                ],
              ),
              if (gpsState.path.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        gpsState.path.last.latitude,
                        gpsState.path.last.longitude,
                      ),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (gpsState.status != TrackingStatus.idle) {
                    _showExitDiscardDialog(context, ref);
                  } else {
                    context.pop();
                  }
                },
              ),
            ),
          ),

          // Stats Overlay
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                _buildStatsPanel(context, gpsState),
                const SizedBox(height: 16),
                _buildControls(context, ref, gpsState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(BuildContext context, GPSState state) {
    final distanceKm = (state.totalDistance / 1000).toStringAsFixed(2);
    final durationStr = _formatDuration(state.duration);

    // Calculate Pace (min/km)
    String paceStr = "0'00\"";
    if (state.totalDistance > 10) {
      final totalMinutes = state.duration.inSeconds / 60;
      final avgPace = totalMinutes / (state.totalDistance / 1000);
      final paceMin = avgPace.floor();
      final paceSec = ((avgPace - paceMin) * 60).round();
      paceStr = "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Distance", distanceKm, "km"),
          _buildStatItem("Time", durationStr, ""),
          _buildStatItem("Pace", paceStr, "/km"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, GPSState state) {
    final gpsNotifier = ref.read(gpsProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.status == TrackingStatus.idle)
          _buildActionButton(
            "START ACTIVITY",
            AppTheme.primaryColor,
            Icons.play_arrow,
            () => gpsNotifier.startTracking(),
            isWide: true,
          )
        else ...[
          if (state.status == TrackingStatus.tracking)
            _buildActionButton(
              "PAUSE",
              Colors.orange,
              Icons.pause,
              () => gpsNotifier.pauseTracking(),
            )
          else
            _buildActionButton(
              "RESUME",
              AppTheme.primaryColor,
              Icons.play_arrow,
              () => gpsNotifier.resumeTracking(),
            ),
          const SizedBox(width: 20),
          _buildActionButton(
            "STOP",
            Colors.red,
            Icons.stop,
            () => _showStopSummary(context, ref, state),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
      String label, Color color, IconData icon, VoidCallback onTap,
      {bool isWide = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: isWide ? 40 : 24, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == "00" ? "$minutes:$seconds" : "$hours:$minutes:$seconds";
  }

  void _showExitDiscardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Activity?"),
        content: const Text("Your current progress will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              ref.read(gpsProvider.notifier).stopTracking();
              Navigator.pop(context); // Dialog
              context.pop(); // Screen
            },
            child: const Text("DISCARD", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStopSummary(BuildContext context, WidgetRef ref, GPSState state) {
    final distanceKm = state.totalDistance / 1000;
    final karmaEarned = (distanceKm * 2).round();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events,
                size: 60, color: AppTheme.saffronColor),
            const SizedBox(height: 16),
            const Text(
              "Activity Complete!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You've earned +$karmaEarned Karma points",
              style: const TextStyle(
                  color: AppTheme.saffronColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                    "Distance", "${distanceKm.toStringAsFixed(2)} km"),
                _buildSummaryStat("Duration", _formatDuration(state.duration)),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                await _saveActivity(ref, state, karmaEarned);
                ref.read(gpsProvider.notifier).stopTracking();
                if (context.mounted) {
                  Navigator.pop(context); // BottomSheet
                  context.pop(); // Screen
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("SAVE & FINISH"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("RESUME TRACKING"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _saveActivity(WidgetRef ref, GPSState state, int karma) async {
    final pb = ref.read(pocketBaseProvider);
    final user = ref.read(pocketBaseProvider).authStore.record;

    if (user == null) return;

    try {
      // 1. Create activity log
      await pb.collection('activity_logs').create(body: {
        'user': user.id,
        'type': 'outdoor_tracking',
        'distance': state.totalDistance,
        'duration': state.duration.inSeconds,
        'path': state.path.map((p) => p.toJson()).toList(),
        'points': karma,
        'created': DateTime.now().toIso8601String(),
      });

      // 2. Update user karma
      final newKarma = (user.getIntValue('karma_points')) + karma;
      await pb.collection('users').update(user.id, body: {
        'karma_points': newKarma,
      });

      // 3. Proactively refresh user data
      await ref.read(authStateProvider.notifier).refreshUser();
    } catch (e) {
      debugPrint("Error saving activity: $e");
    }
  }
}
