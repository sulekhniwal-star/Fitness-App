import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/water_provider.dart';

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterState = ref.watch(waterProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Water Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showGoalSettings(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress Circle
            _buildProgressCircle(waterState),
            const SizedBox(height: 32),
            
            // Quick Add Buttons
            _buildQuickAddButtons(ref),
            const SizedBox(height: 24),
            
            // Today's Logs
            Expanded(
              child: _buildTodayLogs(waterState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(WaterState state) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: state.progressPercent,
              strokeWidth: 15,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                '${state.todayAmount}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'of ${state.goalMl} ml',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.remainingMl} ml remaining',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButtons(WidgetRef ref) {
    final amounts = [100, 200, 250, 500];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: amounts.map((amount) {
        return _buildAddButton(
          ref,
          amount,
          amount == 250 ? 'Glass' : amount == 500 ? 'Bottle' : 'Cup',
        );
      }).toList(),
    );
  }

  Widget _buildAddButton(WidgetRef ref, int amount, String label) {
    return GestureDetector(
      onTap: () => ref.read(waterProvider.notifier).addWater(amount),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '+$amount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ml',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayLogs(WaterState state) {
    if (state.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No water logged today',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the buttons above to add water',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Log",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Could show undo or clear options
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: state.logs.length,
            itemBuilder: (context, index) {
              final log = state.logs[state.logs.length - 1 - index];
              final time = log.time != null
                  ? '${log.time!.hour.toString().padLeft(2, '0')}:${log.time!.minute.toString().padLeft(2, '0')}'
                  : '';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.amountMl} ml',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (time.isNotEmpty)
                            Text(
                              time,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.undo, color: Colors.grey[400], size: 20),
                      onPressed: () {
                        // Undo functionality could be added here
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showGoalSettings(BuildContext context, WidgetRef ref) {
    final waterState = ref.read(waterProvider);
    int selectedGoal = waterState.goalMl;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Daily Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [2000, 2500, 3000, 3500, 4000].map((goal) {
                  final isSelected = goal == selectedGoal;
                  return GestureDetector(
                    onTap: () => setState(() => selectedGoal = goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$goal ml',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(waterProvider.notifier).setGoal(selectedGoal);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Goal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
