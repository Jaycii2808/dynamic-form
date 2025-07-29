import 'package:flutter/material.dart';

class StyleModel {
  final double? fontSize;
  final String? fontStyle;
  final double? contentVerticalPadding;
  final double? contentHorizontalPadding;
  final Color? backgroundColor;
  final String? helperText;
  final Color? helperTextColor;
  final double? labelTextSize;
  final Color? labelColor;
  final int? maxLines;
  final int? minLines;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderOpacity;
  final Color? iconColor;
  final Color? hintColor;
  final double? width;
  final double? height;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? inactiveTrackColor;
  final Color? tagBackgroundColor;
  final Color? tagRemoveIconColor;
  final Color? thumbColor;
  final Color? thumbIconColor;
  final Color? valueLabelColor;
  final double? iconSize;
  final Color? textColor;
  final Color? buttonBackgroundColor;
  final double? buttonBorderRadius;
  final Color? buttonTextColor;
  final String? icon;
  final String? iconPosition;
  final String? fontWeight;
  final double? elevation;
  final Color? shadowColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;

  const StyleModel({
    this.fontSize,
    this.fontStyle,
    this.contentVerticalPadding,
    this.contentHorizontalPadding,
    this.backgroundColor,
    this.helperText,
    this.helperTextColor,
    this.labelTextSize,
    this.labelColor,
    this.maxLines,
    this.minLines,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.borderOpacity,
    this.iconColor,
    this.hintColor,
    this.width,
    this.height,
    this.activeColor,
    this.inactiveColor,
    this.inactiveTrackColor,
    this.tagBackgroundColor,
    this.tagRemoveIconColor,
    this.thumbColor,
    this.thumbIconColor,
    this.valueLabelColor,
    this.iconSize,
    this.textColor,
    this.buttonBackgroundColor,
    this.buttonBorderRadius,
    this.buttonTextColor,
    this.icon,
    this.iconPosition,
    this.fontWeight,
    this.elevation,
    this.shadowColor,
    this.focusedBorderColor,
    this.errorBorderColor,
  });

  factory StyleModel.fromJson(Map<String, dynamic>? map) {
    if (map == null) return const StyleModel();

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    // ✨ FIXED: Simplified to only handle "0x..." color strings.
    Color? parseColor(dynamic v) {
      if (v is String && v.toUpperCase().startsWith('0X')) {
        final intVal = int.tryParse(v.substring(2), radix: 16);
        return intVal != null ? Color(intVal) : null;
      }
      return null;
    }

    return StyleModel(
      fontSize: parseDouble(map['font_size']),
      fontStyle: map['font_style'] as String?,
      contentVerticalPadding: parseDouble(map['content_vertical_padding']),
      contentHorizontalPadding: parseDouble(map['content_horizontal_padding']),
      backgroundColor: parseColor(map['background_color']),
      helperText: map['helper_text'] as String?,
      helperTextColor: parseColor(map['helper_text_color']),
      labelTextSize: parseDouble(map['label_text_size']),
      labelColor: parseColor(map['label_color']),
      maxLines: map['max_lines'] as int?,
      minLines: map['min_lines'] as int?,
      borderRadius: parseDouble(map['border_radius']),
      borderColor: parseColor(map['border_color']),
      borderWidth: parseDouble(map['border_width']),
      borderOpacity: parseDouble(map['border_opacity']),
      iconColor: parseColor(map['icon_color']),
      hintColor: parseColor(map['hint_color']),
      width: parseDouble(map['width']),
      height: parseDouble(map['height']),
      activeColor: parseColor(map['active_color']),
      inactiveColor: parseColor(map['inactive_color']),
      inactiveTrackColor: parseColor(map['inactive_track_color']),
      tagBackgroundColor: parseColor(map['tag_background_color']),
      tagRemoveIconColor: parseColor(map['tag_remove_icon_color']),
      thumbColor: parseColor(map['thumb_color']),
      thumbIconColor: parseColor(map['thumb_icon_color']),
      valueLabelColor: parseColor(map['value_label_color']),
      iconSize: parseDouble(map['icon_size']),
      textColor: parseColor(map['text_color']),
      buttonBackgroundColor: parseColor(map['button_background_color']),
      buttonBorderRadius: parseDouble(map['button_border_radius']),
      buttonTextColor: parseColor(map['button_text_color']),
      icon: map['icon'] as String?,
      iconPosition: map['icon_position'] as String?,
      fontWeight: map['fontWeight'] as String?,
      elevation: parseDouble(map['elevation']),
      shadowColor: parseColor(map['shadowColor']),
      focusedBorderColor: parseColor(map['focused_border_color']),
      errorBorderColor: parseColor(map['error_border_color']),
    );
  }

  // Convert color to hex string for JSON serialization
  String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '0x${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSize,
      'font_style': fontStyle,
      'content_vertical_padding': contentVerticalPadding,
      'content_horizontal_padding': contentHorizontalPadding,
      'background_color': _colorToHex(backgroundColor),
      'helper_text': helperText,
      'helper_text_color': _colorToHex(helperTextColor),
      'label_text_size': labelTextSize,
      'label_color': _colorToHex(labelColor),
      'max_lines': maxLines,
      'min_lines': minLines,
      'border_radius': borderRadius,
      'border_color': _colorToHex(borderColor),
      'border_width': borderWidth,
      'border_opacity': borderOpacity,
      'icon_color': _colorToHex(iconColor),
      'hint_color': _colorToHex(hintColor),
      'width': width,
      'height': height,
      'active_color': _colorToHex(activeColor),
      'inactive_color': _colorToHex(inactiveColor),
      'inactive_track_color': _colorToHex(inactiveTrackColor),
      'tag_background_color': _colorToHex(tagBackgroundColor),
      'tag_remove_icon_color': _colorToHex(tagRemoveIconColor),
      'thumb_color': _colorToHex(thumbColor),
      'thumb_icon_color': _colorToHex(thumbIconColor),
      'value_label_color': _colorToHex(valueLabelColor),
      'icon_size': iconSize,
      'text_color': _colorToHex(textColor),
      'button_background_color': _colorToHex(buttonBackgroundColor),
      'button_border_radius': buttonBorderRadius,
      'button_text_color': _colorToHex(buttonTextColor),
      'icon': icon,
      'icon_position': iconPosition,
      'fontWeight': fontWeight,
      'elevation': elevation,
      'shadowColor': _colorToHex(shadowColor),
      'focused_border_color': _colorToHex(focusedBorderColor),
      'error_border_color': _colorToHex(errorBorderColor),
    };
  }
}
