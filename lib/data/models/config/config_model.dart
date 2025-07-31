import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:equatable/equatable.dart';

class Condition extends Equatable {
  final String componentId;
  final String type;
  final String rule;
  final dynamic expectedValue;
  final String errorMessage;

  const Condition({
    required this.componentId,
    required this.type,
    required this.rule,
    this.expectedValue,
    required this.errorMessage,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      componentId: json['component_id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
      expectedValue: json['expected_value'],
      errorMessage: json['error_message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'component_id': componentId,
      'type': type,
      'rule': rule,
      if (expectedValue != null) 'expected_value': expectedValue,
      'error_message': errorMessage,
    };
  }

  @override
  List<Object?> get props => [
    componentId,
    type,
    rule,
    expectedValue,
    errorMessage,
  ];
}

class Option extends Equatable {
  final String value;
  final String label;

  const Option({
    required this.value,
    required this.label,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }

  @override
  List<Object?> get props => [value, label];
}

class ConfigModel extends Equatable {
  final String? label;
  final String? placeholder;
  final bool? isRequired;
  final dynamic value;
  final StatesEnum? currentState;
  final String? errorText;
  final String? defaultFormat;
  final List<String>? initialTags;
  final List<String>? textSeparators;
  final String? pickerMode;
  final bool? selected;
  final bool? range;
  final double? min;
  final double? max;
  final List<double>? values;
  final String? prefix;
  final String? icon;
  final String? title;
  final String? buttonText;
  final List<String>? allowedExtensions;
  final String? action;
  final List<Condition>? conditions;
  final List<Option>? options;
  final String? hint;
  final String? height;
  final String? statusText;
  final dynamic validate;

  const ConfigModel({
    this.label,
    this.placeholder,
    this.isRequired,
    this.value,
    this.currentState,
    this.errorText,
    this.defaultFormat,
    this.initialTags,
    this.textSeparators,
    this.pickerMode,
    this.selected,
    this.range,
    this.min,
    this.max,
    this.values,
    this.prefix,
    this.icon,
    this.title,
    this.buttonText,
    this.allowedExtensions,
    this.action,
    this.conditions,
    this.options,
    this.hint,
    this.height,
    this.statusText,
    this.validate,
  });

  factory ConfigModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ConfigModel();
    }

    // Helper function to parse StatesEnum from string
    StatesEnum? parseState(dynamic stateValue) {
      if (stateValue == null) return null;
      final stateStr = stateValue.toString();
      switch (stateStr) {
        case 'StatesEnum.base':
        case 'base':
          return StatesEnum.base;
        case 'StatesEnum.error':
        case 'error':
          return StatesEnum.error;
        case 'StatesEnum.success':
        case 'success':
          return StatesEnum.success;
        case 'StatesEnum.focused':
        case 'focused':
          return StatesEnum.focused;
        case 'StatesEnum.disabled':
        case 'disabled':
          return StatesEnum.disabled;
        case 'StatesEnum.loading':
        case 'loading':
          return StatesEnum.loading;
        default:
          return StatesEnum.base;
      }
    }

    return ConfigModel(
      label: json['label'] as String?,
      placeholder: json['placeholder'] as String?,
      isRequired: json['is_required'] as bool?,
      value: json['value'],
      currentState: parseState(json['current_state']),
      errorText: json['error_text'] as String?,
      defaultFormat: json['default_format'] as String?,
      initialTags: (json['initial_tags'] as List<dynamic>?)?.cast<String>(),
      textSeparators: (json['text_separators'] as List<dynamic>?)
          ?.cast<String>(),
      pickerMode: json['picker_mode'] as String?,
      selected: json['selected'] as bool?,
      range: json['range'] as bool?,
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      values: (json['values'] as List<dynamic>?)?.cast<double>(),
      prefix: json['prefix'] as String?,
      icon: json['icon'] as String?,
      title: json['title'] as String?,
      buttonText: json['button_text'] as String?,
      allowedExtensions: (json['allowed_extensions'] as List<dynamic>?)
          ?.cast<String>(),
      action: json['action'] as String?,
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((e) => Condition.fromJson(e as Map<String, dynamic>))
          .toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList(),
      hint: json['hint'] as String?,
      height: json['height'] as String?,
      statusText: json['status_text'] as String?,
      validate: json['validate'],
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    if (label != null) result['label'] = label;
    if (placeholder != null) result['placeholder'] = placeholder;
    if (isRequired != null) result['is_required'] = isRequired;
    result['value'] = value; // Always include value, even if null
    if (currentState != null) result['current_state'] = currentState;
    if (errorText != null) result['error_text'] = errorText;
    if (defaultFormat != null) result['default_format'] = defaultFormat;
    if (initialTags != null) result['initial_tags'] = initialTags;
    if (textSeparators != null) result['text_separators'] = textSeparators;
    if (pickerMode != null) result['picker_mode'] = pickerMode;
    if (selected != null) result['selected'] = selected;
    if (range != null) result['range'] = range;
    if (min != null) result['min'] = min;
    if (max != null) result['max'] = max;
    if (values != null) result['values'] = values;
    if (prefix != null) result['prefix'] = prefix;
    if (icon != null) result['icon'] = icon;
    if (title != null) result['title'] = title;
    if (buttonText != null) result['button_text'] = buttonText;
    if (allowedExtensions != null) {
      result['allowed_extensions'] = allowedExtensions;
    }
    if (action != null) result['action'] = action;
    if (conditions != null) {
      result['conditions'] = conditions!.map((e) => e.toJson()).toList();
    }
    if (options != null) {
      result['options'] = options!.map((e) => e.toJson()).toList();
    }
    if (hint != null) result['hint'] = hint;
    if (height != null) result['height'] = height;
    if (statusText != null) result['status_text'] = statusText;
    if (validate != null) result['validate'] = validate;
    return result;
  }

  ConfigModel copyWith({
    String? label,
    String? placeholder,
    bool? isRequired,
    dynamic value,
    StatesEnum? currentState,
    String? errorText,
    String? defaultFormat,
    List<String>? initialTags,
    List<String>? textSeparators,
    String? pickerMode,
    bool? selected,
    bool? range,
    double? min,
    double? max,
    List<double>? values,
    String? prefix,
    String? icon,
    String? title,
    String? buttonText,
    List<String>? allowedExtensions,
    String? action,
    List<Condition>? conditions,
    List<Option>? options,
    String? hint,
    String? height,
    String? statusText,
    dynamic validate,
  }) {
    return ConfigModel(
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      isRequired: isRequired ?? this.isRequired,
      value: value ?? this.value,
      currentState: currentState ?? this.currentState,
      errorText: errorText ?? this.errorText,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      initialTags: initialTags ?? this.initialTags,
      textSeparators: textSeparators ?? this.textSeparators,
      pickerMode: pickerMode ?? this.pickerMode,
      selected: selected ?? this.selected,
      range: range ?? this.range,
      min: min ?? this.min,
      max: max ?? this.max,
      values: values ?? this.values,
      prefix: prefix ?? this.prefix,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      buttonText: buttonText ?? this.buttonText,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      action: action ?? this.action,
      conditions: conditions ?? this.conditions,
      options: options ?? this.options,
      hint: hint ?? this.hint,
      height: height ?? this.height,
      statusText: statusText ?? this.statusText,
      validate: validate ?? this.validate,
    );
  }

  @override
  List<Object?> get props => [
    label,
    placeholder,
    isRequired,
    value,
    currentState,
    errorText,
    defaultFormat,
    initialTags,
    textSeparators,
    pickerMode,
    selected,
    range,
    min,
    max,
    values,
    prefix,
    icon,
    title,
    buttonText,
    allowedExtensions,
    action,
    conditions,
    options,
    hint,
    height,
    statusText,
    validate,
  ];
}
