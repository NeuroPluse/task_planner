import 'package:flutter/material.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color priorityColor;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.priorityColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        color: Colors.greenAccent.withOpacity(0.8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        color: Colors.redAccent.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
        } else {
          onDelete();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          title: Text(
            task.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: task.description.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: priorityColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context);
                            return Text(localizations.edit, style: Theme.of(context).textTheme.bodyMedium);
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context);
                            return Text(
                              localizations.delete,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}