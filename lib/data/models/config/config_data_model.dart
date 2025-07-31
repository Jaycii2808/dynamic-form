import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/date_time_range/date_time_range_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';

/// Model for config data
class ConfigDataModel extends Equatable {
  final dynamic value;
  final StatesEnum? currentState;
  final String? errorText;
  final String? placeholder;
  final bool? required;
  final String? type;
  final DateTimeRangeModel? dateTimeRange;
  final Map<String, dynamic>? customProperties;

  const ConfigDataModel({
    this.value,
    this.currentState,
    this.errorText,
    this.placeholder,
    this.required,
    this.type,
    this.dateTimeRange,
    this.customProperties,
  });

  factory ConfigDataModel.fromJson(Map<String, dynamic> json) {
    // Convert string to StatesEnum
    StatesEnum? parseState(String? stateStr) {
      if (stateStr == null) return null;
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

    return ConfigDataModel(
      value: json['value'],
      currentState: parseState(json['current_state'] as String?),
      errorText: json['error_text'] as String?,
      placeholder: json['placeholder'] as String?,
      required: json['required'] as bool?,
      type: json['type'] as String?,
      dateTimeRange: json['dateTimeRange'] != null
          ? DateTimeRangeModel.fromJson(
              json['dateTimeRange'] as Map<String, dynamic>,
            )
          : null,
      customProperties: json['customProperties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'current_state': currentState?.toString(),
      'error_text': errorText,
      'placeholder': placeholder,
      'required': required,
      'type': type,
      'dateTimeRange': dateTimeRange?.toJson(),
      'customProperties': customProperties,
    };
  }

  @override
  List<Object?> get props => [
    value,
    currentState,
    errorText,
    placeholder,
    required,
    type,
    dateTimeRange,
    customProperties,
  ];

  ConfigDataModel copyWith({
    dynamic value,
    StatesEnum? currentState,
    String? errorText,
    String? placeholder,
    bool? required,
    String? type,
    DateTimeRangeModel? dateTimeRange,
    Map<String, dynamic>? customProperties,
  }) {
    return ConfigDataModel(
      value: value ?? this.value,
      currentState: currentState ?? this.currentState,
      errorText: errorText ?? this.errorText,
      placeholder: placeholder ?? this.placeholder,
      required: required ?? this.required,
      type: type ?? this.type,
      dateTimeRange: dateTimeRange ?? this.dateTimeRange,
      customProperties: customProperties ?? this.customProperties,
    );
  }
}
