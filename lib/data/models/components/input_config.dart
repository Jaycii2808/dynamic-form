import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';

class InputConfig {
  final String? value;
  final StatesEnum currentState;
  final String? errorText;
  final String? label;
  final String? placeholder;
  final bool editable;
  final bool disabled;
  final bool readOnly;

  const InputConfig({
    this.value,
    this.currentState = StatesEnum.base,
    this.errorText,
    this.label,
    this.placeholder,
    this.editable = true,
    this.disabled = false,
    this.readOnly = false,
  });

  factory InputConfig.fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return const InputConfig();
    }
    String? parseString(dynamic v, [String? fallback = '']) {
      if (v == null) return fallback;
      if (v is String) return v;
      if (v is List || v is Map) return fallback;
      return v.toString();
    }

    // Parse current_state as StatesEnum
    StatesEnum parseCurrentState(dynamic value) {
      if (value == null) return StatesEnum.base;
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'base':
            return StatesEnum.base;
          case 'error':
            return StatesEnum.error;
          case 'success':
            return StatesEnum.success;
          case 'focused':
            return StatesEnum.focused;
          case 'disabled':
            return StatesEnum.disabled;
          case 'loading':
            return StatesEnum.loading;
          default:
            return StatesEnum.base;
        }
      }
      return StatesEnum.base;
    }

    dynamic valueField = map['value'];
    String? valueString;
    if (valueField is String) {
      valueString = valueField;
    } else if (valueField is List) {
      valueString = null;
    } else if (valueField != null) {
      valueString = valueField.toString();
    }

    final currentState = parseCurrentState(map['current_state']);
    final errorText = map['error_text'] != null
        ? parseString(map['error_text'])
        : null;
    final label = map['label'] != null ? parseString(map['label']) : null;
    final placeholder = map['placeholder'] != null
        ? parseString(map['placeholder'])
        : null;
    final editable = map['editable'] is bool ? map['editable'] : true;
    final disabled = map['disabled'] is bool ? map['disabled'] : false;
    final readOnly = map['readOnly'] is bool ? map['readOnly'] : false;
    return InputConfig(
      value: valueString,
      currentState: currentState,
      errorText: errorText,
      label: label,
      placeholder: placeholder,
      editable: editable,
      disabled: disabled,
      readOnly: readOnly,
    );
  }
}
