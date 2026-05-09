import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_theme.dart';
import 'package:isango_app/screens/auth/sign_in_screen.dart';

Widget _wrap(Widget child, {Map<String, WidgetBuilder>? routes}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: child,
    routes: routes ?? const {},
  );
}

void main() {
  group('SignInScreen', () {
    testWidgets('shows inline validation errors when submitted empty',
        (tester) async {
      await tester.pumpWidget(_wrap(const SignInScreen()));

      await tester.tap(find.byKey(const Key('signInSubmit')));
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('shows inline error for malformed email', (tester) async {
      await tester.pumpWidget(_wrap(const SignInScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.tap(find.byKey(const Key('signInSubmit')));
      await tester.pump();

      expect(
        find.text('Please enter a valid university email address'),
        findsOneWidget,
      );
    });

    testWidgets('navigates to /signup when "Create one" is tapped',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SignInScreen(),
          routes: {
            AppRoutes.signUp: (_) =>
                const Scaffold(body: Text('signup-route-loaded')),
          },
        ),
      );

      await tester.tap(find.byKey(const Key('goToSignUp')));
      await tester.pumpAndSettle();

      expect(find.text('signup-route-loaded'), findsOneWidget);
    });

    testWidgets('shows loading spinner and disables CTA while submitting',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        _wrap(
          SignInScreen(
            onSubmit: (email, password) => completer.future,
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@ur.ac.rw',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'secret123',
      );
      await tester.tap(find.byKey(const Key('signInSubmit')));
      await tester.pump();

      expect(find.byKey(const Key('signInLoading')), findsOneWidget);

      final button =
          tester.widget<FilledButton>(find.byKey(const Key('signInSubmit')));
      expect(button.onPressed, isNull);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows submission error banner when sign-in fails',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SignInScreen(
            onSubmit: (email, password) async => throw Exception('bad creds'),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@ur.ac.rw',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'secret123',
      );
      await tester.tap(find.byKey(const Key('signInSubmit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('signInError')), findsOneWidget);
      expect(
        find.text(
          'We could not sign you in. Check your details and try again.',
        ),
        findsOneWidget,
      );
    });
  });
}
