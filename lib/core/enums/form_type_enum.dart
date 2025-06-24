enum FormTypeEnum {
  textFieldFormType,
  selectFormType,
  textAreaFormType,
  dateTimePickerFormType,
  dateTimeRangePickerFormType,
  dropdownFormType,
  checkboxGroupFormType,
  checkboxFormType,
  radioFormType,
  radioGroupFormType,
  sliderFormType,
  selectorFormType,
  switchFormType,
  textFieldTagsFormType,
  fileUploaderFormType,
  unknown;

  factory FormTypeEnum.fromJson(String? json) {
    try {
      return FormTypeEnum.values.firstWhere(
            (e) => e.toString().split('.').last == json,
        orElse: () => FormTypeEnum.unknown,
      );
    } catch (_) {
      return FormTypeEnum.unknown;
    }
  }

  String toJson() => toString().split('.').last;
}