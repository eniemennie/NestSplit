import 'package:flutter_test/flutter_test.dart';
import 'package:nestsplit_app/app.dart';
import 'package:nestsplit_app/data/repositories/mock_app_repository.dart';
import 'package:nestsplit_app/state/app_services.dart';

void main() {
  testWidgets('tenant can sign in and see the home screen', (tester) async {
    final services = AppServices(MockAppRepository());
    await services.loadAll();
    await tester.pumpWidget(NestSplitApp(services: services));

    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Ben'), findsOneWidget);
  });

  testWidgets('landlord link opens the landlord dashboard', (tester) async {
    final services = AppServices(MockAppRepository());
    await services.loadAll();
    await tester.pumpWidget(NestSplitApp(services: services));

    services.signIn(UserRole.landlord);
    await tester.pumpAndSettle();

    expect(find.text('Lakbay Boarding House'), findsWidgets);
    expect(find.text('Room 2 rent is late'), findsOneWidget);
  });
}
