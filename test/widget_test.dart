import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestsplit_app/app.dart';
import 'package:nestsplit_app/data/repositories/mock_app_repository.dart';
import 'package:nestsplit_app/state/app_services.dart';

Future<AppServices> _start(WidgetTester tester, {bool splash = false}) async {
  final services = AppServices(MockAppRepository());
  await services.loadAll();
  await tester.pumpWidget(NestSplitApp(services: services, showSplash: splash));
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

  testWidgets('splash shows name and tagline, then the login screen', (tester) async {
    await _start(tester, splash: true);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('NestSplit'), findsOneWidget);
    expect(find.text('Split the Bill, Share the Load.'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Landlord login'), findsOneWidget);
  });

  testWidgets('tenant door rejects a landlord account', (tester) async {
    await _start(tester);
    await _signIn(tester, 'landlord@nestsplit.test', 'Nest1234');
    expect(find.textContaining('landlord account'), findsOneWidget);
  });

  testWidgets('landlord login opens the dashboard', (tester) async {
    await _start(tester);
    await tester.tap(find.text('Landlord login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'landlord@nestsplit.test');
    await tester.enterText(find.byType(TextField).at(1), 'Nest1234');
    await tester.tap(find.text('Sign in as landlord'));
    await tester.pumpAndSettle();
    expect(find.text('Room 2 rent is late'), findsOneWidget);
  });

  testWidgets('landlord can switch boarding house', (tester) async {
    final services = await _start(tester);
    await tester.tap(find.text('Landlord login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'landlord@nestsplit.test');
    await tester.enterText(find.byType(TextField).at(1), 'Nest1234');
    await tester.tap(find.text('Sign in as landlord'));
    await tester.pumpAndSettle();
    expect(services.property.propertyCount, 3);
    await tester.tap(find.text('Lakbay Boarding House'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mabini Dormitory'));
    await tester.pumpAndSettle();
    expect(find.text('Mabini Dormitory'), findsWidgets);
    expect(services.property.roomCount, 12);
  });

  testWidgets('profile tab shows the account and logs out', (tester) async {
    await _start(tester);
    await _signIn(tester, 'ben@nestsplit.test', 'Nest1234');
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('ben@nestsplit.test'), findsOneWidget);

    // The Log out button is below the fold of the test screen, so scroll to it first.
    await tester.scrollUntilVisible(find.text('Log out'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
  });
}
