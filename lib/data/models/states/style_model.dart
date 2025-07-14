import 'dart:ui';
import 'package:flutter/foundation.dart';

class StyleModel {
  final Color? borderColor;
  final double? borderWidth;
  final String? helperText;
  final Color? helperTextColor;
  final Color? textColor;
  final FontStyle? fontStyle;
  // Add more fields as needed

  StyleModel({
    this.borderColor,
    this.borderWidth,
    this.helperText,
    this.helperTextColor,
    this.textColor,
    this.fontStyle,
  });

  factory StyleModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StyleModel();
    return StyleModel(
      borderColor: StyleModel._parseColor(json['border_color']),
      borderWidth: (json['border_width'] as num?)?.toDouble(),
      helperText: json['helper_text'] as String?,
      helperTextColor: StyleModel._parseColor(json['helper_text_color']),
      textColor: StyleModel._parseColor(json['color']),
      fontStyle: (json['font_style'] == 'italic')
          ? FontStyle.italic
          : FontStyle.normal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'border_color': borderColor,
      'border_width': borderWidth,
      'helper_text': helperText,
      'helper_text_color': helperTextColor,
      'color': textColor,
      'font_style': fontStyle == FontStyle.italic ? 'italic' : 'normal',
    };
  }

  static Color? _parseColor(dynamic value) {
    debugPrint('[StyleModel] _parseColor input: $value');
    if (value is int) {
      debugPrint('[StyleModel] _parseColor int: $value');
      return Color(value);
    }
    if (value is String) {
      debugPrint('[StyleModel] _parseColor string: $value');
      if (value.startsWith('#')) {
        final hex = value.replaceAll('#', '');
        if (hex.length == 6) {
          final color = Color(int.parse('FF$hex', radix: 16));
          debugPrint('[StyleModel] _parseColor HEX #$hex => $color');
          return color;
        } else if (hex.length == 8) {
          final color = Color(int.parse(hex, radix: 16));
          debugPrint('[StyleModel] _parseColor HEX8 $hex => $color');
          return color;
        }
      }
      if (value.startsWith('0x') || value.startsWith('0X')) {
        try {

          final hex = value.replaceAll(RegExp(r'0[xX]'), '');
          final color = Color(int.parse(hex, radix: 16));
          debugPrint('[StyleModel] _parseColor 0x => $color');
          return color;
        } catch (e) {
          debugPrint('[StyleModel] _parseColor ERROR: $e, value=$value');
        }
      }
    }
    debugPrint('[StyleModel] _parseColor NULL for value=$value');
    return null;
  }
  @override
  String toString() => toJson().toString();
}
