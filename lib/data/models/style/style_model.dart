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
  };
}
