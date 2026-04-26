import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.registerMode = false});

  final bool registerMode;

  LoginController get controller {
    if (Get.isRegistered<LoginController>()) {
      return Get.find<LoginController>();
    }
    if (!Get.isRegistered<AuthRepository>()) {
      return Get.put(LoginController(null));
    }
    return Get.put(LoginController(Get.find<AuthRepository>()));
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    c.applyInitialMode(registerMode: registerMode);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthHeader(controller: c),
                      const SizedBox(height: 32),
                      _AuthForm(controller: c),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFECEEF7), height: 1),
                      const SizedBox(height: 16),
                      _AuthModePrompt(controller: c),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRegisterMode = controller.isRegisterMode.value;
      return Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRegisterMode ? 'Join KanbanPro' : 'Welcome back',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 30,
              height: 38 / 30,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isRegisterMode
                ? 'Create your account to start managing tasks efficiently.'
                : 'Enter your credentials to access your workspace.',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 20 / 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final isRegisterMode = controller.isRegisterMode.value;
        final obscurePassword = controller.obscurePassword.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isRegisterMode) ...[
              const _FieldLabel('Full Name'),
              const SizedBox(height: 4),
              _AuthTextField(
                key: const ValueKey('fullNameField'),
                controller: controller.fullNameController,
                enabled: !isLoading,
                hintText: 'Jane Doe',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 16),
            ],
            const _FieldLabel('Email address'),
            const SizedBox(height: 4),
            _AuthTextField(
              key: const ValueKey('emailField'),
              controller: controller.emailController,
              enabled: !isLoading,
              hintText: isRegisterMode ? 'you@company.com' : 'name@company.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            if (isRegisterMode)
              const _FieldLabel('Password')
            else
              Row(
                children: [
                  const Expanded(child: _FieldLabel('Password')),
                  TextButton(
                    onPressed: isLoading ? null : controller.resetPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            _AuthTextField(
              key: const ValueKey('passwordField'),
              controller: controller.passwordController,
              enabled: !isLoading,
              hintText: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => isRegisterMode
                  ? controller.registerWithEmail()
                  : controller.loginWithEmail(),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: isLoading ? null : controller.togglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.outline,
                ),
              ),
            ),
            if (isRegisterMode) ...[
              const SizedBox(height: 8),
              const Text(
                'Must be at least 8 characters long.',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 11,
                  height: 14 / 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (!isRegisterMode) ...[
              CheckboxListTile(
                value: controller.rememberMe.value,
                onChanged: isLoading ? null : controller.setRememberMe,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                activeColor: AppColors.primary,
                title: const Text(
                  'Remember me',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : isRegisterMode
                  ? controller.registerWithEmail
                  : controller.loginWithEmail,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isRegisterMode ? 'Sign Up' : 'Login'),
            ),
            if (!isRegisterMode) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isLoading ? null : controller.loginWithGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                label: const Text('Continue with Google'),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 14,
        height: 20 / 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _AuthModePrompt extends StatelessWidget {
  const _AuthModePrompt({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isRegisterMode = controller.isRegisterMode.value;
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            isRegisterMode
                ? 'Already have an account?'
                : "Don't have an account?",
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : isRegisterMode
                ? controller.showLogin
                : controller.showRegister,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(isRegisterMode ? 'Log in' : 'Register'),
          ),
        ],
      );
    });
  }
}
