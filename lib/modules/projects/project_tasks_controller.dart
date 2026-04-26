import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import '../../data/models/kanban_column.dart';
import '../../data/models/kanban_project.dart';
import '../../data/models/kanban_task.dart';
import '../../data/models/task_draft.dart';
import '../../data/models/task_enums.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/task_repository.dart';
import 'widgets/task_dialog.dart';

class ProjectTasksController extends GetxController {
  ProjectTasksController(
    this._taskRepository,
    this._projectRepository,
    this._authRepository,
    this.projectId, {
    KanbanProject? initialProject,
  }) {
    project.value = initialProject;
  }

  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final AuthRepository _authRepository;
  final String projectId;

  final searchController = TextEditingController();
  final project = Rxn<KanbanProject>();
  final tasks = <KanbanTask>[].obs;
  final query = ''.obs;
  final isLoading = true.obs;
  final isProjectLoading = true.obs;

  String get email => _authRepository.currentUser?.email ?? 'Signed in user';
  String get workspaceName => email.split('@').first;

  List<KanbanTask> get filteredTasks {
    final normalizedQuery = query.value.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return tasks;
    }
    return tasks.where((task) {
      return task.title.toLowerCase().contains(normalizedQuery) ||
          task.assignee.toLowerCase().contains(normalizedQuery) ||
          task.priority.label.toLowerCase().contains(normalizedQuery) ||
          _columnLabel(task.statusId).toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  List<KanbanColumn> get columns =>
      project.value?.columns ?? KanbanColumn.defaults();

  @override
  void onInit() {
    super.onInit();
    project.bindStream(_projectRepository.watchProject(projectId));
    tasks.bindStream(_taskRepository.watchTasks());
    searchController.addListener(() => query.value = searchController.text);
    ever<KanbanProject?>(project, (_) => isProjectLoading.value = false);
    ever<List<KanbanTask>>(tasks, (_) => isLoading.value = false);
  }

  Future<void> showTaskDialog({String? initialStatusId}) async {
    final draft = await Get.dialog<TaskDraft>(
      TaskDialog(
        columns: columns,
        initialStatusId: initialStatusId ?? columns.first.id,
      ),
    );
    if (draft == null) {
      return;
    }
    await _taskRepository.createTask(draft);
  }

  Future<void> createInlineTask({
    required String title,
    required KanbanColumn column,
  }) {
    return _taskRepository.createTask(
      TaskDraft(
        title: title,
        statusId: column.id,
        priority: TaskPriority.medium,
        dueDate: 'No date',
        assignee: 'Unassigned',
      ),
    );
  }

  Future<void> updateStatus(KanbanTask task, KanbanColumn column) {
    return _taskRepository.updateStatus(task, column.id);
  }

  Future<void> reorderTask({
    required KanbanTask task,
    required KanbanColumn column,
    required int index,
  }) {
    final statusTasks =
        tasks.where((candidate) => candidate.statusId == column.id).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    final reorderedTasks = statusTasks
        .where((candidate) => candidate.id != task.id)
        .toList();
    final safeIndex = index.clamp(0, reorderedTasks.length);
    reorderedTasks.insert(safeIndex, task);
    return _taskRepository.updateTaskPlacement(
      statusId: column.id,
      orderedTasks: reorderedTasks,
    );
  }

  Future<void> showColumnDialog() async {
    final textController = TextEditingController();
    final label = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Create column'),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Column name'),
            onSubmitted: (value) => Get.back(result: value.trim()),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: textController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (label == null || label.isEmpty) {
      return;
    }
    final normalized = label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final column = KanbanColumn(
      id: '${normalized.isEmpty ? 'column' : normalized}-${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      color: _nextColumnColor(),
      order: (columns.length + 1) * 1000,
    );
    await _projectRepository.addColumn(projectId, column);
  }

  Future<void> reorderColumn({
    required KanbanColumn column,
    required int index,
  }) {
    final reorderedColumns = [...columns];
    final fromIndex = reorderedColumns.indexWhere(
      (candidate) => candidate.id == column.id,
    );
    if (fromIndex == -1) {
      return Future.value();
    }
    reorderedColumns.removeAt(fromIndex);
    final adjustedIndex = fromIndex < index ? index - 1 : index;
    final safeIndex = adjustedIndex.clamp(0, reorderedColumns.length);
    reorderedColumns.insert(safeIndex, column);
    return _projectRepository.updateColumns(projectId, reorderedColumns);
  }

  String _columnLabel(String statusId) {
    return columns
        .firstWhere(
          (column) => column.id == statusId,
          orElse: () => columns.first,
        )
        .label;
  }

  Color _nextColumnColor() {
    const colors = [
      Color(0xFF7C3AED),
      Color(0xFF0891B2),
      Color(0xFFBE123C),
      Color(0xFF4D7C0F),
      Color(0xFF9333EA),
      Color(0xFF0F766E),
    ];
    return colors[columns.length % colors.length];
  }

  Future<void> deleteTask(KanbanTask task) {
    return _taskRepository.deleteTask(task);
  }

  void backToProjects() => Get.offNamed(AppRouteNames.projects);

  Future<void> signOut() async {
    await _authRepository.signOut();
    Get.offAllNamed(AppRouteNames.login);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
