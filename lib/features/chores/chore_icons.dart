import 'package:flutter/material.dart';

/// Maps the iconKey stored on a Chore to an icon. Add new keys here.
IconData choreIcon(String key) {
  switch (key) {
    case 'dishes':
      return Icons.restaurant_rounded;
    case 'trash':
      return Icons.delete_outline_rounded;
    case 'sweep':
      return Icons.air_rounded;
    case 'bathroom':
      return Icons.bathtub_outlined;
    case 'mop':
      return Icons.water_drop_outlined;
    case 'recycle':
      return Icons.recycling_rounded;
    case 'water':
      return Icons.opacity_rounded;
    case 'sparkle':
    default:
      return Icons.auto_awesome_rounded;
  }
}
