import 'dart:ui';
import 'package:flutter/foundation.dart';

class StyleStatesModel {
  final Color? borderColor;
  final double? borderWidth;
  final String? helperText;
  final Color? helperTextColor;
  final Color? textColor;
  final FontStyle? fontStyle;
  // Add more fields as needed

  StyleStatesModel({
    this.borderColor,
    this.borderWidth,
    this.helperText,
    this.helperTextColor,
    this.textColor,
    this.fontStyle,
  });

  factory StyleStatesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StyleStatesModel();
    return StyleStatesModel(
      borderColor: StyleStatesModel._parseColor(json['border_color']),
      borderWidth: (json['border_width'] as num?)?.toDouble(),
      helperText: json['helper_text'] as String?,
      helperTextColor: StyleStatesModel._parseColor(json['helper_text_color']),
      textColor: StyleStatesModel._parseColor(json['color']),
      fontStyle: (json['font_style'] == 'italic')
          ? FontStyle.italic
          : FontStyle.normal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'border_color': borderColor != null ? _colorToHex(borderColor!) : null,
      'border_width': borderWidth,
      'helper_text': helperText,
      'helper_text_color': helperTextColor != null
          ? _colorToHex(helperTextColor!)
          : null,
      'color': textColor != null ? _colorToHex(textColor!) : null,
      'font_style': fontStyle == FontStyle.italic ? 'italic' : 'normal',
    };
  }

  static String _colorToHex(Color color) {
    // Returns #RRGGBB in uppercase
    return '#${((color.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${((color.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${((color.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  static Color? _parseColor(dynamic value) {
    debugPrint('[StyleStatesModel] _parseColor input: $value');
    if (value is int) {
      debugPrint('[StyleStatesModel] _parseColor int: $value');
      return Color(value);
    }
    if (value is String) {
      debugPrint('[StyleStatesModel] _parseColor string: $value');
      if (value.startsWith('#')) {
        final hex = value.replaceAll('#', '');
        if (hex.length == 6) {
          final color = Color(int.parse('FF$hex', radix: 16));
          debugPrint('[StyleStatesModel] _parseColor HEX #$hex => $color');
          return color;
        } else if (hex.length == 8) {
          final color = Color(int.parse(hex, radix: 16));
          debugPrint('[StyleStatesModel] _parseColor HEX8 $hex => $color');
          return color;
        }
      }
      if (value.startsWith('0x') || value.startsWith('0X')) {
        try {
          final hex = value.replaceAll(RegExp(r'0[xX]'), '');
          final color = Color(int.parse(hex, radix: 16));
          debugPrint('[StyleStatesModel] _parseColor 0x => $color');
          return color;
        } catch (e) {
          debugPrint('[StyleStatesModel] _parseColor ERROR: $e, value=$value');
        }
      }
    }
    debugPrint('[StyleStatesModel] _parseColor NULL for value=$value');
    return null;
  }

  @override
  String toString() => toJson().toString();
}
