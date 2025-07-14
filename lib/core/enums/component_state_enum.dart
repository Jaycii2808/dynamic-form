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
      print('[ComponentStateEnum.fromString] value is null, returning base');
      return ComponentStateEnum.base;
    }
    if (value is! String) {
      print(
        '[ComponentStateEnum.fromString] value is not a String: '
                ' [33m' +
            value.toString() +
            '\u001b[0m, returning base',
      );
      return ComponentStateEnum.base;
    }
    for (final state in values) {
      if (state.value == value) {
        print('[ComponentStateEnum.fromString] matched: $value');
        return state;
      }
    }
    print(
      '[ComponentStateEnum.fromString] unknown value: $value, returning base',
    );
    return ComponentStateEnum.base;
  }
}
