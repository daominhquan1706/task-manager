import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/kanban_column.dart';
import '../../../data/models/kanban_task.dart';
import '../../../data/models/task_enums.dart';
import 'task_details_dialog.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({
    required this.columns,
    required this.tasks,
    required this.onCreateTask,
    required this.onAddColumn,
    required this.onReorderColumn,
    required this.onMoveTask,
    required this.onReorderTask,
    required this.onDeleteTask,
    super.key,
  });

  final List<KanbanColumn> columns;
  final List<KanbanTask> tasks;
  final Future<void> Function(KanbanColumn column, String title) onCreateTask;
  final VoidCallback onAddColumn;
  final void Function({required KanbanColumn column, required int index})
  onReorderColumn;
  final void Function(KanbanTask task, KanbanColumn column) onMoveTask;
  final void Function({
    required KanbanTask task,
    required KanbanColumn column,
    required int index,
  })
  onReorderTask;
  final ValueChanged<KanbanTask> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index <= columns.length; index++) ...[
              _ColumnDropZone(index: index, onAccept: onReorderColumn),
              if (index < columns.length)
                _KanbanColumn(
                  column: columns[index],
                  columns: columns,
                  tasks:
                      (tasks
                          .where((task) => task.statusId == columns[index].id)
                          .toList()
                        ..sort((a, b) => a.order.compareTo(b.order))),
                  onCreateTask: onCreateTask,
                  onMoveTask: onMoveTask,
                  onReorderTask: onReorderTask,
                  onDeleteTask: onDeleteTask,
                ),
              const SizedBox(width: 24),
            ],
            _AddColumnCard(onAddColumn: onAddColumn),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends StatefulWidget {
  const _KanbanColumn({
    required this.column,
    required this.columns,
    required this.tasks,
    required this.onCreateTask,
    required this.onMoveTask,
    required this.onReorderTask,
    required this.onDeleteTask,
  });

  final KanbanColumn column;
  final List<KanbanColumn> columns;
  final List<KanbanTask> tasks;
  final Future<void> Function(KanbanColumn column, String title) onCreateTask;
  final void Function(KanbanTask task, KanbanColumn column) onMoveTask;
  final void Function({
    required KanbanTask task,
    required KanbanColumn column,
    required int index,
  })
  onReorderTask;
  final ValueChanged<KanbanTask> onDeleteTask;

  @override
  State<_KanbanColumn> createState() => _KanbanColumnState();
}

class _ColumnDropZone extends StatelessWidget {
  const _ColumnDropZone({required this.index, required this.onAccept});

  final int index;
  final void Function({required KanbanColumn column, required int index})
  onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<KanbanColumn>(
      hitTestBehavior: HitTestBehavior.translucent,
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        onAccept(column: details.data, index: index);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: isActive ? 320 : 12,
          height: 520,
          margin: EdgeInsets.only(right: isActive ? 24 : 0),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.32))
                : null,
          ),
          child: isActive
              ? Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.column, required this.taskCount});

  final KanbanColumn column;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: AppColors.outline,
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: column.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              column.label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                height: 26 / 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _CountChip(count: taskCount),
        ],
      ),
    );
  }
}

class _KanbanColumnState extends State<_KanbanColumn> {
  final _taskKeys = <String, GlobalKey>{};
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  KanbanTask? _previewTask;
  int? _previewIndex;
  bool _isComposing = false;
  bool _showTitleError = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _KanbanColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final taskIds = widget.tasks.map((task) => task.id).toSet();
    _taskKeys.removeWhere((id, key) => !taskIds.contains(id));
  }

  void _updatePreview(DragTargetDetails<KanbanTask> details) {
    final visibleTasks = _visibleTasks(details.data);
    final nextIndex = _indexForOffset(details.offset, visibleTasks);
    if (_previewTask?.id == details.data.id && _previewIndex == nextIndex) {
      return;
    }
    setState(() {
      _previewTask = details.data;
      _previewIndex = nextIndex;
    });
  }

  int _indexForOffset(Offset globalOffset, List<KanbanTask> visibleTasks) {
    for (var index = 0; index < visibleTasks.length; index++) {
      final context = _taskKeys[visibleTasks[index].id]?.currentContext;
      final renderBox = context?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        continue;
      }
      final topLeft = renderBox.localToGlobal(Offset.zero);
      final middleY = topLeft.dy + renderBox.size.height / 2;
      if (globalOffset.dy < middleY) {
        return index;
      }
    }
    return visibleTasks.length;
  }

  List<KanbanTask> _visibleTasks(KanbanTask? draggingTask) {
    if (draggingTask == null) {
      return widget.tasks;
    }
    return widget.tasks
        .where((task) => task.id != draggingTask.id)
        .toList(growable: false);
  }

  void _clearPreview() {
    if (_previewTask == null && _previewIndex == null) {
      return;
    }
    setState(() {
      _previewTask = null;
      _previewIndex = null;
    });
  }

  void _openComposer() {
    setState(() {
      _isComposing = true;
      _showTitleError = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  void _closeComposer() {
    setState(() {
      _isComposing = false;
      _showTitleError = false;
      _isCreating = false;
      _titleController.clear();
    });
  }

  Future<void> _submitComposer() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _showTitleError = true);
      _titleFocusNode.requestFocus();
      return;
    }
    setState(() => _isCreating = true);
    await widget.onCreateTask(widget.column, title);
    if (!mounted) {
      return;
    }
    _closeComposer();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _visibleTasks(_previewTask);
    final previewIndex = _previewIndex?.clamp(0, visibleTasks.length);

    return SizedBox(
      width: 320,
      child: Container(
        constraints: const BoxConstraints(minHeight: 520),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          children: [
            Draggable<KanbanColumn>(
              data: widget.column,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 320,
                  child: Opacity(
                    opacity: 0.92,
                    child: _ColumnHeader(
                      column: widget.column,
                      taskCount: widget.tasks.length,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _ColumnHeader(
                  column: widget.column,
                  taskCount: widget.tasks.length,
                ),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: _ColumnHeader(
                  column: widget.column,
                  taskCount: widget.tasks.length,
                ),
              ),
            ),
            DragTarget<KanbanTask>(
              hitTestBehavior: HitTestBehavior.translucent,
              onWillAcceptWithDetails: (details) {
                _updatePreview(details);
                return true;
              },
              onMove: _updatePreview,
              onLeave: (_) => _clearPreview(),
              onAcceptWithDetails: (details) {
                final index =
                    previewIndex ??
                    _indexForOffset(
                      details.offset,
                      _visibleTasks(details.data),
                    );
                widget.onReorderTask(
                  task: details.data,
                  column: widget.column,
                  index: index,
                );
                _clearPreview();
              },
              builder: (context, candidateData, rejectedData) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 430),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index <= visibleTasks.length;
                          index++
                        ) ...[
                          if (previewIndex == index)
                            _DropPreview(
                              task: _previewTask!,
                              columns: widget.columns,
                              onMoveTask: widget.onMoveTask,
                              onDeleteTask: widget.onDeleteTask,
                              onOpenTask: null,
                            ),
                          if (index < visibleTasks.length) ...[
                            Builder(
                              builder: (context) {
                                final task = visibleTasks[index];
                                return _DraggableTaskCard(
                                  key: _taskKeys.putIfAbsent(
                                    task.id,
                                    GlobalKey.new,
                                  ),
                                  task: task,
                                  columns: widget.columns,
                                  onMoveTask: widget.onMoveTask,
                                  onDeleteTask: widget.onDeleteTask,
                                  onOpenTask: () {
                                    showDialog<void>(
                                      context: context,
                                      barrierColor: AppColors.onSurface
                                          .withValues(alpha: 0.4),
                                      builder: (_) => TaskDetailsDialog(
                                        task: task,
                                        columns: widget.columns,
                                        onDeleteTask: widget.onDeleteTask,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                        if (_isComposing)
                          _InlineTaskComposer(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            showTitleError: _showTitleError,
                            isCreating: _isCreating,
                            onTitleChanged: () {
                              if (_showTitleError) {
                                setState(() => _showTitleError = false);
                              }
                            },
                            onCancel: _closeComposer,
                            onCreate: _submitComposer,
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _openComposer,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Task'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(132, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                side: const BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                      ],
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

class _DropPreview extends StatelessWidget {
  const _DropPreview({
    required this.task,
    required this.columns,
    required this.onMoveTask,
    required this.onDeleteTask,
    required this.onOpenTask,
  });

  final KanbanTask task;
  final List<KanbanColumn> columns;
  final void Function(KanbanTask task, KanbanColumn column) onMoveTask;
  final ValueChanged<KanbanTask> onDeleteTask;
  final VoidCallback? onOpenTask;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.38,
          child: _TaskCard(
            task: task,
            columns: columns,
            onMoveTask: onMoveTask,
            onDeleteTask: onDeleteTask,
            onOpenTask: onOpenTask,
          ),
        ),
      ),
    );
  }
}

class _InlineTaskComposer extends StatelessWidget {
  const _InlineTaskComposer({
    required this.controller,
    required this.focusNode,
    required this.showTitleError,
    required this.isCreating,
    required this.onTitleChanged,
    required this.onCancel,
    required this.onCreate,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showTitleError;
  final bool isCreating;
  final VoidCallback onTitleChanged;
  final VoidCallback onCancel;
  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: showTitleError ? Colors.redAccent : AppColors.surfaceVariant,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isCreating,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onCreate(),
            onChanged: (_) => onTitleChanged(),
            decoration: InputDecoration(
              hintText: 'Task title',
              isDense: true,
              errorText: showTitleError ? 'Title is required' : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isCreating ? null : onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isCreating ? null : onCreate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddColumnCard extends StatelessWidget {
  const _AddColumnCard({required this.onAddColumn});

  final VoidCallback onAddColumn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Material(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onAddColumn,
          child: Container(
            height: 96,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Add Column',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _DraggableTaskCard extends StatelessWidget {
  const _DraggableTaskCard({
    required this.task,
    required this.columns,
    required this.onMoveTask,
    required this.onDeleteTask,
    required this.onOpenTask,
    super.key,
  });

  final KanbanTask task;
  final List<KanbanColumn> columns;
  final void Function(KanbanTask task, KanbanColumn column) onMoveTask;
  final ValueChanged<KanbanTask> onDeleteTask;
  final VoidCallback? onOpenTask;

  @override
  Widget build(BuildContext context) {
    final card = _TaskCard(
      task: task,
      columns: columns,
      onMoveTask: onMoveTask,
      onDeleteTask: onDeleteTask,
      onOpenTask: onOpenTask,
    );

    return Draggable<KanbanTask>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 292, child: Opacity(opacity: 0.92, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: card),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.columns,
    required this.onMoveTask,
    required this.onDeleteTask,
    this.onOpenTask,
  });

  final KanbanTask task;
  final List<KanbanColumn> columns;
  final void Function(KanbanTask task, KanbanColumn column) onMoveTask;
  final ValueChanged<KanbanTask> onDeleteTask;
  final VoidCallback? onOpenTask;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onOpenTask,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: task.statusId == TaskStatus.inProgress.name
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.surfaceVariant,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PriorityChip(priority: task.priority),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: 'Task actions',
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.outline,
                    ),
                    itemBuilder: (context) => [
                      for (final column in columns)
                        PopupMenuItem(
                          value: column.id,
                          child: Text('Move to ${column.label}'),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDeleteTask(task);
                        return;
                      }
                      final column = columns.firstWhere(
                        (candidate) => candidate.id == value,
                        orElse: () => columns.first,
                      );
                      onMoveTask(task, column);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: AppColors.surfaceVariant),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.dueDate,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: task.assignee,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFFD0E1FB),
                      child: Text(
                        task.assignee.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: priority.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: priority.foreground,
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
