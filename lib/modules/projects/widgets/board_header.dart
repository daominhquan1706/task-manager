import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/kanban_column.dart';
import '../../../data/models/kanban_project.dart';
import '../../../data/models/kanban_task.dart';

class BoardHeader extends StatelessWidget {
  const BoardHeader({
    required this.project,
    required this.columns,
    required this.tasks,
    required this.onBack,
    required this.onCreateTask,
    super.key,
  });

  final KanbanProject project;
  final List<KanbanColumn> columns;
  final List<KanbanTask> tasks;
  final VoidCallback onBack;
  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final doneColumnIds = columns
        .where((column) => column.id == 'done' || column.label.toLowerCase() == 'done')
        .map((column) => column.id)
        .toSet();
    final completed = tasks.where((task) => doneColumnIds.contains(task.statusId)).length;
    final percent = tasks.isEmpty ? 0 : ((completed / tasks.length) * 100);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          return Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: compact ? constraints.maxWidth : 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back to projects',
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            project.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 24,
                              height: 32 / 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      project.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tasks.length} tasks · ${percent.round()}% complete',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded, size: 18),
                    label: const Text('Filter'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort_rounded, size: 18),
                    label: const Text('Sort'),
                  ),
                  ElevatedButton.icon(
                    onPressed: onCreateTask,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(124, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
