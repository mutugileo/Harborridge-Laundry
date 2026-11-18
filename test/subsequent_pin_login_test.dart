import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth_backend.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Subsequent 4-Digit PIN Login Tests', () {
    testWidgets(
      'Initial login asks for email & password, subsequent login asks ONLY for 4-digit PIN',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await pumpTestApp(tester);

        // 1. Initial Login: shows email & password form
        expect(find.byKey(const ValueKey('login_email_input')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('login_password_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('subsequent_pin_form_view')),
          findsNothing,
        );

        // Sign in as Test Admin
        await signInThroughForm(tester);
        expect(find.text('Operations Overview'), findsOneWidget);

        // 2. Staff logs out
        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();

        // 3. Subsequent Login: ONLY asks for 4-digit PIN!
        expect(
          find.byKey(const ValueKey('subsequent_pin_form_view')),
          findsOneWidget,
        );
        expect(find.text('QUICK STAFF UNLOCK'), findsOneWidget);
        expect(find.text('Test Admin'), findsOneWidget);
        expect(find.text('Enter 4-Digit Security PIN'), findsOneWidget);
        expect(find.byKey(const ValueKey('login_pin_input')), findsOneWidget);
        expect(find.byKey(const ValueKey('login_email_input')), findsNothing);
        expect(
          find.byKey(const ValueKey('login_password_input')),
          findsNothing,
        );

        // 4. Test wrong PIN rejection
        await tester.enterText(
          find.byKey(const ValueKey('login_pin_input')),
          '9999',
        );
        await tester.tap(find.byKey(const ValueKey('login_pin_submit_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Incorrect 4-digit PIN. Try again.'), findsOneWidget);
        expect(find.text('Operations Overview'), findsNothing);

        // 5. Test correct PIN (default: 1234) unlocks terminal
        await tester.enterText(
          find.byKey(const ValueKey('login_pin_input')),
          '1234',
        );
        await tester.tap(find.byKey(const ValueKey('login_pin_submit_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Operations Overview'), findsOneWidget);
      },
    );

    testWidgets('Touch keypad enters 4 digits and auto-submits on 4th digit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await pumpTestApp(tester);
      await signInThroughForm(tester);

      await tester.tap(find.text('Logout'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.byKey(const ValueKey('subsequent_pin_form_view')),
        findsOneWidget,
      );

      // Tap on-screen keypad numbers: 1, 2, 3, 4
      await tester.tap(find.text('1').last);
      await tester.pump();
      await tester.tap(find.text('2').last);
      await tester.pump();
      await tester.tap(find.text('3').last);
      await tester.pump();
      await tester.tap(find.text('4').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Operations Overview'), findsOneWidget);
    });

    testWidgets(
      'Staff can switch between 4-digit PIN unlock and Email/Password mode',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await pumpTestApp(tester);
        await signInThroughForm(tester);

        await tester.tap(find.text('Logout'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.byKey(const ValueKey('subsequent_pin_form_view')),
          findsOneWidget,
        );

        // Switch to Email
        await tester.tap(
          find.byKey(const ValueKey('switch_to_email_login_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login_email_input')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('login_password_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('subsequent_pin_form_view')),
          findsNothing,
        );

        // Switch back to PIN
        await tester.tap(
          find.byKey(const ValueKey('switch_to_pin_login_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('subsequent_pin_form_view')),
          findsOneWidget,
        );
      },
    );
  });
}
