import 'package:flutter/material.dart';

enum SmokeItemType { cigarette, cigar, joint, bong }

class SmokeItem {
  const SmokeItem({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.duration,
    required this.thickness,
    required this.bodyColor,
    required this.endColor,
    required this.isCone,
    required this.icon,
  });

  final SmokeItemType type;
  final String label;
  final String subtitle;
  final Duration duration;
  final double thickness;
  final Color bodyColor;
  final Color endColor;
  final bool isCone;
  final String icon;

  bool get isBong => type == SmokeItemType.bong;

  static const List<SmokeItem> all = [
    SmokeItem(
      type: SmokeItemType.cigarette,
      label: 'Zigarette',
      subtitle: 'Klassisch mit Filter - ca. 3 Minuten',
      duration: Duration(minutes: 3),
      thickness: 0.040,
      bodyColor: Color(0xFFF4F1E8),
      endColor: Color(0xFFD89B4A),
      isCone: false,
      icon: '🚬',
    ),
    SmokeItem(
      type: SmokeItemType.cigar,
      label: 'Zigarre',
      subtitle: 'Langsam und gemütlich - ca. 8 Minuten',
      duration: Duration(minutes: 8),
      thickness: 0.075,
      bodyColor: Color(0xFF7A4A21),
      endColor: Color(0xFFC9A227),
      isCone: false,
      icon: '🍂',
    ),
    SmokeItem(
      type: SmokeItemType.joint,
      label: 'Joint',
      subtitle: 'Mit Krutz - ca. 2,5 Minuten',
      duration: Duration(minutes: 2, seconds: 30),
      thickness: 0.055,
      bodyColor: Color(0xFFD8D2AE),
      endColor: Color(0xFFF8F6EE),
      isCone: true,
      icon: '🍃',
    ),
    SmokeItem(
      type: SmokeItemType.bong,
      label: 'Bong',
      subtitle: 'Ein Zug mit Flutsch - danach wird kurz schwarz …',
      duration: Duration(seconds: 3),
      thickness: 0.15,
      bodyColor: Color(0xFF9FD4E8),
      endColor: Color(0xFF3E7CA6),
      isCone: false,
      icon: '🫧',
    ),
  ];
}
