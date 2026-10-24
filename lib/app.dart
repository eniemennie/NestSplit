import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/landlord/landlord_shell.dart';
import 'features/shell/tenant_shell.dart';
import 'state/app_services.dart';

/// Root widget. Shows the login screen, then the tenant or landlord shell by role.
class NestSplitApp extends StatelessWidget {
  const NestSplitApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: 'NestSplit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        navigatorKey: services.navigatorKey,
        // Keeps phone layout on tablets, web and desktop windows.
        builder: (context, child) {
          return ColoredBox(
            color: AppColors.background,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: child,
              ),
            ),
          );
        },
        home: ValueListenableBuilder<UserRole?>(
          valueListenable: services.role,
          builder: (context, role, _) {
            switch (role) {
              case UserRole.tenant:
                return const TenantShell();
              case UserRole.landlord:
                return const LandlordShell();
              case null:
                return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
