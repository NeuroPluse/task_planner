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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(localizations.weekStats),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatRow(
            icon: Icons.task_alt,
            label: localizations.totalTasks,
            value: totalTasks.toString(),
          ),
          StatRow(
            icon: Icons.check_circle,
            label: localizations.completed,
            value: completedTasks.toString(),
            color: Colors.green,
          ),
          StatRow(
            icon: Icons.pending,
            label: localizations.pending,
            value: (totalTasks - completedTasks).toString(),
            color: Colors.orange,
          ),
          StatRow(
            icon: Icons.priority_high,
            label: localizations.highPriority,
            value: highPriorityTasks.toString(),
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: totalTasks > 0 ? completedTasks / totalTasks : 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            totalTasks > 0
                ? 'Прогресс: ${((completedTasks / totalTasks) * 100).round()}%'
                : localizations.noTasks,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.close),
        ),
      ],
    );
  }
}