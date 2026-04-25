import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/main.dart';

void main() {
  testWidgets('shows KanbanPro login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Enter your credentials to access your workspace.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.view_kanban_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('emailField')), findsOneWidget);
    expect(find.byKey(const ValueKey('passwordField')), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: LoginScreen()));

    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
