import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_checkbox.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_range_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_dropdown.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_file_uploader.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_radio.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_select.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_selector.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_slider.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_switch.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_area.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field_tags.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

IconData? mapIconNameToIconData(String name) {
  return IconTypeEnum.fromString(name).toIconData();
}

class DynamicFormRenderer extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicFormRenderer({super.key, required this.component});

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  late StringTagController<String> tagController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildForm();
  }

  Widget buildForm() {
    final component = widget.component;
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return DynamicTextField(component: component);
      case FormTypeEnum.selectFormType:
        return DynamicSelect(component: component);
      case FormTypeEnum.textAreaFormType:
        return DynamicTextArea(component: component);
      case FormTypeEnum.dateTimePickerFormType:
        return DynamicDateTimePicker(component: component);
      case FormTypeEnum.dateTimeRangePickerFormType:
        return DynamicDateTimeRangePicker(component: component);
      case FormTypeEnum.dropdownFormType:
        return DynamicDropdown(component: component);
      case FormTypeEnum.checkboxGroupFormType:
        return const SizedBox.shrink();
      case FormTypeEnum.checkboxFormType:
        return DynamicCheckbox(component: component);
      case FormTypeEnum.radioFormType:
        return DynamicRadio(component: component);
      case FormTypeEnum.radioGroupFormType:
        return const SizedBox.shrink();
      case FormTypeEnum.sliderFormType:
        return DynamicSlider(component: component);
      case FormTypeEnum.selectorFormType:
        return DynamicSelector(component: component);
      case FormTypeEnum.switchFormType:
        return DynamicSwitch(component: component);
      case FormTypeEnum.textFieldTagsFormType:
        return DynamicTextFieldTags(component: component);
      case FormTypeEnum.fileUploaderFormType:
        return DynamicFileUploader(component: component);
      case FormTypeEnum.buttonFormType:
        return const SizedBox.shrink();
      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }
}
