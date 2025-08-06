enum FormTypeEnum {
  textFieldFormType,
  textAreaFormType,
  dateTimePickerFormType,
  dateTimeRangePickerFormType,
  selectorButtonFormType,
  switchFormType,
  textFieldTagsFormType,
  buttonFormType,
  container,
  dropdownFormType,
  //checkboxFormType,
  //radioFormType,
  //selectFormType,
  //sliderFormType,
  //fileUploaderFormType,
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
