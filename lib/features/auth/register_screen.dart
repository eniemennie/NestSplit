import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/ns_chip.dart';
import '../../core/widgets/ns_text_field.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/app_services.dart';

/// Create-account form. Tenants join a home with its invite code; landlords do not need one.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _code = TextEditingController();

  AccountRole _role = AccountRole.tenant;
  final Map<String, String?> _errors = <String, String?>{};
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final services = AppScope.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _errors
        ..['name'] = Validators.requiredText(_name.text, 'your name')
        ..['email'] = Validators.email(_email.text)
        ..['password'] = Validators.newPassword(_password.text)
        ..['confirm'] = _confirm.text == _password.text ? null : 'Passwords do not match.'
        ..['code'] = _role == AccountRole.tenant ? Validators.requiredText(_code.text, 'the invite code') : null;
      _formError = null;
    });
    if (_errors.values.any((e) => e != null)) return;
    setState(() => _busy = true);
    try {
      await services.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        role: _role,
        inviteCode: _code.text,
      );
      // The app swaps to the tenant or landlord side by itself; close this form.
      navigator.popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTenant = _role == AccountRole.tenant;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.navy,
        title: const Text('Create account', style: AppText.headerTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Text('I am a', style: AppText.cardTitle),
            const SizedBox(height: 8),
            Row(
              children: [
                NsChip(label: 'Tenant', selected: isTenant, onTap: () => setState(() => _role = AccountRole.tenant)),
                const SizedBox(width: 8),
                NsChip(label: 'Landlord', selected: !isTenant, onTap: () => setState(() => _role = AccountRole.landlord)),
              ],
            ),
            const SizedBox(height: 16),
            NsTextField(controller: _name, label: 'Name', errorText: _errors['name'], textInputAction: TextInputAction.next),
            const SizedBox(height: 12),
            NsTextField(
              controller: _email,
              label: 'Email',
              errorText: _errors['email'],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            NsTextField(
              controller: _password,
              label: 'Password',
              errorText: _errors['password'],
              obscure: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 4),
            const Text('At least 8 characters, with a letter and a number.', style: AppText.caption),
            const SizedBox(height: 12),
            NsTextField(
              controller: _confirm,
              label: 'Confirm password',
              errorText: _errors['confirm'],
              obscure: true,
              textInputAction: isTenant ? TextInputAction.next : TextInputAction.done,
            ),
            if (isTenant) ...[
              const SizedBox(height: 12),
              NsTextField(
                controller: _code,
                label: 'Home invite code',
                errorText: _errors['code'],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 4),
              const Text('Ask a housemate for the code (see More > Members).', style: AppText.caption),
            ],
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Text(_formError!, style: AppText.caption.copyWith(color: AppColors.errorText, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            PrimaryButton(label: _busy ? 'Creating...' : 'Create account', onPressed: _busy ? null : _submit),
          ],
        ),
      ),
    );
  }
}
