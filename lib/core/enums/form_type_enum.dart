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

/// Enum for email field display types
enum EmailFieldTypeEnum {
  text,
  textarea,
  date,
  dateRange,
  boolean,
  tags,
  dropdown,
  number,
  unknown;

  /// Get display name for email
  String get displayName {
    switch (this) {
      case EmailFieldTypeEnum.text:
        return 'Text Field';
      case EmailFieldTypeEnum.textarea:
        return 'Text Area';
      case EmailFieldTypeEnum.date:
        return 'Date & Time';
      case EmailFieldTypeEnum.dateRange:
        return 'Date Range';
      case EmailFieldTypeEnum.boolean:
        return 'Yes/No';
      case EmailFieldTypeEnum.tags:
        return 'Tags';
      case EmailFieldTypeEnum.dropdown:
        return 'Dropdown';
      case EmailFieldTypeEnum.number:
        return 'Number';
      case EmailFieldTypeEnum.unknown:
        return 'Field';
    }
  }

  /// Convert from FormTypeEnum
  static EmailFieldTypeEnum fromFormType(FormTypeEnum formType) {
    switch (formType) {
      case FormTypeEnum.textFieldFormType:
        return EmailFieldTypeEnum.text;
      case FormTypeEnum.textAreaFormType:
        return EmailFieldTypeEnum.textarea;
      case FormTypeEnum.dateTimePickerFormType:
        return EmailFieldTypeEnum.date;
      case FormTypeEnum.dateTimeRangePickerFormType:
        return EmailFieldTypeEnum.dateRange;
      case FormTypeEnum.selectorButtonFormType:
      case FormTypeEnum.switchFormType:
        return EmailFieldTypeEnum.boolean;
      case FormTypeEnum.textFieldTagsFormType:
        return EmailFieldTypeEnum.tags;
      case FormTypeEnum.dropdownFormType:
        return EmailFieldTypeEnum.dropdown;
      case FormTypeEnum.buttonFormType:
      case FormTypeEnum.container:
      case FormTypeEnum.unknown:
        return EmailFieldTypeEnum.unknown;
    }
  }
}
