import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'project_tasks_controller.dart';
import 'widgets/board_header.dart';
import 'widgets/kanban_board.dart';
import 'widgets/workspace_shell.dart';

class ProjectTasksScreen extends GetView<ProjectTasksController> {
  const ProjectTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final project = controller.project.value;
      if (controller.isProjectLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (project == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Project not found'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.backToProjects,
                  child: const Text('Back to projects'),
                ),
              ],
            ),
          ),
        );
      }

      return WorkspaceShell(
        email: controller.email,
        workspaceName: controller.workspaceName,
        searchController: controller.searchController,
        searchHint: 'Search tasks...',
        count: controller.tasks.length,
        countLabel: 'active tasks',
        primaryActionLabel: 'Create Task',
        onPrimaryAction: controller.showTaskDialog,
        onSignOut: controller.signOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BoardHeader(
              project: project,
              columns: project.columns,
              tasks: controller.filteredTasks,
              onBack: controller.backToProjects,
              onCreateTask: controller.showTaskDialog,
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : KanbanBoard(
                      columns: project.columns,
                      tasks: controller.filteredTasks,
                      onCreateTask: (column, title) => controller
                          .createInlineTask(title: title, column: column),
                      onAddColumn: controller.showColumnDialog,
                      onReorderColumn: controller.reorderColumn,
                      onMoveTask: controller.updateStatus,
                      onReorderTask: controller.reorderTask,
                      onDeleteTask: controller.deleteTask,
                    ),
            ),
          ],
        ),
      );
    });
  }
}
