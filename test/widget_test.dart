import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestsplit_app/app.dart';
import 'package:nestsplit_app/data/repositories/mock_app_repository.dart';
import 'package:nestsplit_app/state/app_services.dart';

Future<AppServices> _start(WidgetTester tester) async {
  final services = AppServices(MockAppRepository());
  await services.loadAll();
  await tester.pumpWidget(NestSplitApp(services: services));
  return services;
}

Future<void> _signIn(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty form shows errors and stays on login', (tester) async {
    await _start(tester);
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('wrong password is rejected', (tester) async {
    await _start(tester);
    await _signIn(tester, 'ben@nestsplit.test', 'wrongpass1');
    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Hi, Ben'), findsNothing);
  });

  testWidgets('tenant signs in with email and password', (tester) async {
    await _start(tester);
    await _signIn(tester, 'ben@nestsplit.test', 'Nest1234');
    expect(find.text('Hi, Ben'), findsOneWidget);
  });

  testWidgets('landlord signs in and sees the dashboard', (tester) async {
    await _start(tester);
    await _signIn(tester, 'landlord@nestsplit.test', 'Nest1234');
    expect(find.text('Room 2 rent is late'), findsOneWidget);
  });

  testWidgets('profile tab shows the account and logs out', (tester) async {
    await _start(tester);
    await _signIn(tester, 'ben@nestsplit.test', 'Nest1234');
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('ben@nestsplit.test'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
  });
}
