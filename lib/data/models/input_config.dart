class InputConfig {
  final String? value;
  final String currentState;
  final String? errorText;
  final String? label;
  final String? placeholder;
  final bool editable;
  final bool disabled;
  final bool readOnly;

  const InputConfig({
    this.value,
    this.currentState = 'base',
    this.errorText,
    this.label,
    this.placeholder,
    this.editable = true,
    this.disabled = false,
    this.readOnly = false,
  });

  factory InputConfig.fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      print(
        '[InputConfig.fromJson] map is null, returning default InputConfig',
      );
      return const InputConfig();
    }
    print('[InputConfig.fromJson] incoming map: ' + map.toString());
    String? parseString(dynamic v, [String? fallback = '']) {
      if (v == null) return fallback;
      if (v is String) return v;
      if (v is List || v is Map) return fallback;
      return v.toString();
    }

    dynamic valueField = map['value'];
    print('[InputConfig.fromJson] value field: ' + valueField.toString());
    String? valueString;
    if (valueField is String) {
      valueString = valueField;
    } else if (valueField is List) {
      print(
        '[InputConfig.fromJson] value is a List, setting valueString to null',
      );
      valueString = null;
    } else if (valueField != null) {
      valueString = valueField.toString();
    }
    final currentState = parseString(map['current_state'], 'base') ?? 'base';
    print(
      '[InputConfig.fromJson] current_state: ' +
          map['current_state'].toString() +
          ', parsed: ' +
          currentState.toString(),
    );
    final errorText = map['error_text'] != null
        ? parseString(map['error_text'])
        : null;
    print(
      '[InputConfig.fromJson] error_text: ' +
          map['error_text'].toString() +
          ', parsed: ' +
          errorText.toString(),
    );
    final label = map['label'] != null ? parseString(map['label']) : null;
    print(
      '[InputConfig.fromJson] label: ' +
          map['label'].toString() +
          ', parsed: ' +
          label.toString(),
    );
    final placeholder = map['placeholder'] != null
        ? parseString(map['placeholder'])
        : null;
    print(
      '[InputConfig.fromJson] placeholder: ' +
          map['placeholder'].toString() +
          ', parsed: ' +
          placeholder.toString(),
    );
    final editable = map['editable'] is bool ? map['editable'] : true;
    print(
      '[InputConfig.fromJson] editable: ' +
          map['editable'].toString() +
          ', parsed: ' +
          editable.toString(),
    );
    final disabled = map['disabled'] is bool ? map['disabled'] : false;
    print(
      '[InputConfig.fromJson] disabled: ' +
          map['disabled'].toString() +
          ', parsed: ' +
          disabled.toString(),
    );
    final readOnly = map['readOnly'] is bool ? map['readOnly'] : false;
    print(
      '[InputConfig.fromJson] readOnly: ' +
          map['readOnly'].toString() +
          ', parsed: ' +
          readOnly.toString(),
    );
    print(
      '[InputConfig.fromJson] FINAL: value=$valueString, currentState=$currentState, errorText=$errorText, label=$label, placeholder=$placeholder, editable=$editable, disabled=$disabled, readOnly=$readOnly',
    );
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
