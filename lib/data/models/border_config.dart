import 'package:flutter/material.dart';

class BorderConfig {
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final double borderOpacity;

  const BorderConfig({
    this.borderRadius = 4.0,
    this.borderColor = const Color(0xFFCCCCCC),
    this.borderWidth = 1.0,
    this.borderOpacity = 1.0,
  });

  factory BorderConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const BorderConfig();
    return BorderConfig(
      borderRadius: (map['border_radius'] as num?)?.toDouble() ?? 4.0,
      borderColor: _parseColor(map['border_color']) ?? const Color(0xFFCCCCCC),
      borderWidth: (map['border_width'] as num?)?.toDouble() ?? 1.0,
      borderOpacity: (map['border_opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  static Color? _parseColor(dynamic value) {
    if (value is int) return Color(value);
    if (value is String) {
      if (value.startsWith('#')) {
        final hex = value.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
    }
    return null;
  }
}
