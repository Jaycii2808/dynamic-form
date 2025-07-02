enum FormStateEnum {
  focused('focused'),
  error('error'),
  base('base'),
  success('success');

  final String value;

  const FormStateEnum(this.value);

  static FormStateEnum? fromString(String? value) {
    if (value == null) return null;
    return values.firstWhere(
          (state) => state.value == value,
      orElse: () => throw Exception('Unknown border state: $value'),
    );
  }
}