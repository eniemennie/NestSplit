import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/landlord/landlord_shell.dart';
import 'features/shell/tenant_shell.dart';
import 'features/splash/splash_screen.dart';
import 'state/app_services.dart';

/// Root widget. Shows the splash, then the login screen, then the tenant or landlord
/// shell by role. Set [showSplash] to false in tests.
class NestSplitApp extends StatelessWidget {
  const NestSplitApp({super.key, required this.services, this.showSplash = true});

  final AppServices services;
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: AppInfo.name,
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
        home: _SplashGate(
          showSplash: showSplash,
          child: ValueListenableBuilder<UserRole?>(
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
      ),
    );
  }
}

/// Shows the splash first, then [child].
class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.showSplash, required this.child});

  final bool showSplash;
  final Widget child;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  late bool _splashVisible = widget.showSplash;

  @override
  Widget build(BuildContext context) {
    if (_splashVisible) {
      return SplashScreen(onFinished: () => setState(() => _splashVisible = false));
    }
    return widget.child;
  }
}
