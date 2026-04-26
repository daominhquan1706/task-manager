import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'projects_controller.dart';
import 'widgets/project_dashboard.dart';
import 'widgets/workspace_shell.dart';

class ProjectsScreen extends GetView<ProjectsController> {
  const ProjectsScreen({super.key});

  ProjectsController get c {
    if (Get.isRegistered<ProjectsController>()) {
      return Get.find<ProjectsController>();
    }
    return Get.put(ProjectsController(Get.find(), Get.find()));
  }

  @override
  Widget build(BuildContext context) {
    final controller = c;
    return Obx(() {
      return WorkspaceShell(
        email: controller.email,
        workspaceName: controller.workspaceName,
        searchController: controller.searchController,
        searchHint: 'Search projects...',
        count: controller.projects.length,
        countLabel: 'active projects',
        primaryActionLabel: 'Create Project',
        onPrimaryAction: controller.showProjectDialog,
        onSignOut: controller.signOut,
        child: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ProjectDashboard(
                projects: controller.filteredProjects,
                onCreateProject: controller.showProjectDialog,
                onOpenProject: controller.openProject,
              ),
      );
    });
  }
}
