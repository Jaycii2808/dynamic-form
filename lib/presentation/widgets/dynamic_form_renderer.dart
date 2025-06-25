import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        return buildForm();
      },
    );
  }

  Widget buildForm() {
    final component = widget.component;
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return DynamicTextField(
          component: component,
          onComplete: (value) {
          },
        );
      case FormTypeEnum.selectFormType:
        return DynamicSelect(component: component);
      case FormTypeEnum.textAreaFormType:
        return DynamicTextArea(component: component, onComplete: (value) {});
      case FormTypeEnum.dateTimePickerFormType:
        return DynamicDateTimePicker(component: component, onComplete: (value) {});
      case FormTypeEnum.dateTimeRangePickerFormType:
        return DynamicDateTimeRangePicker(component: component, onComplete: (value) {});
      case FormTypeEnum.dropdownFormType:
        return DynamicDropdown(component: component);
      case FormTypeEnum.checkboxGroupFormType:
        return _buildCheckboxGroup(component);
      case FormTypeEnum.checkboxFormType:
        return DynamicCheckbox(component: component);
      case FormTypeEnum.radioFormType:
        return DynamicRadio(component: component);
      case FormTypeEnum.radioGroupFormType:
        return _buildRadioGroup(component);
      case FormTypeEnum.sliderFormType:
        return DynamicSlider(component: component);
      case FormTypeEnum.selectorFormType:
        return DynamicSelector(component: component, onComplete: (value) {});
      case FormTypeEnum.switchFormType:
        return DynamicSwitch(component: component, onComplete: (value) {});
      case FormTypeEnum.textFieldTagsFormType:
        return DynamicTextFieldTags(component: component, onComplete: (value) {});
      case FormTypeEnum.fileUploaderFormType:
        return DynamicFileUploader(component: component);
      case FormTypeEnum.buttonFormType:
        return const SizedBox.shrink();
      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRadioGroup(DynamicFormModel component) {
    final layout = component.config['layout']?.toString().toLowerCase() ?? 'row';
    final groupStyle = Map<String, dynamic>.from(component.style);
    final children = component.children ?? [];

    final widgets = children.map((item) {
      final style = {...groupStyle, ...item.style};
      final isSelected = item.config['value'] == true;
      final isEditable = item.config['editable'] != false;
      final label = item.config['label'] as String?;
      final hint = item.config['hint'] as String?;
      final iconName = item.config['icon'] as String?;

      Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
      Color borderColor = StyleUtils.parseColor(style['borderColor']);
      double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 20;
      double borderWidth = (style['borderWidth'] as num?)?.toDouble() ?? 2;
      Color iconColor = StyleUtils.parseColor(style['iconColor']);
      double width = (style['width'] as num?)?.toDouble() ?? 40;
      double height = (style['height'] as num?)?.toDouble() ?? 40;
      EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);

      if (isSelected) {
        borderWidth += 2;
      }

      if (!isEditable) {
        bgColor = StyleUtils.parseColor('#e0e0e0');
        borderColor = StyleUtils.parseColor('#e0e0e0');
        iconColor = StyleUtils.parseColor('#bdbdbd');
      }

      Widget? iconWidget;
      if (iconName != null) {
        final iconData = mapIconNameToIconData(iconName);
        if (iconData != null) {
          iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
        }
      }

      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEditable
            ? () {
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(componentId: item.id, value: true),
                );
              }
            : null,
        child: Container(
          margin: margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: borderWidth),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      iconWidget ??
                      (isSelected
                          ? Container(
                              width: width * 0.5,
                              height: height * 0.5,
                              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                            )
                          : null),
                ),
              ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isEditable ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      margin: StyleUtils.parsePadding(groupStyle['margin']),
      padding: StyleUtils.parsePadding(groupStyle['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.config['hint'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                component.config['hint'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          layout == 'row'
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: widgets),
                )
              : Column(children: widgets),
        ],
      ),
    );
  }

  Widget _buildCheckboxGroup(DynamicFormModel component) {
    component.config['layout']?.toString().toLowerCase() ?? 'row';
    final groupStyle = Map<String, dynamic>.from(component.style);

    return Container(
      margin: StyleUtils.parsePadding(groupStyle['margin']),
      padding: StyleUtils.parsePadding(groupStyle['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
