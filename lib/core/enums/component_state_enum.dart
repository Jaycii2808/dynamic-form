enum ComponentStateEnum {
  base('base'),
  focused('focused'),
  error('error'),
  enabled('enabled'),
  success('success');

  final String value;
  const ComponentStateEnum(this.value);

  static ComponentStateEnum fromString(dynamic value) {
    if (value == null) {
      return ComponentStateEnum.base;
    }
    if (value is! String) {
      return ComponentStateEnum.base;
    }
    for (final state in values) {
      if (state.value == value) {
        return state;
      }
    }
    return ComponentStateEnum.base;
  }
}
