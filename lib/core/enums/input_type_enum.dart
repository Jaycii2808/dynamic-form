enum InputTypeEnum {
  email('email'),
  tel('tel'),
  password('password'),
  multiline('multiline');

  final String value;
  const InputTypeEnum(this.value);

  static InputTypeEnum fromString(String? value) {
    if (value == null) return InputTypeEnum.multiline;
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => InputTypeEnum.multiline,
    );
  }
}
