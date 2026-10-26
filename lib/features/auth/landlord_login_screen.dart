import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/ns_text_field.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/app_services.dart';
import 'register_screen.dart';

/// Landlord sign-in. Only landlord accounts can enter here; tenants use the first screen.
class LandlordLoginScreen extends StatefulWidget {
  const LandlordLoginScreen({super.key});

  @override
  State<LandlordLoginScreen> createState() => _LandlordLoginScreenState();
}

class _LandlordLoginScreenState extends State<LandlordLoginScreen> {
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
    final navigator = Navigator.of(context);
    setState(() {
      _emailError = Validators.email(_email.text);
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;
    setState(() => _busy = true);
    try {
      await services.login(_email.text, _password.text, expectedRole: AccountRole.landlord);
      // The app swaps to the landlord side by itself; close this screen.
      navigator.popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen(initialRole: AccountRole.landlord)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.navy,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandLogo(size: 88),
                const SizedBox(height: 12),
                Text('Landlord login', style: AppText.screenTitle.copyWith(fontSize: 28)),
                const SizedBox(height: 4),
                const Text('Manage your boarding houses, rooms and rent.', textAlign: TextAlign.center, style: AppText.bodyMuted),
                const SizedBox(height: 24),
                NsTextField(
                  controller: _email,
                  label: 'Email',
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                NsTextField(
                  controller: _password,
                  label: 'Password',
                  errorText: _passwordError,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 10),
                  Text(_formError!, style: AppText.caption.copyWith(color: AppColors.errorText, fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 18),
                PrimaryButton(label: _busy ? 'Signing in...' : 'Sign in as landlord', onPressed: _busy ? null : _submit),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : _openRegister,
                  child: Text('New landlord? Create account', style: AppText.caption.copyWith(color: AppColors.linkBlue, fontWeight: FontWeight.w800)),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  const Text('Demo (debug only): landlord@nestsplit.test, password Nest1234', textAlign: TextAlign.center, style: AppText.caption),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
