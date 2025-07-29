import 'dart:ui';

class StyleStatesModel {
  final Color? borderColor;
  final double? borderWidth;
  final String? helperText;
  final Color? helperTextColor;
  final Color? textColor;
  final FontStyle? fontStyle;
  final String? icon;
  final Color? iconColor;
  final double? iconSize;
  // Add more fields as needed

  StyleStatesModel({
    this.borderColor,
    this.borderWidth,
    this.helperText,
    this.helperTextColor,
    this.textColor,
    this.fontStyle,
    this.icon,
    this.iconColor,
    this.iconSize,
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
      icon: json['icon'] as String?,
      iconColor: StyleStatesModel._parseColor(json['icon_color']),
      iconSize: (json['icon_size'] as num?)?.toDouble(),
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
      'icon': icon,
      'icon_color': iconColor != null ? _colorToHex(iconColor!) : null,
      'icon_size': iconSize,
    };
  }

  static String _colorToHex(Color color) {
    // Returns 0xFFRRGGBB in uppercase
    return '0x${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}';
  }

  // ✨ FIXED: Simplified to only handle "0x..." color strings
  static Color? _parseColor(dynamic value) {
    if (value is String && value.toUpperCase().startsWith('0X')) {
      final intVal = int.tryParse(value.substring(2), radix: 16);
      return intVal != null ? Color(intVal) : null;
    }
    return null;
  }

  @override
  String toString() => toJson().toString();
}
