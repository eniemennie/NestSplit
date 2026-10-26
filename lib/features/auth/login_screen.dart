import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/buttons.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/ns_text_field.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/app_services.dart';
import '../../data/models/user_account.dart';
import 'landlord_login_screen.dart';
import 'register_screen.dart';

/// Screen 1: email + password sign-in. Accounts are checked by [AuthRepository]
/// (a local mock for now, see MockAuthRepository).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final services = AppScope.of(context);
    setState(() {
      _emailError = Validators.email(_email.text);
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;
    setState(() => _busy = true);
    try {
      await services.login(_email.text, _password.text, expectedRole: AccountRole.tenant);
    } on AuthException catch (e) {
      if (mounted) setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openRegister() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
  }

  void _openLandlordLogin() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LandlordLoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandLogo(size: 104),
                      const SizedBox(height: 14),
                      Text('NestSplit', style: AppText.screenTitle.copyWith(fontSize: 32)),
                      const SizedBox(height: 4),
                      const Text('Split the Bill, Share the Load.', style: AppText.bodyMuted),
                      const SizedBox(height: 26),
                      NsTextField(
                        controller: _email,
                        label: 'Email',
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 12),
                      NsTextField(
                        controller: _password,
                        label: 'Password',
                        errorText: _passwordError,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.password],
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: 10),
                        Text(_formError!, style: AppText.caption.copyWith(color: AppColors.errorText, fontWeight: FontWeight.w700)),
                      ],
                      const SizedBox(height: 18),
                      PrimaryButton(label: _busy ? 'Signing in...' : 'Sign in', onPressed: _busy ? null : _submit),
                      const SizedBox(height: 12),
                      TriBandButton(label: 'Create account', onPressed: _busy ? null : _openRegister),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _openLandlordLogin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.navy, width: 1.4),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.apartment_rounded, size: 20),
                        label: const Text('Landlord login', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
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
