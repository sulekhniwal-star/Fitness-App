import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/activity_log_provider.dart';
import '../../../data/models/activity_log_model.dart';

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityLogProvider);

    return Scaffold(

      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, ref);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(activityLogProvider.notifier).fetchLogs(refresh: true),
        child: _buildBody(context, ref, activityState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ActivityLogState state) {
    if (state.isLoading && state.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No activities yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your fitness journey!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    final groupedLogs = state.groupedByDate;
    final sortedDates = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: sortedDates.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sortedDates.length) {
          // Load more button
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                ref.read(activityLogProvider.notifier).fetchLogs();
              },
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load More'),
            ),
          );
        }

        final date = sortedDates[index];
        final logs = groupedLogs[date]!..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context, date),
            const SizedBox(height: 8),
            ...logs.map((log) => _buildActivityCard(context, ref, log)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, String date) {
    final parsedDate = DateTime.parse(date);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    String label;
    if (date == '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}') {
      label = 'Today';
    } else if (date == '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}') {
      label = 'Yesterday';
    } else {
      label = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, WidgetRef ref, ActivityLogModel log) {
    final color = _hexToColor(log.colorHex);

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(activityLogProvider.notifier).deleteLog(log.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                log.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            log.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            log.formattedTimestamp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          trailing: log.karmaPoints != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${log.karmaPoints}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          onTap: () => _showActivityDetails(context, log),
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context, ActivityLogModel log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _hexToColor(log.colorHex).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        log.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.activityType.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _hexToColor(log.colorHex),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.description,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Time', log.timestamp.toString()),
              if (log.karmaPoints != null)
                _buildDetailRow('Karma Points', '+${log.karmaPoints}'),
              if (log.metadata.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...log.metadata.entries.map((e) => _buildDetailRow(
                      e.key.toString().replaceAll('_', ' ').toUpperCase(),
                      e.value.toString(),
                    )),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Activities'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(context, 'All', Icons.apps),
              _buildFilterOption(context, 'Steps', Icons.directions_walk),
              _buildFilterOption(context, 'Workouts', Icons.fitness_center),
              _buildFilterOption(context, 'Food', Icons.restaurant),
              _buildFilterOption(context, 'Water', Icons.water_drop),
              _buildFilterOption(context, 'Karma', Icons.star),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        // TODO: Implement filtering
        Navigator.pop(context);
      },
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
