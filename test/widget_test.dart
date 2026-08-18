import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jm_hockey/main.dart';

void main() {
  testWidgets('shows onboarding first', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to JM Hockey Academy'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('shows the dashboard after login', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to JM Hockey Academy'), findsOneWidget);
    final publicSignIn = find.widgetWithText(
      ElevatedButton,
      'Member Sign In / Sign Up',
    );
    await tester.ensureVisible(publicSignIn);
    await tester.tap(publicSignIn);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'admin@jmhockey.com');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    final authSignIn = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(authSignIn);
    await tester.pumpAndSettle();

    expect(find.text('Admin control center'), findsOneWidget);
  });
}
