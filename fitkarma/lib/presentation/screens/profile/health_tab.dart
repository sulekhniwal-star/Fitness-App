import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/weight_provider.dart';

class HealthTab extends ConsumerStatefulWidget {
  const HealthTab({super.key});

  @override
  ConsumerState<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends ConsumerState<HealthTab> {
  @override
  Widget build(BuildContext context) {
    final weightLogs = ref.watch(weightProvider);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Metrics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null)
              _buildBMICard(context, user.weightKg ?? 0.0, user.heightCm ?? 0.0,
                  user.bmi ?? 0.0),
            const SizedBox(height: 24),
            _buildChartSection(context, weightLogs),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showUpdateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Log New Weight & Height'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard(
      BuildContext context, double weight, double height, double bmi) {
    // Determine category correctly based on standard Indian demographics mappings.
    // Generally, Asian/Indian BMI markers are slightly lower than generic WHO ones.
    String category = 'Unknown';
    Color color = Colors.grey;

    if (bmi > 0 && bmi < 18.5) {
      category = 'Underweight';
      color = Colors.orange;
    } else if (bmi >= 18.5 && bmi <= 22.9) {
      category = 'Normal';
      color = AppTheme.primaryColor;
    } else if (bmi >= 23 && bmi <= 24.9) {
      category = 'Overweight';
      color = Colors.orange;
    } else if (bmi >= 25) {
      category = 'Obese';
      color = AppTheme.errorColor;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Your BMI Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('${weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Weight', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text(bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(category,
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('${height.toStringAsFixed(1)} cm',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('Height', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, List logs) {
    if (logs.isEmpty) {
      return const Center(
          child: Text('No weight history yet. Add one to see trends!'));
    }

    // Sort ascending for chart (earliest to latest)
    final sortedLogs = List.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    // For FlChart, we need floats X and Y
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedLogs[i].weightKg));
    }

    final minWei =
        sortedLogs.reduce((a, b) => a.weightKg < b.weightKg ? a : b).weightKg -
            5.0;
    final maxWei =
        sortedLogs.reduce((a, b) => a.weightKg > b.weightKg ? a : b).weightKg +
            5.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Weight Trend (kg)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minWei < 0 ? 0 : minWei,
                maxY: maxWei,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false)), // Simplified for MVP
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    double newWeight = user.weightKg ?? 0.0;
    double newHeight = user.heightCm ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update Vitals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: (user.weightKg ?? 0.0).toString(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                onChanged: (val) =>
                    newWeight = double.tryParse(val) ?? newWeight,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: (user.heightCm ?? 0.0).toString(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                onChanged: (val) =>
                    newHeight = double.tryParse(val) ?? newHeight,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(weightProvider.notifier)
                    .logWeight(newWeight, newHeight);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Health metrics safely updated!')),
                );
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }
}
