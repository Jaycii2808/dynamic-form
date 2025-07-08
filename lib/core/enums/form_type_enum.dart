enum FormTypeEnum {
  textFieldFormType,
  selectFormType,
  textAreaFormType,
  dateTimePickerFormType,
  dateTimeRangePickerFormType,
  dropdownFormType,
  checkboxFormType,
  radioFormType,

  sliderFormType,
  selectorButtonFormType,
  switchFormType,
  textFieldTagsFormType,
  fileUploaderFormType,
  buttonFormType,
  container,
  unknown;

  factory FormTypeEnum.fromJson(String? json) {
    try {
      // Handle legacy textfield name
      if (json == 'textfield') return FormTypeEnum.textFieldFormType;

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
