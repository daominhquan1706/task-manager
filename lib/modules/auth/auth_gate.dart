import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import 'auth_controller.dart';

class AuthGate extends GetView<AuthController> {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(
          user == null ? AppRouteNames.login : AppRouteNames.projects,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    });
  }
}
