import 'package:equatable/equatable.dart';

/// Model for style data - replaces Map<String, dynamic>
class StyleDataModel extends Equatable {
  final String? backgroundColor;
  final String? textColor;
  final String? borderColor;
  final double? borderRadius;
  final double? fontSize;
  final String? fontWeight;
  final double? padding;
  final double? margin;
  final String? alignment;
  final Map<String, dynamic>? customProperties;

  const StyleDataModel({
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.alignment,
    this.customProperties,
  });

  factory StyleDataModel.fromJson(Map<String, dynamic> json) {
    return StyleDataModel(
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      borderColor: json['borderColor'] as String?,
      borderRadius: json['borderRadius']?.toDouble(),
      fontSize: json['fontSize']?.toDouble(),
      fontWeight: json['fontWeight'] as String?,
      padding: json['padding']?.toDouble(),
      margin: json['margin']?.toDouble(),
      alignment: json['alignment'] as String?,
      customProperties: json['customProperties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'borderColor': borderColor,
      'borderRadius': borderRadius,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'padding': padding,
      'margin': margin,
      'alignment': alignment,
      'customProperties': customProperties,
    };
  }

  @override
  List<Object?> get props => [
    backgroundColor,
    textColor,
    borderColor,
    borderRadius,
    fontSize,
    fontWeight,
    padding,
    margin,
    alignment,
    customProperties,
  ];

  StyleDataModel copyWith({
    String? backgroundColor,
    String? textColor,
    String? borderColor,
    double? borderRadius,
    double? fontSize,
    String? fontWeight,
    double? padding,
    double? margin,
    String? alignment,
    Map<String, dynamic>? customProperties,
  }) {
    return StyleDataModel(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      alignment: alignment ?? this.alignment,
      customProperties: customProperties ?? this.customProperties,
    );
  }
}
