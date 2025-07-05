import 'package:flutter/material.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/widgets/stat_row.dart';

class WeekStatsDialog extends StatelessWidget {
  final List<Task> tasks;
  final List<DateTime> weekDays;

  const WeekStatsDialog({
    Key? key,
    required this.tasks,
    required this.weekDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final weekTasks = tasks.where((task) {
      return weekDays.any((day) =>
          task.date.year == day.year &&
          task.date.month == day.month &&
          task.date.day == day.day);
    }).toList();

    final completedTasks = weekTasks.where((task) => task.isCompleted).length;
    final totalTasks = weekTasks.length;
    final highPriorityTasks = weekTasks.where((task) => task.priority == 2).length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.weekStats,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            StatRow(
              icon: Icons.task_alt_rounded,
              label: localizations.totalTasks,
              value: totalTasks.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            StatRow(
              icon: Icons.check_circle_rounded,
              label: localizations.completed,
              value: completedTasks.toString(),
              color: Colors.greenAccent,
            ),
            StatRow(
              icon: Icons.pending_rounded,
              label: localizations.pending,
              value: (totalTasks - completedTasks).toString(),
              color: Colors.amber,
            ),
            StatRow(
              icon: Icons.priority_high_rounded,
              label: localizations.highPriority,
              value: highPriorityTasks.toString(),
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              totalTasks > 0
                  ? '${localizations.progress}: ${((completedTasks / totalTasks) * 100).round()}%'
                  : localizations.noTasks,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Text(
                localizations.close,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}