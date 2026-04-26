import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  LoginController(this._authRepository);

  final AuthRepository? _authRepository;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isRegisterMode = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = true.obs;
  final isLoading = false.obs;
  bool? _appliedRouteMode;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void applyInitialMode({required bool registerMode}) {
    if (_appliedRouteMode == registerMode) {
      return;
    }
    isRegisterMode.value = registerMode;
    _appliedRouteMode = registerMode;
  }

  void showRegister() => isRegisterMode.value = true;

  void showLogin() => isRegisterMode.value = false;

  void togglePassword() => obscurePassword.toggle();

  void setRememberMe(bool? value) => rememberMe.value = value ?? false;

  Future<void> loginWithEmail() {
    return _runAuthAction(() async {
      final authRepository = _authRepository;
      if (authRepository == null) {
        return;
      }
      final email = emailController.text.trim();
      final password = passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        _showMessage('Enter both email and password.');
        return;
      }

      await authRepository.signInWithEmail(
        email: email,
        password: password,
        rememberMe: rememberMe.value,
      );
      Get.offAllNamed(AppRouteNames.projects);
    });
  }

  Future<void> registerWithEmail() {
    return _runAuthAction(() async {
      final authRepository = _authRepository;
      if (authRepository == null) {
        return;
      }
      final displayName = fullNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      if (displayName.isEmpty || email.isEmpty || password.isEmpty) {
        _showMessage('Enter your name, email, and password.');
        return;
      }
      if (password.length < 8) {
        _showMessage('Password must be at least 8 characters.');
        return;
      }

      await authRepository.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        rememberMe: rememberMe.value,
      );
      Get.offAllNamed(AppRouteNames.projects);
    });
  }

  Future<void> resetPassword() {
    return _runAuthAction(() async {
      final authRepository = _authRepository;
      if (authRepository == null) {
        return;
      }
      final email = emailController.text.trim();
      if (email.isEmpty) {
        _showMessage('Enter your email address first.');
        return;
      }

      await authRepository.sendPasswordResetEmail(email);
      _showMessage('Password reset email sent.');
    });
  }

  Future<void> loginWithGoogle() {
    return _runAuthAction(() async {
      final authRepository = _authRepository;
      if (authRepository == null) {
        return;
      }
      await authRepository.signInWithGoogle(rememberMe: rememberMe.value);
      Get.offAllNamed(AppRouteNames.projects);
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      _showMessage(_messageFromAuthException(error));
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showMessage(String message) {
    Get.snackbar(
      'KanbanPro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  String _messageFromAuthException(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'Email or password is incorrect.',
      'popup-closed-by-user' => 'Google sign-in was cancelled.',
      'weak-password' => 'Password must be at least 6 characters.',
      'operation-not-allowed' =>
        'Enable this sign-in provider in Firebase Authentication first.',
      'unauthorized-domain' =>
        'Add this domain in Firebase Authentication authorized domains.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
}
