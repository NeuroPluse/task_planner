import 'dart:ui';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedPriority = widget.task?.priority ?? 1;
    _selectedCategory = widget.task?.category ?? 'General';
    _selectedRecurrence = widget.task?.recurrence;
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

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
        return Colors.red;
      case 1:
        return Colors.orange;
      case 0:
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: localizations.taskName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.task_alt),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: localizations.description,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.description),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: localizations.priority,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.flag),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              items: [0, 1, 2].map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                labelText: 'Категория',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.category),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              items: ['General', 'Work', 'Personal', 'Study'].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
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
                labelText: 'Повторение',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.repeat),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Без повторения'),
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
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                elevation: 8,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _buttonAnimationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Text(widget.task == null ? localizations.createTask : localizations.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}