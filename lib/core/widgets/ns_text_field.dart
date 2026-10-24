import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Rounded text field used on login, sign-up and profile forms.
/// Set [obscure] for passwords; a show/hide eye is added automatically.
class NsTextField extends StatefulWidget {
  const NsTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  @override
  State<NsTextField> createState() => _NsTextFieldState();
}

class _NsTextFieldState extends State<NsTextField> {
  late bool _hidden = widget.obscure;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      autocorrect: !widget.obscure,
      enableSuggestions: !widget.obscure,
      style: AppText.body,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppText.bodyMuted,
        errorText: widget.errorText,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(AppColors.border, 1),
        enabledBorder: _border(AppColors.border, 1),
        focusedBorder: _border(AppColors.navy, 1.6),
        errorBorder: _border(AppColors.pink, 1.6),
        focusedErrorBorder: _border(AppColors.pink, 1.6),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.muted),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}
