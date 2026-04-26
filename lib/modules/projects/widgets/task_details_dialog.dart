import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/kanban_column.dart';
import '../../../data/models/kanban_task.dart';

class TaskDetailsDialog extends StatelessWidget {
  const TaskDetailsDialog({
    required this.task,
    required this.columns,
    required this.onDeleteTask,
    super.key,
  });

  final KanbanTask task;
  final List<KanbanColumn> columns;
  final ValueChanged<KanbanTask> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final column = columns.firstWhere(
      (candidate) => candidate.id == task.statusId,
      orElse: () => columns.first,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 840),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: AppColors.surfaceLowest,
            child: Column(
              children: [
                _TaskDetailsHeader(task: task, column: column),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 760;
                        final content = _TaskDetailsContent(
                          task: task,
                          column: column,
                          onDeleteTask: onDeleteTask,
                        );
                        final sidebar = _TaskDetailsSidebar(
                          task: task,
                          column: column,
                        );
                        if (!isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              content,
                              const SizedBox(height: 24),
                              sidebar,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: content),
                            const SizedBox(width: 32),
                            SizedBox(width: 256, child: sidebar),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailsHeader extends StatelessWidget {
  const _TaskDetailsHeader({required this.task, required this.column});

  final KanbanTask task;
  final KanbanColumn column;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLowest,
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.space_dashboard_outlined,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'KAN-${task.id.hashCode.abs().toString().padLeft(3, '0').substring(0, 3)}',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '/',
              style: TextStyle(color: AppColors.outline, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              column.label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Share',
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: 'More actions',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailsContent extends StatelessWidget {
  const _TaskDetailsContent({
    required this.task,
    required this.column,
    required this.onDeleteTask,
  });

  final KanbanTask task;
  final KanbanColumn column;
  final ValueChanged<KanbanTask> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 30,
            height: 38 / 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(label: column.label, color: column.color),
            _PriorityChip(label: task.priority.label),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          icon: Icons.description_outlined,
          label: 'Description',
        ),
        const SizedBox(height: 8),
        _SurfacePanel(
          child: Text(
            'No description has been added yet. Use this detail view to review ownership, due date, priority, status, and activity for the task.',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.surfaceVariant),
        const SizedBox(height: 20),
        const _SectionTitle(icon: Icons.forum_outlined, label: 'Activity'),
        const SizedBox(height: 16),
        _CommentBubble(
          initials: task.assignee.characters.first.toUpperCase(),
          author: task.assignee,
          time: 'Just now',
          message: 'Task detail opened from the board.',
        ),
        const SizedBox(height: 16),
        const _CommentComposer(),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteTask(task);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete task'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFBA1A1A),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskDetailsSidebar extends StatelessWidget {
  const _TaskDetailsSidebar({required this.task, required this.column});

  final KanbanTask task;
  final KanbanColumn column;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataTile(
            label: 'Assignee',
            icon: Icons.person_outline_rounded,
            value: task.assignee,
            avatarText: task.assignee.characters.first.toUpperCase(),
          ),
          const SizedBox(height: 16),
          _MetadataTile(
            label: 'Due Date',
            icon: Icons.calendar_today_rounded,
            value: task.dueDate,
            accentColor: const Color(0xFFBA1A1A),
          ),
          const SizedBox(height: 16),
          _MetadataTile(
            label: 'Priority',
            icon: Icons.keyboard_double_arrow_up_rounded,
            value: task.priority.label,
            accentColor: task.priority.foreground,
          ),
          const SizedBox(height: 16),
          _MetadataTile(
            label: 'Status',
            icon: Icons.circle,
            value: column.label,
            accentColor: column.color,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            height: 26 / 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SurfacePanel extends StatelessWidget {
  const _SurfacePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDCC6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFB786)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF723600),
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.initials,
    required this.author,
    required this.time,
    required this.message,
  });

  final String initials;
  final String author;
  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFD0E1FB),
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    author,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.outline,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _SurfacePanel(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Text(
            'Y',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const TextField(
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(hintText: 'Write a comment...'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetadataTile extends StatelessWidget {
  const _MetadataTile({
    required this.label,
    required this.icon,
    required this.value,
    this.accentColor,
    this.avatarText,
  });

  final String label;
  final IconData icon;
  final String value;
  final Color? accentColor;
  final String? avatarText;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.outline,
            fontSize: 11,
            height: 14 / 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              if (avatarText != null)
                CircleAvatar(
                  radius: 13,
                  backgroundColor: const Color(0xFFD0E1FB),
                  child: Text(
                    avatarText!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color == const Color(0xFFBA1A1A)
                        ? color
                        : AppColors.onSurface,
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
