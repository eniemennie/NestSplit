import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/text_prompt.dart';
import '../../state/app_services.dart';

/// Screen 1. Sign-in is a mock for now: it only picks the role and opens the app.
/// TODO(backend): replace the button handlers with real authentication.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _join(BuildContext context, AppServices services) async {
    final code = await showTextPrompt(
      context,
      title: 'Join with invite code',
      hint: 'e.g. LKB-482',
      confirmLabel: 'Join',
    );
    if (code == null || code.isEmpty || !context.mounted) return;
    if (code.toUpperCase() == services.household.inviteCode.toUpperCase()) {
      services.signIn(UserRole.tenant);
    } else {
      showNsSnack(context, 'That code does not match a home.');
    }
  }

  Future<void> _create(BuildContext context, AppServices services) async {
    final name = await showTextPrompt(
      context,
      title: 'Create a household',
      hint: 'Household name',
      confirmLabel: 'Create',
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    services.household.householdName = name;
    services.signIn(UserRole.tenant);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(left: 24, top: 70, child: _Triangle()),
          Positioned(
            right: 52,
            top: 96,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 250,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(width: 100, height: 34, color: AppColors.lime),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const BrandLogo(size: 130),
                  const SizedBox(height: 18),
                  Text('NestSplit', style: AppText.screenTitle.copyWith(fontSize: 36)),
                  const SizedBox(height: 6),
                  const Text('Fair chores, happy home.', style: AppText.bodyMuted),
                  const Spacer(flex: 4),
                  PrimaryButton(label: 'Sign in', onPressed: () => services.signIn(UserRole.tenant)),
                  const SizedBox(height: 12),
                  TriBandButton(label: 'Join with invite code', onPressed: () => _join(context, services)),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _create(context, services),
                    child: Text('New here? Create a household', style: AppText.caption.copyWith(color: AppColors.navy)),
                  ),
                  // Interpretation: the mockup set has no landlord sign-in screen, so a small
                  // text link is used to open the landlord view.
                  TextButton(
                    onPressed: () => services.signIn(UserRole.landlord),
                    child: Text("I'm a landlord", style: AppText.caption.copyWith(color: AppColors.linkBlue, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Triangle extends StatelessWidget {
  const _Triangle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(46, 44), painter: _TrianglePainter());
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height * 0.62)
      ..lineTo(size.width * 0.85, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
