import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';

class StyleConfig {
  final double fontSize;
  final Color textColor;
  final FontStyle fontStyle;
  final double contentVerticalPadding;
  final double contentHorizontalPadding;
  final Color fillColor;
  final String? helperText;
  final Color helperTextColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double labelTextSize;
  final Color labelColor;
  final int maxLines;
  final int minLines;
  final BorderConfig borderConfig;

  const StyleConfig({
    this.fontSize = 16.0,
    this.textColor = Colors.white,
    this.fontStyle = FontStyle.normal,
    this.contentVerticalPadding = 12.0,
    this.contentHorizontalPadding = 12.0,
    this.fillColor = Colors.transparent,
    this.helperText,
    this.helperTextColor = Colors.grey,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.labelTextSize = 16.0,
    this.labelColor = Colors.white,
    this.maxLines = 10,
    this.minLines = 6,
    this.borderConfig = const BorderConfig(),
  });

  factory StyleConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StyleConfig();
    return StyleConfig(
      fontSize: (map['font_size'] as num?)?.toDouble() ?? 16.0,
      textColor: _parseColor(map['color']) ?? Colors.white,
      fontStyle: (map['font_style'] == 'italic')
          ? FontStyle.italic
          : FontStyle.normal,
      contentVerticalPadding:
          (map['content_vertical_padding'] as num?)?.toDouble() ?? 12.0,
      contentHorizontalPadding:
          (map['content_horizontal_padding'] as num?)?.toDouble() ?? 12.0,
      fillColor: _parseColor(map['background_color']) ?? Colors.transparent,
      helperText: map['helper_text']?.toString(),
      helperTextColor: _parseColor(map['helper_text_color']) ?? Colors.grey,
      padding: _parseEdgeInsets(map['padding']) ?? EdgeInsets.zero,
      margin: _parseEdgeInsets(map['margin']) ?? EdgeInsets.zero,
      labelTextSize: (map['label_text_size'] as num?)?.toDouble() ?? 16.0,
      labelColor: _parseColor(map['label_color']) ?? Colors.white,
      maxLines: (map['max_lines'] as num?)?.toInt() ?? 10,
      minLines: (map['min_lines'] as num?)?.toInt() ?? 6,
      borderConfig: BorderConfig.fromMap(map),
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

  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value is String) {
      final parts = value.split(' ');
      if (parts.length == 2) {
        final horizontal = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
        final vertical = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
        return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
      } else if (parts.length == 4) {
        final top = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
        final right = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
        final bottom = double.tryParse(parts[2].replaceAll('px', '')) ?? 0;
        final left = double.tryParse(parts[3].replaceAll('px', '')) ?? 0;
        return EdgeInsets.fromLTRB(left, top, right, bottom);
      } else {
        final valueNum = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
        return EdgeInsets.all(valueNum);
      }
    }
    return null;
  }
}
