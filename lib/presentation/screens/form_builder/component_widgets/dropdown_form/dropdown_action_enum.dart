enum DropdownActionOptionsEnum {
  next,
  goto,
  submit;

  static DropdownActionOptionsEnum fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'next':
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
  String toString() {
    switch (this) {
      case DropdownActionOptionsEnum.next:
        return 'next';
      case DropdownActionOptionsEnum.goto:
        return 'goto';
      case DropdownActionOptionsEnum.submit:
        return 'submit';
    }
  }
}
