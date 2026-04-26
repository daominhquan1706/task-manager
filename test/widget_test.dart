import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/app/app.dart';
import 'package:task_manager/modules/auth/login_screen.dart';

void main() {
  testWidgets('shows KanbanPro login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Enter your credentials to access your workspace.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('emailField')), findsOneWidget);
    expect(find.byKey(const ValueKey('passwordField')), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('shows Stitch-inspired register form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen(registerMode: true)));

    expect(find.text('Join KanbanPro'), findsOneWidget);
    expect(
      find.text('Create your account to start managing tasks efficiently.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('fullNameField')), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Must be at least 8 characters long.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
