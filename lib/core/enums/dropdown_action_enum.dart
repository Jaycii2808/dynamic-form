enum DropdownActionOptionsEnum {
  next('continue'),
  goto('goto'),
  submit('submit');

  const DropdownActionOptionsEnum(this.value);
  final String value;

  static DropdownActionOptionsEnum fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'continue':
        return DropdownActionOptionsEnum.next;
      case 'goto':
        return DropdownActionOptionsEnum.goto;
      case 'submit':
        return DropdownActionOptionsEnum.submit;
      default:
        return DropdownActionOptionsEnum.next;
    }
  }

  @override
  String toString() => value;
}
