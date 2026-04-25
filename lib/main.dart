import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home});

  final Widget? home;

  static const _primary = Color(0xFF0058BE);
  static const _surface = Color(0xFFF9F9FF);
  static const _surfaceContainer = Color(0xFFFFFFFF);
  static const _onSurface = Color(0xFF191B23);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KanbanPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: _surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          primary: _primary,
          surface: _surface,
          onSurface: _onSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC2C6D6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC2C6D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.4),
          ),
          labelStyle: const TextStyle(
            color: _onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(color: Color(0xFF727785), fontSize: 14),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      home: home ?? const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return HomeScreen(user: user);
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      _showMessage(_messageFromAuthException(error));
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyPersistence() async {
    if (!kIsWeb) {
      return;
    }

    await FirebaseAuth.instance.setPersistence(
      _rememberMe ? Persistence.LOCAL : Persistence.SESSION,
    );
  }

  Future<void> _loginWithEmail() {
    return _runAuthAction(() async {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        _showMessage('Enter both email and password.');
        return;
      }

      await _applyPersistence();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> _registerWithEmail() {
    return _runAuthAction(() async {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        _showMessage('Enter an email and password to create an account.');
        return;
      }

      await _applyPersistence();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> _resetPassword() {
    return _runAuthAction(() async {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _showMessage('Enter your email address first.');
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent.');
    });
  }

  Future<void> _loginWithGoogle() {
    return _runAuthAction(() async {
      await _applyPersistence();

      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
        return;
      }

      await FirebaseAuth.instance.signInWithProvider(provider);
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
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
                  border: Border.all(color: const Color(0xFFE1E2EC)),
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
                      const _LoginHeader(),
                      const SizedBox(height: 32),
                      _LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        rememberMe: _rememberMe,
                        isLoading: _isLoading,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        onRememberChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        onForgotPassword: _resetPassword,
                        onLogin: _loginWithEmail,
                        onGoogleLogin: _loginWithGoogle,
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFECEEF7), height: 1),
                      const SizedBox(height: 16),
                      _RegisterPrompt(
                        isLoading: _isLoading,
                        onRegister: _registerWithEmail,
                      ),
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2170E4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.view_kanban_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome back',
          style: TextStyle(
            color: Color(0xFF191B23),
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your credentials to access your workspace.',
          style: TextStyle(
            color: Color(0xFF424754),
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onGoogleLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldLabel('Email address'),
          const SizedBox(height: 4),
          TextField(
            key: const ValueKey('emailField'),
            controller: emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(hintText: 'name@company.com'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: _FieldLabel('Password')),
              TextButton(
                onPressed: isLoading ? null : onForgotPassword,
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
          TextField(
            key: const ValueKey('passwordField'),
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onLogin(),
            decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: isLoading ? null : onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF727785),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: rememberMe,
            onChanged: isLoading ? null : onRememberChanged,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            activeColor: const Color(0xFF0058BE),
            title: const Text(
              'Remember me',
              style: TextStyle(
                color: Color(0xFF424754),
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Login'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onGoogleLogin,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF191B23),
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: Color(0xFFC2C6D6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
        color: Color(0xFF191B23),
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.isLoading, required this.onRegister});

  final bool isLoading;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
            color: Color(0xFF424754),
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onRegister,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Register'),
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final email = user.email ?? 'Signed in user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('KanbanPro'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF0058BE),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Signed in as $email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF191B23),
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Firebase Authentication is connected for this web app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF424754),
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
