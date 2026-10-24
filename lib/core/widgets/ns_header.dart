import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import 'buttons.dart';

/// Header for sub-screens: square back button, bold title and optional right action.
class NsHeader extends StatelessWidget {
  const NsHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          SquareIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppText.headerTitle)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Standard scrolling page with the back header. Used by every sub-screen.
class SubPage extends StatelessWidget {
  const SubPage({super.key, required this.title, required this.children, this.trailing, this.bottom});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  /// Optional widget pinned below the scrolling content (e.g. a primary button).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NsHeader(title: title, trailing: trailing),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: children,
              ),
            ),
            if (bottom != null)
              Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), child: bottom),
          ],
        ),
      ),
    );
  }
}
