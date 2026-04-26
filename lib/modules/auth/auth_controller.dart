import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;
  final user = Rxn<User>();
  StreamSubscription<User?>? _subscription;

  @override
  void onInit() {
    super.onInit();
    user.value = _authRepository.currentUser;
    _subscription = _authRepository.authStateChanges().listen(user.call);
  }

  Future<void> signOut() => _authRepository.signOut();

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
