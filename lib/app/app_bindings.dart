import 'package:get/get.dart';

import '../data/repositories/auth_repository.dart';
import '../modules/auth/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository(), permanent: true);
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
  }
}
