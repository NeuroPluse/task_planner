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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOutCubic),
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
        return Colors.redAccent;
      case 1:
        return Colors.amber;
      case 0:
      default:
        return Colors.greenAccent;
    }
  }

  void _addTask(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: TaskFormSheet(
              date: date,
              onTaskAdded: (task) {
                context.read<TaskProvider>().addTask(task);
              },
            ),
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
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: TaskFormSheet(
              task: task,
              date: task.date,
              onTaskAdded: (updatedTask) {
                context.read<TaskProvider>().updateTask(updatedTask);
              },
            ),
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
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                localizations.appTitle,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
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
                            icon: const Icon(Icons.chevron_right_rounded),
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
                          Text(localizations.progress, style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            '${(progress * 100).round()}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress * _progressAnimation.value,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                              minHeight: 8,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: taskProvider.selectedCategory,
                        decoration: InputDecoration(
                          labelText: localizations.getCategoryText('Category'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: taskProvider.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(localizations.getCategoryText(category)),
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
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final day = weekDays[index];
                final dayTasks = _getTasksForDate(day, tasks);
                final isToday = DateTime.now().day == day.day &&
                    DateTime.now().month == day.month &&
                    DateTime.now().year == day.year;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: isToday
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surfaceContainer,
                        child: Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        localizations.getDayName(day.weekday),
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        localizations.getTasksCountText(dayTasks.length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (dayTasks.isNotEmpty)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: dayTasks.where((t) => t.isCompleted).length /
                                    dayTasks.length,
                                strokeWidth: 3,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _addTask(day),
                          ),
                        ],
                      ),
                      children: dayTasks
                          .asMap()
                          .entries
                          .map((entry) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.2, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: AnimationController(
                                      duration: const Duration(milliseconds: 300),
                                      vsync: this,
                                    )..forward(),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                                child: TaskTile(
                                  key: ValueKey(entry.value.id),
                                  task: entry.value,
                                  onToggle: () => _toggleTaskCompletion(entry.value),
                                  onEdit: () => _editTask(entry.value),
                                  onDelete: () => _deleteTask(entry.value, entry.key),
                                  priorityColor: _getPriorityColor(entry.value.priority),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
              childCount: weekDays.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(DateTime.now()),
        child: const Icon(Icons.add_rounded, size: 28),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 6,
        tooltip: localizations.newTask,
      ),
    );
  }
}