import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/providers/task_provider.dart';
import 'package:weekly_task_planner/providers/theme_provider.dart';
import 'package:weekly_task_planner/screens/settings_screen.dart';
import 'package:weekly_task_planner/widgets/task_form_sheet.dart';
import 'package:weekly_task_planner/widgets/task_tile.dart';
import 'package:weekly_task_planner/widgets/week_stats_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({Key? key}) : super(key: key);

  @override
  _WeeklyPlannerScreenState createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen>
    with TickerProviderStateMixin {
  DateTime selectedWeek = DateTime.now();
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _getWeekDays() {
    final startOfWeek = _getStartOfWeek(selectedWeek);
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Task> _getTasksForDate(DateTime date, List<Task> tasks) {
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  double _getWeekProgress(List<Task> tasks) {
    final weekDays = _getWeekDays();
    final weekTasks = tasks.where((task) {
      return weekDays.any((day) =>
          task.date.year == day.year &&
          task.date.month == day.month &&
          task.date.day == day.day);
    }).toList();

    if (weekTasks.isEmpty) return 0;
    final completedTasks = weekTasks.where((task) => task.isCompleted).length;
    return completedTasks / weekTasks.length;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 0:
      default:
        return Colors.green;
    }
  }

  void _addTask(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TaskFormSheet(
            date: date,
            onTaskAdded: (task) {
              context.read<TaskProvider>().addTask(task);
            },
          ),
        ),
      ),
    );
  }

  void _editTask(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TaskFormSheet(
            task: task,
            date: task.date,
            onTaskAdded: (updatedTask) {
              context.read<TaskProvider>().updateTask(updatedTask);
            },
          ),
        ),
      ),
    );
  }

  void _deleteTask(Task task, int index) {
    final localizations = AppLocalizations.of(context);
    context.read<TaskProvider>().deleteTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.taskDeleted),
        action: SnackBarAction(
          label: localizations.undo,
          onPressed: () {
            context.read<TaskProvider>().addTask(task);
          },
        ),
      ),
    );
  }

  void _toggleTaskCompletion(Task task) {
    context.read<TaskProvider>().toggleTaskCompletion(task);
    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final weekDays = _getWeekDays();
    final progress = _getWeekProgress(tasks);
    final localizations = AppLocalizations.of(context);
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.appTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => WeekStatsDialog(
                  tasks: tasks,
                  weekDays: weekDays,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!.withOpacity(0.5),
              Colors.white,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              selectedWeek = selectedWeek.subtract(const Duration(days: 7));
                            });
                            _progressAnimationController.reset();
                            _progressAnimationController.forward();
                          },
                        ),
                        Text(
                          '${weekDays.first.day}.${weekDays.first.month} - ${weekDays.last.day}.${weekDays.last.month}.${weekDays.last.year}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              selectedWeek = selectedWeek.add(const Duration(days: 7));
                            });
                            _progressAnimationController.reset();
                            _progressAnimationController.forward();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.progress),
                        Text('${(progress * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ).createShader(bounds),
                          child: LinearProgressIndicator(
                            value: progress * _progressAnimation.value,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            minHeight: 6,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: taskProvider.selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      items: taskProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        taskProvider.setCategoryFilter(value!);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: weekDays.length,
                itemBuilder: (context, index) {
                  final day = weekDays[index];
                  final dayTasks = _getTasksForDate(day, tasks);
                  final isToday = DateTime.now().day == day.day &&
                      DateTime.now().month == day.month &&
                      DateTime.now().year == day.year;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isToday
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        localizations.getDayName(day.weekday),
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('${dayTasks.length} ${localizations.tasks}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (dayTasks.isNotEmpty)
                            CircularProgressIndicator(
                              value: dayTasks.where((t) => t.isCompleted).length /
                                  dayTasks.length,
                              strokeWidth: 3,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addTask(day),
                          ),
                        ],
                      ),
                      children: dayTasks.map((task) => TaskTile(
                            key: ValueKey(task.id),
                            task: task,
                            onToggle: () => _toggleTaskCompletion(task),
                            onEdit: () => _editTask(task),
                            onDelete: () => _deleteTask(task, index),
                            priorityColor: _getPriorityColor(task.priority),
                          )).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}