import 'package:flutter/material.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? task;
  final DateTime date;
  final Function(Task) onTaskAdded;

  const TaskFormSheet({
    Key? key,
    this.task,
    required this.date,
    required this.onTaskAdded,
  }) : super(key: key);

  @override
  _TaskFormSheetState createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _selectedPriority;
  late String _selectedCategory;
  late String? _selectedRecurrence;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedPriority = widget.task?.priority ?? 1;
    _selectedCategory = widget.task?.category ?? 'General';
    _selectedRecurrence = widget.task?.recurrence;
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _buttonAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).taskRequired),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      isCompleted: widget.task?.isCompleted ?? false,
      date: widget.date,
      category: _selectedCategory,
      recurrence: _selectedRecurrence,
    );

    widget.onTaskAdded(task);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
            Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.task == null ? localizations.newTask : localizations.editTask,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: localizations.taskName,
                prefixIcon: Icon(
                  Icons.task_alt_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: localizations.description,
                prefixIcon: Icon(
                  Icons.description_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: localizations.priority,
                prefixIcon: Icon(
                  Icons.flag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              items: [0, 1, 2].map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getPriorityColor(priority).withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(localizations.getPriorityText(priority)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: localizations.getCategoryText('Category'),
                prefixIcon: Icon(
                  Icons.category_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              items: ['General', 'Work', 'Personal', 'Study'].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(localizations.getCategoryText(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedRecurrence,
              decoration: InputDecoration(
                labelText: localizations.getCategoryText('Recurrence'),
                prefixIcon: Icon(
                  Icons.repeat_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(localizations.getCategoryText('No recurrence')),
                ),
                const DropdownMenuItem(
                  value: 'daily',
                  child: Text('Ежедневно'),
                ),
                const DropdownMenuItem(
                  value: 'weekly',
                  child: Text('Еженедельно'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRecurrence = value;
                });
              },
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 8,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    child: Text(
                      widget.task == null ? localizations.createTask : localizations.save,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}