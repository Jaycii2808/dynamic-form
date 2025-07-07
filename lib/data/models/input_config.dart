class InputConfig {
  final String value;
  final String currentState;
  final String? errorText;
  final String? label;
  final String? placeholder;
  final bool editable;
  final bool disabled;
  final bool readOnly;

  const InputConfig({
    this.value = '',
    this.currentState = 'base',
    this.errorText,
    this.label,
    this.placeholder,
    this.editable = true,
    this.disabled = false,
    this.readOnly = false,
  });

  factory InputConfig.fromJson(Map<String, dynamic>? map) {
    if (map == null) return const InputConfig();
    return InputConfig(
      value: map['value']?.toString() ?? '',
      currentState: map['current_state']?.toString() ?? 'base',
      errorText: map['error_text']?.toString(),
      label:
          map['label']?.toString() ??
          '', // Đảm bảo label không null, trả về chuỗi rỗng nếu không có giá trị
      placeholder: map['placeholder']?.toString(),
      editable: map['editable'] is bool ? map['editable'] : true,
      disabled: map['disabled'] is bool ? map['disabled'] : false,
      readOnly: map['readOnly'] is bool ? map['readOnly'] : false,
    );
  }
}
