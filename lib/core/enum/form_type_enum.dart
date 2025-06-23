enum FormTypeEnum {
  textField,
  select,
  datePicker,
  textArea,
  datetimePicker,
  dropdown,
  checkboxGroup,
  checkbox,
  radio,
  radioGroup,
  slider,
  selector,
  switchComponent,
  textFieldTags,
  fileUploader,
  container;

  static FormTypeEnum fromJson(String type) {
    switch (type.toLowerCase()) {
      case 'textfield':
        return FormTypeEnum.textField;
      case 'select':
        return FormTypeEnum.select;
      case 'datepicker':
        return FormTypeEnum.datePicker;
      case 'textarea':
        return FormTypeEnum.textArea;
      case 'datetime_picker':
        return FormTypeEnum.datetimePicker;
      case 'dropdown':
        return FormTypeEnum.dropdown;
      case 'checkbox_group':
        return FormTypeEnum.checkboxGroup;
      case 'checkbox':
        return FormTypeEnum.checkbox;
      case 'radio':
        return FormTypeEnum.radio;
      case 'radio_group':
        return FormTypeEnum.radioGroup;
      case 'slider':
        return FormTypeEnum.slider;
      case 'selector':
        return FormTypeEnum.selector;
      case 'switch':
        return FormTypeEnum.switchComponent;
      case 'textfield_tags':
        return FormTypeEnum.textFieldTags;
      case 'file_uploader':
        return FormTypeEnum.fileUploader;
      default:
        return FormTypeEnum.container;
    }
  }

  String toJson() {
    switch (this) {
      case FormTypeEnum.textField:
        return 'textfield';
      case FormTypeEnum.select:
        return 'select';
      case FormTypeEnum.datePicker:
        return 'datepicker';
      case FormTypeEnum.textArea:
        return 'textarea';
      case FormTypeEnum.datetimePicker:
        return 'datetime_picker';
      case FormTypeEnum.dropdown:
        return 'dropdown';
      case FormTypeEnum.checkboxGroup:
        return 'checkbox_group';
      case FormTypeEnum.checkbox:
        return 'checkbox';
      case FormTypeEnum.radio:
        return 'radio';
      case FormTypeEnum.radioGroup:
        return 'radio_group';
      case FormTypeEnum.slider:
        return 'slider';
      case FormTypeEnum.selector:
        return 'selector';
      case FormTypeEnum.switchComponent:
        return 'switch';
      case FormTypeEnum.textFieldTags:
        return 'textfield_tags';
      case FormTypeEnum.fileUploader:
        return 'file_uploader';
      case FormTypeEnum.container:
        return 'container';
    }
  }
}