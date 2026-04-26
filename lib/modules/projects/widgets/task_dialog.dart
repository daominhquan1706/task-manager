import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/kanban_column.dart';
import '../../../data/models/task_draft.dart';
import '../../../data/models/task_enums.dart';

class TaskDialog extends StatefulWidget {
  const TaskDialog({
    required this.columns,
    required this.initialStatusId,
    super.key,
  });

  final List<KanbanColumn> columns;
  final String initialStatusId;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _dueController = TextEditingController(text: 'Apr 30');
  final _assigneeController = TextEditingController(text: 'Quan');
  late String _statusId = widget.initialStatusId;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _dueController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create task'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Task title'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _statusId,
              decoration: const InputDecoration(labelText: 'Column'),
              items: widget.columns
                  .map(
                    (column) => DropdownMenuItem(
                      value: column.id,
                      child: Text(column.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _statusId = value);
                }
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dueController,
                    decoration: const InputDecoration(labelText: 'Due date'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _assigneeController,
                    decoration: const InputDecoration(labelText: 'Assignee'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Get.back<TaskDraft>(
              result: TaskDraft(
                title: title,
                statusId: _statusId,
                priority: _priority,
                dueDate: _dueController.text.trim().isEmpty
                    ? 'No date'
                    : _dueController.text.trim(),
                assignee: _assigneeController.text.trim().isEmpty
                    ? 'Unassigned'
                    : _assigneeController.text.trim(),
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
