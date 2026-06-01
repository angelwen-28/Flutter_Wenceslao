import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wenceslao/main.dart';
import 'package:wenceslao/provider/app_state_provider.dart';

void main() {
  testWidgets('App loads and displays LoginScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame with provider injected.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const MyApp(),
      ),
    );

    // Wait for the fade-in animation and mock DB async delay (300ms) to settle
    await tester.pumpAndSettle();

    // Verify that the login screen header is displayed
    expect(find.text('ScoreRecord'), findsOneWidget);
    expect(find.text('Student Login'), findsOneWidget);
    
    // Verify that the login input field exists
    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
    
    // Verify that the email input field exists
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });
}

