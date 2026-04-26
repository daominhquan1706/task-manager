import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/kanban_project.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/task_repository.dart';
import '../modules/auth/auth_gate.dart';
import '../modules/auth/login_controller.dart';
import '../modules/auth/login_screen.dart';
import '../modules/projects/project_tasks_controller.dart';
import '../modules/projects/project_tasks_screen.dart';
import '../modules/projects/projects_controller.dart';
import '../modules/projects/projects_screen.dart';

class AppRouteNames {
  static const root = '/';
  static const login = '/login';
  static const register = '/register';
  static const projects = '/project';
  static const legacyProjects = '/projects';
  static const projectTasks = '/project/:projectId';

  static String projectTasksPath(String projectId) => '/project/$projectId';
}

class AppRoutes {
  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => const _NotFoundScreen(),
  );

  static final pages = [
    GetPage(name: AppRouteNames.root, page: () => const AuthGate()),
    GetPage(
      name: AppRouteNames.login,
      page: () => const LoginScreen(),
      middlewares: [_LoginMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
      }),
    ),
    GetPage(
      name: AppRouteNames.register,
      page: () => const LoginScreen(registerMode: true),
      middlewares: [_LoginMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
      }),
    ),
    GetPage(
      name: AppRouteNames.projects,
      page: () => const ProjectsScreen(),
      middlewares: [_AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProjectRepository(Get.find<AuthRepository>()));
        Get.lazyPut(
          () => ProjectsController(
            Get.find<ProjectRepository>(),
            Get.find<AuthRepository>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRouteNames.legacyProjects,
      page: () => const ProjectsScreen(),
      middlewares: [
        _AuthMiddleware(),
        _RedirectMiddleware(AppRouteNames.projects),
      ],
    ),
    GetPage(
      name: AppRouteNames.projectTasks,
      page: () => const ProjectTasksScreen(),
      middlewares: [_AuthMiddleware()],
      binding: BindingsBuilder(() {
        final projectId = Get.parameters['projectId']!;
        final project = Get.arguments is KanbanProject
            ? Get.arguments as KanbanProject
            : null;
        Get.lazyPut(() => ProjectRepository(Get.find<AuthRepository>()));
        Get.lazyPut(
          () => TaskRepository(Get.find<AuthRepository>(), projectId),
        );
        Get.lazyPut(
          () => ProjectTasksController(
            Get.find<TaskRepository>(),
            Get.find<ProjectRepository>(),
            Get.find<AuthRepository>(),
            projectId,
            initialProject: project,
          ),
        );
      }),
    ),
  ];
}

class _AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const RouteSettings(name: AppRouteNames.login);
    }
    return null;
  }
}

class _LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (FirebaseAuth.instance.currentUser != null) {
      return const RouteSettings(name: AppRouteNames.projects);
    }
    return null;
  }
}

class _RedirectMiddleware extends GetMiddleware {
  _RedirectMiddleware(this.target);

  final String target;

  @override
  RouteSettings? redirect(String? route) => RouteSettings(name: target);
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed(AppRouteNames.root),
          child: const Text('Back to KanbanPro'),
        ),
      ),
    );
  }
}
