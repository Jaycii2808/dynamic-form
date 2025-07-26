import 'package:flutter/material.dart';

class StyleModel {
  final double? fontSize;
  final String? color;
  final String? fontStyle;
  final double? contentVerticalPadding;
  final double? contentHorizontalPadding;
  final String? backgroundColor;
  final String? helperText;
  final String? helperTextColor;
  final String? padding;
  final String? margin;
  final double? labelTextSize;
  final String? labelColor;
  final int? maxLines;
  final int? minLines;
  final double? borderRadius;
  final String? borderColor;
  final double? borderWidth;
  final double? borderOpacity;
  // Bổ sung các property thường dùng trong UI
  final String? iconColor;
  final String? hintColor;
  final double? width;
  final double? height;
  final String? activeColor;
  final String? inactiveColor;
  final String? inactiveTrackColor;
  final String? tagBackgroundColor;
  final String? tagRemoveIconColor;
  final String? thumbColor;
  final String? thumbIconColor;
  final String? valueLabelColor;
  final double? iconSize;
  final String? textColor;
  final String? buttonBackgroundColor;
  final double? buttonBorderRadius;
  final String? buttonTextColor;
  final String? icon;
  final String? iconPosition;
  final String? fontWeight;
  final double? elevation;
  final String? shadowColor;
  // Add missing properties
  final String? focusedBorderColor;
  final String? errorBorderColor;

  const StyleModel({
    this.fontSize,
    this.color,
    this.fontStyle,
    this.contentVerticalPadding,
    this.contentHorizontalPadding,
    this.backgroundColor,
    this.helperText,
    this.helperTextColor,
    this.padding,
    this.margin,
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

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return StyleModel(
      fontSize: parseDouble(map['font_size']),
      color: map['color'] as String?,
      fontStyle: map['font_style'] as String?,
      contentVerticalPadding: parseDouble(map['content_vertical_padding']),
      contentHorizontalPadding: parseDouble(map['content_horizontal_padding']),
      backgroundColor: map['background_color'] as String?,
      helperText: map['helper_text'] as String?,
      helperTextColor: map['helper_text_color'] as String?,
      padding: map['padding'] as String?,
      margin: map['margin'] as String?,
      labelTextSize: parseDouble(map['label_text_size']),
      labelColor: map['label_color'] as String?,
      maxLines: parseInt(map['max_lines']),
      minLines: parseInt(map['min_lines']),
      borderRadius: parseDouble(map['border_radius']),
      borderColor: map['border_color'] as String?,
      borderWidth: parseDouble(map['border_width']),
      borderOpacity: parseDouble(map['border_opacity']),
      iconColor: map['icon_color'] as String?,
      hintColor: map['hint_color'] as String?,
      width: parseDouble(map['width']),
      height: parseDouble(map['height']),
      activeColor: map['active_color'] as String?,
      inactiveColor: map['inactive_color'] as String?,
      inactiveTrackColor: map['inactive_track_color'] as String?,
      tagBackgroundColor: map['tag_background_color'] as String?,
      tagRemoveIconColor: map['tag_remove_icon_color'] as String?,
      thumbColor: map['thumb_color'] as String?,
      thumbIconColor: map['thumb_icon_color'] as String?,
      valueLabelColor: map['value_label_color'] as String?,
      iconSize: parseDouble(map['icon_size']),
      textColor: map['text_color'] as String?,
      buttonBackgroundColor: map['button_background_color'] as String?,
      buttonBorderRadius: parseDouble(map['button_border_radius']),
      buttonTextColor: map['button_text_color'] as String?,
      icon: map['icon'] as String?,
      iconPosition: map['icon_position'] as String?,
      fontWeight: map['fontWeight'] as String?,
      elevation: parseDouble(map['elevation']),
      shadowColor: map['shadowColor'] as String?,
      focusedBorderColor: map['focused_border_color'] as String?,
      errorBorderColor: map['error_border_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (fontSize != null) 'font_size': fontSize,
    if (color != null) 'color': color,
    if (fontStyle != null) 'font_style': fontStyle,
    if (contentVerticalPadding != null)
      'content_vertical_padding': contentVerticalPadding,
    if (contentHorizontalPadding != null)
      'content_horizontal_padding': contentHorizontalPadding,
    if (backgroundColor != null) 'background_color': backgroundColor,
    if (helperText != null) 'helper_text': helperText,
    if (helperTextColor != null) 'helper_text_color': helperTextColor,
    if (padding != null) 'padding': padding,
    if (margin != null) 'margin': margin,
    if (labelTextSize != null) 'label_text_size': labelTextSize,
    if (labelColor != null) 'label_color': labelColor,
    if (maxLines != null) 'max_lines': maxLines,
    if (minLines != null) 'min_lines': minLines,
    if (borderRadius != null) 'border_radius': borderRadius,
    if (borderColor != null) 'border_color': borderColor,
    if (borderWidth != null) 'border_width': borderWidth,
    if (borderOpacity != null) 'border_opacity': borderOpacity,
    if (iconColor != null) 'icon_color': iconColor,
    if (hintColor != null) 'hint_color': hintColor,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (activeColor != null) 'active_color': activeColor,
    if (inactiveColor != null) 'inactive_color': inactiveColor,
    if (inactiveTrackColor != null) 'inactive_track_color': inactiveTrackColor,
    if (tagBackgroundColor != null) 'tag_background_color': tagBackgroundColor,
    if (tagRemoveIconColor != null) 'tag_remove_icon_color': tagRemoveIconColor,
    if (thumbColor != null) 'thumb_color': thumbColor,
    if (thumbIconColor != null) 'thumb_icon_color': thumbIconColor,
    if (valueLabelColor != null) 'value_label_color': valueLabelColor,
    if (iconSize != null) 'icon_size': iconSize,
    if (textColor != null) 'text_color': textColor,
    if (buttonBackgroundColor != null)
      'button_background_color': buttonBackgroundColor,
    if (buttonBorderRadius != null) 'button_border_radius': buttonBorderRadius,
    if (buttonTextColor != null) 'button_text_color': buttonTextColor,
    if (icon != null) 'icon': icon,
    if (iconPosition != null) 'icon_position': iconPosition,
    if (fontWeight != null) 'fontWeight': fontWeight,
    if (elevation != null) 'elevation': elevation,
    if (shadowColor != null) 'shadowColor': shadowColor,
    if (focusedBorderColor != null) 'focused_border_color': focusedBorderColor,
    if (errorBorderColor != null) 'error_border_color': errorBorderColor,
  };

  // Make parsing methods public
  static Color? parseColor(dynamic value) {
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

  static EdgeInsets? parseEdgeInsets(dynamic value) {
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

  // Helper methods for common style properties
  Color get fillColor => parseColor(backgroundColor) ?? Colors.transparent;
  Color get textColorValue => parseColor(color) ?? Colors.black;
  Color get labelTextColor => parseColor(labelColor) ?? Colors.black;
  Color get borderColorValue => parseColor(borderColor) ?? Colors.grey;
  Color get focusedBorderColorValue =>
      parseColor(focusedBorderColor) ?? parseColor(iconColor) ?? Colors.blue;
  Color get errorBorderColorValue => parseColor(errorBorderColor) ?? Colors.red;
  EdgeInsetsGeometry get paddingGeometry =>
      parseEdgeInsets(padding) ?? EdgeInsets.zero;
  EdgeInsetsGeometry get marginGeometry =>
      parseEdgeInsets(margin) ?? EdgeInsets.zero;
  double get borderWidthValue => borderWidth ?? 1.0;
  double get borderRadiusValue => borderRadius ?? 8.0;
  double get fontSizeValue => fontSize ?? 14.0;
  double get contentVerticalPaddingValue => contentVerticalPadding ?? 16.0;
  double get contentHorizontalPaddingValue => contentHorizontalPadding ?? 16.0;
  FontStyle get fontStyleValue =>
      fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal;
}
