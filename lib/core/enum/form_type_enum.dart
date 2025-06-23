enum FormTypeEnum {
  textField,
  select,
  textArea,
  dateTimePicker,
  dropdown,
  checkBoxGroup,
  checkBox,
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
      case 'textField':
        return FormTypeEnum.textField;
      case 'select':
        return FormTypeEnum.select;
      case 'textArea':
        return FormTypeEnum.textArea;
      case 'datetime_picker':
        return FormTypeEnum.dateTimePicker;
      case 'dropdown':
        return FormTypeEnum.dropdown;
      case 'checkBoxGroup':
        return FormTypeEnum.checkBoxGroup;
      case 'checkBox':
        return FormTypeEnum.checkBox;
      case 'radio':
        return FormTypeEnum.radio;
      case 'radioGroup':
        return FormTypeEnum.radioGroup;
      case 'slider':
        return FormTypeEnum.slider;
      case 'selector':
        return FormTypeEnum.selector;
      case 'switch':
        return FormTypeEnum.switchComponent;
      case 'textFieldTags':
        return FormTypeEnum.textFieldTags;
      case 'fileUploader':
        return FormTypeEnum.fileUploader;
      default:
        return FormTypeEnum.container;
    }
  }

  String toJson() {
    switch (this) {
      case FormTypeEnum.textField:
        return 'textField';
      case FormTypeEnum.select:
        return 'select';
      case FormTypeEnum.textArea:
        return 'textArea';
      case FormTypeEnum.dateTimePicker:
        return 'datetime_picker';
      case FormTypeEnum.dropdown:
        return 'dropdown';
      case FormTypeEnum.checkBoxGroup:
        return 'checkBoxGroup';
      case FormTypeEnum.checkBox:
        return 'checkBox';
      case FormTypeEnum.radio:
        return 'radio';
      case FormTypeEnum.radioGroup:
        return 'radioGroup';
      case FormTypeEnum.slider:
        return 'slider';
      case FormTypeEnum.selector:
        return 'selector';
      case FormTypeEnum.switchComponent:
        return 'switch';
      case FormTypeEnum.textFieldTags:
        return 'textFieldTags';
      case FormTypeEnum.fileUploader:
        return 'fileUploader';
      case FormTypeEnum.container:
        return 'container';
    }
  }
}