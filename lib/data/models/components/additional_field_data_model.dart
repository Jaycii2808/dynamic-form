import 'package:equatable/equatable.dart';

class AdditionalFieldDataModel extends Equatable {
  final String? validationRule;
  final String? validationMessage;
  final bool? isDirty;
  final bool? isTouched;
  final DateTime? lastModified;
  final String? source;
  final Map<String, dynamic>? customProperties;
  final List<String>? tags;
  final String? format;
  final int? maxLength;
  final int? minLength;
  final String? pattern;
  final bool? readOnly;
  final bool? disabled;
  final String? helpText;
  final String? tooltip;

  const AdditionalFieldDataModel({
    this.validationRule,
    this.validationMessage,
    this.isDirty,
    this.isTouched,
    this.lastModified,
    this.source,
    this.customProperties,
    this.tags,
    this.format,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.readOnly,
    this.disabled,
    this.helpText,
    this.tooltip,
  });

  factory AdditionalFieldDataModel.create({
    String? validationRule,
    String? validationMessage,
    bool? isDirty,
    bool? isTouched,
    DateTime? lastModified,
    String? source,
    Map<String, dynamic>? customProperties,
    List<String>? tags,
    String? format,
    int? maxLength,
    int? minLength,
    String? pattern,
    bool? readOnly,
    bool? disabled,
    String? helpText,
    String? tooltip,
  }) {
    return AdditionalFieldDataModel(
      validationRule: validationRule,
      validationMessage: validationMessage,
      isDirty: isDirty,
      isTouched: isTouched,
      lastModified: lastModified ?? DateTime.now(),
      source: source,
      customProperties: customProperties,
      tags: tags,
      format: format,
      maxLength: maxLength,
      minLength: minLength,
      pattern: pattern,
      readOnly: readOnly,
      disabled: disabled,
      helpText: helpText,
      tooltip: tooltip,
    );
  }

  factory AdditionalFieldDataModel.fromJson(Map<String, dynamic> map) {
    return AdditionalFieldDataModel(
      validationRule: map['validation_rule'] as String?,
      validationMessage: map['validation_message'] as String?,
      isDirty: map['is_dirty'] as bool?,
      isTouched: map['is_touched'] as bool?,
      lastModified: map['last_modified'] != null
          ? DateTime.parse(map['last_modified'] as String)
          : null,
      source: map['source'] as String?,
      customProperties: map['custom_properties'] != null
          ? Map<String, dynamic>.from(map['custom_properties'])
          : null,
      tags: map['tags'] != null ? List<String>.from(map['tags'] as List) : null,
      format: map['format'] as String?,
      maxLength: map['max_length'] as int?,
      minLength: map['min_length'] as int?,
      pattern: map['pattern'] as String?,
      readOnly: map['read_only'] as bool?,
      disabled: map['disabled'] as bool?,
      helpText: map['help_text'] as String?,
      tooltip: map['tooltip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (validationRule != null) data['validation_rule'] = validationRule;
    if (validationMessage != null) {
      data['validation_message'] = validationMessage;
    }
    if (isDirty != null) data['is_dirty'] = isDirty;
    if (isTouched != null) data['is_touched'] = isTouched;
    if (lastModified != null) {
      data['last_modified'] = lastModified!.toIso8601String();
    }
    if (source != null) data['source'] = source;
    if (customProperties != null) data['custom_properties'] = customProperties;
    if (tags != null) data['tags'] = tags;
    if (format != null) data['format'] = format;
    if (maxLength != null) data['max_length'] = maxLength;
    if (minLength != null) data['min_length'] = minLength;
    if (pattern != null) data['pattern'] = pattern;
    if (readOnly != null) data['read_only'] = readOnly;
    if (disabled != null) data['disabled'] = disabled;
    if (helpText != null) data['help_text'] = helpText;
    if (tooltip != null) data['tooltip'] = tooltip;

    return data;
  }

  // Convert to legacy Map format for backward compatibility
  Map<String, dynamic> toLegacyMap() {
    final data = <String, dynamic>{};

    if (validationRule != null) data['validationRule'] = validationRule;
    if (validationMessage != null) {
      data['validationMessage'] = validationMessage;
    }
    if (isDirty != null) data['isDirty'] = isDirty;
    if (isTouched != null) data['isTouched'] = isTouched;
    if (lastModified != null) {
      data['lastModified'] = lastModified!.toIso8601String();
    }
    if (source != null) data['source'] = source;
    if (customProperties != null) data.addAll(customProperties!);
    if (tags != null) data['tags'] = tags;
    if (format != null) data['format'] = format;
    if (maxLength != null) data['maxLength'] = maxLength;
    if (minLength != null) data['minLength'] = minLength;
    if (pattern != null) data['pattern'] = pattern;
    if (readOnly != null) data['readOnly'] = readOnly;
    if (disabled != null) data['disabled'] = disabled;
    if (helpText != null) data['helpText'] = helpText;
    if (tooltip != null) data['tooltip'] = tooltip;

    return data;
  }

  AdditionalFieldDataModel copyWith({
    String? validationRule,
    String? validationMessage,
    bool? isDirty,
    bool? isTouched,
    DateTime? lastModified,
    String? source,
    Map<String, dynamic>? customProperties,
    List<String>? tags,
    String? format,
    int? maxLength,
    int? minLength,
    String? pattern,
    bool? readOnly,
    bool? disabled,
    String? helpText,
    String? tooltip,
  }) {
    return AdditionalFieldDataModel(
      validationRule: validationRule ?? this.validationRule,
      validationMessage: validationMessage ?? this.validationMessage,
      isDirty: isDirty ?? this.isDirty,
      isTouched: isTouched ?? this.isTouched,
      lastModified: lastModified ?? this.lastModified,
      source: source ?? this.source,
      customProperties: customProperties ?? this.customProperties,
      tags: tags ?? this.tags,
      format: format ?? this.format,
      maxLength: maxLength ?? this.maxLength,
      minLength: minLength ?? this.minLength,
      pattern: pattern ?? this.pattern,
      readOnly: readOnly ?? this.readOnly,
      disabled: disabled ?? this.disabled,
      helpText: helpText ?? this.helpText,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  @override
  List<Object?> get props => [
    validationRule,
    validationMessage,
    isDirty,
    isTouched,
    lastModified,
    source,
    customProperties,
    tags,
    format,
    maxLength,
    minLength,
    pattern,
    readOnly,
    disabled,
    helpText,
    tooltip,
  ];

  @override
  String toString() {
    return 'AdditionalFieldDataModel(validationRule: $validationRule, validationMessage: $validationMessage, isDirty: $isDirty, isTouched: $isTouched, lastModified: $lastModified, source: $source, customProperties: $customProperties, tags: $tags, format: $format, maxLength: $maxLength, minLength: $minLength, pattern: $pattern, readOnly: $readOnly, disabled: $disabled, helpText: $helpText, tooltip: $tooltip)';
  }
}
