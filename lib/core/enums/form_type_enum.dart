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
  shortAnswerFormType,
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
      case FormTypeEnum.shortAnswerFormType:
        return EmailFieldTypeEnum.text;
      case FormTypeEnum.buttonFormType:
      case FormTypeEnum.container:
      case FormTypeEnum.unknown:
        return EmailFieldTypeEnum.unknown;
    }
  }
}

/// Enum for short answer validation types
enum ShortAnswerValidationType {
  number,
  text,
  length,
  regularExpression;

  String get displayName {
    switch (this) {
      case ShortAnswerValidationType.number:
        return 'Number';
      case ShortAnswerValidationType.text:
        return 'Text';
      case ShortAnswerValidationType.length:
        return 'Length';
      case ShortAnswerValidationType.regularExpression:
        return 'Regular expression';
    }
  }
}

/// Enum for number validation actions
enum NumberValidationAction {
  greaterThan,
  lessThan,
  equalTo;

  String get displayName {
    switch (this) {
      case NumberValidationAction.greaterThan:
        return 'Greater than';
      case NumberValidationAction.lessThan:
        return 'Less than';
      case NumberValidationAction.equalTo:
        return 'Equal to';
    }
  }
}

/// Enum for text validation actions
enum TextValidationAction {
  contains,
  doesNotContain,
  emailAddress,
  url;

  String get displayName {
    switch (this) {
      case TextValidationAction.contains:
        return 'Contains';
      case TextValidationAction.doesNotContain:
        return 'Does not contain';
      case TextValidationAction.emailAddress:
        return 'Email address';
      case TextValidationAction.url:
        return 'URL';
    }
  }
}

/// Enum for length validation types
enum LengthValidationType {
  minimumCharacterCount,
  maximumCharacterCount;

  String get displayName {
    switch (this) {
      case LengthValidationType.minimumCharacterCount:
        return 'Minimum character count';
      case LengthValidationType.maximumCharacterCount:
        return 'Maximum character count';
    }
  }
}

/// Enum for regex validation actions
enum RegexValidationAction {
  contains,
  doesNotContain,
  matches,
  doesNotMatch;

  String get displayName {
    switch (this) {
      case RegexValidationAction.contains:
        return 'Contains';
      case RegexValidationAction.doesNotContain:
        return 'Does not contain';
      case RegexValidationAction.matches:
        return 'Matches';
      case RegexValidationAction.doesNotMatch:
        return 'Does not match';
    }
  }
}
