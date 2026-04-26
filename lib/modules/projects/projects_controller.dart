import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import '../../data/models/kanban_project.dart';
import '../../data/models/project_draft.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/project_repository.dart';
import 'widgets/project_dialog.dart';

class ProjectsController extends GetxController {
  ProjectsController(this._repository, this._authRepository);

  final ProjectRepository _repository;
  final AuthRepository _authRepository;

  final searchController = TextEditingController();
  final projects = <KanbanProject>[].obs;
  final query = ''.obs;
  final isLoading = true.obs;

  String get email => _authRepository.currentUser?.email ?? 'Signed in user';
  String get workspaceName => email.split('@').first;

  List<KanbanProject> get filteredProjects {
    final normalizedQuery = query.value.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return projects;
    }
    return projects.where((project) {
      return project.name.toLowerCase().contains(normalizedQuery) ||
          project.description.toLowerCase().contains(normalizedQuery) ||
          project.team.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    projects.bindStream(_repository.watchProjects());
    searchController.addListener(() => query.value = searchController.text);
    ever<List<KanbanProject>>(projects, (_) => isLoading.value = false);
  }

  Future<void> showProjectDialog() async {
    final draft = await Get.dialog<ProjectDraft>(const ProjectDialog());
    if (draft == null) {
      return;
    }
    await _repository.createProject(draft);
  }

  void openProject(KanbanProject project) {
    Get.toNamed(AppRouteNames.projectTasksPath(project.id), arguments: project);
  }

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
