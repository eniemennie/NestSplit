import 'package:flutter/material.dart';
import '../../data/models/member.dart';
import '../theme/app_colors.dart';

/// Background color for a member's avatar.
Color memberColor(MemberColor color) {
  switch (color) {
    case MemberColor.blue:
      return AppColors.blue;
    case MemberColor.pink:
      return AppColors.pink;
    case MemberColor.lime:
      return AppColors.lime;
    case MemberColor.navy:
      return AppColors.navy;
  }
}

/// Rounded-square avatar showing the member's initial.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.member, this.size = 30, this.radius});

  final Member member;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final bg = memberColor(member.color);
    final fg = member.color == MemberColor.navy ? AppColors.white : AppColors.navy;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius ?? size * 0.28),
      ),
      child: Text(
        member.initial,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: size * 0.42),
      ),
    );
  }
}
