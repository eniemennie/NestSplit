import 'package:flutter/material.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/ns_card.dart';
import '../../core/widgets/ns_text_field.dart';
import '../../core/widgets/snack.dart';
import '../../core/widgets/status_pill.dart';
import '../../core/widgets/text_prompt.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/app_services.dart';

/// Profile tab (both roles): who is signed in, edit name, change password, log out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, AppServices services, UserAccount acc) async {
    final name = await showTextPrompt(context, title: 'Edit name', hint: 'Your name', initial: acc.name);
    if (name == null || name.isEmpty || !context.mounted) return;
    await services.updateName(name);
    if (context.mounted) showNsSnack(context, 'Name updated');
  }

  Future<void> _changePassword(BuildContext context, AppServices services) async {
    final done = await showDialog<bool>(context: context, builder: (_) => _ChangePasswordDialog(services: services));
    if (done == true && context.mounted) showNsSnack(context, 'Password changed');
  }

  Future<void> _confirmLogout(BuildContext context, AppServices services) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?', style: AppText.sectionTitle),
        content: const Text('You will need your email and password to sign back in.', style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) services.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return ValueListenableBuilder<UserAccount?>(
      valueListenable: services.account,
      builder: (context, acc, _) {
        if (acc == null) return const SizedBox.shrink();
        final isTenant = acc.role == AccountRole.tenant;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              const Text('Profile', style: AppText.screenTitle),
              const SizedBox(height: 16),
              NsCard(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isTenant ? AppColors.pink : AppColors.lime,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy, width: 1.6),
                      ),
                      child: Text(
                        acc.name.isEmpty ? '?' : acc.name.substring(0, 1).toUpperCase(),
                        style: AppText.screenTitle.copyWith(fontSize: 34),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(acc.name, style: AppText.sectionTitle.copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(acc.email, style: AppText.bodyMuted),
                    const SizedBox(height: 10),
                    StatusPill(isTenant ? 'Tenant' : 'Landlord', kind: isTenant ? PillKind.blue : PillKind.lime),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: isTenant ? services.household : services.property,
                builder: (context, _) {
                  return NsCard(
                    child: Column(
                      children: [
                        if (isTenant) ...[
                          _InfoRow(label: 'Household', value: services.household.householdName),
                          _InfoRow(label: 'Invite code', value: services.household.inviteCode),
                        ] else ...[
                          _InfoRow(label: 'Property', value: services.property.propertyName),
                          _InfoRow(label: 'Tenant code', value: services.property.inviteCode),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              NsCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    _ActionRow(icon: Icons.edit_outlined, label: 'Edit name', onTap: () => _editName(context, services, acc)),
                    const Divider(height: 1, color: AppColors.border),
                    _ActionRow(icon: Icons.lock_outline_rounded, label: 'Change password', onTap: () => _changePassword(context, services)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, services),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.navy, width: 1.4),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  BrandLogo(size: 26),
                  SizedBox(width: 8),
                  Text('NestSplit · Split the Bill, Share the Load.', style: AppText.caption),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodyMuted)),
          Text(value, style: AppText.cardTitle),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.navy),
      title: Text(label, style: AppText.cardTitle),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.services});

  final AppServices services;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  String? _currentError;
  String? _nextError;
  String? _confirmError;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _currentError = _current.text.isEmpty ? 'Enter your current password.' : null;
      _nextError = Validators.newPassword(_next.text);
      _confirmError = _confirm.text == _next.text ? null : 'Passwords do not match.';
    });
    if (_currentError != null || _nextError != null || _confirmError != null) return;
    setState(() => _busy = true);
    try {
      await widget.services.changePassword(_current.text, _next.text);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _currentError = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password', style: AppText.sectionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NsTextField(controller: _current, label: 'Current password', obscure: true, errorText: _currentError),
            const SizedBox(height: 10),
            NsTextField(controller: _next, label: 'New password', obscure: true, errorText: _nextError),
            const SizedBox(height: 10),
            NsTextField(controller: _confirm, label: 'Confirm new password', obscure: true, errorText: _confirmError),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
        ),
        TextButton(
          onPressed: _busy ? null : _save,
          child: const Text('Save', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
