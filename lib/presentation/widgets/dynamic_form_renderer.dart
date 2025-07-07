import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_button.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_checkbox.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_range_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_dropdown.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_file_uploader.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_radio.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_select.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_selector_button.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_slider.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_switch.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_area.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field_tags.dart';
import 'package:dynamic_form_bi/presentation/screens/form_preview_screen.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

IconData? mapIconNameToIconData(String name) {
  return IconTypeEnum.fromString(name).toIconData();
}

class FormContainer extends StatelessWidget {
  final List<Widget> children;

  const FormContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: FocusScope(autofocus: false, child: Column(children: children)),
    );
  }
}

class DynamicFormRenderer extends StatefulWidget {
  final DynamicFormModel component;
  final DynamicFormPageModel? page;
  final VoidCallback? onCompleted;
  final Function(String componentId, dynamic value)? onFieldChanged;

  const DynamicFormRenderer({
    super.key,
    required this.component,
    this.page,
    this.onCompleted,
    this.onFieldChanged,
  });

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  void handleFormFieldUpdate(
    BuildContext context,
    DynamicFormModel component,
    dynamic value,
  ) {
    if (value != null) {
      component.config[ValueKeyEnum.value.key] = value[ValueKeyEnum.value.key];
      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(componentId: component.id, value: value),
      );
    } else {
      debugPrint("Error: No value received");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildComponents(widget.component);
  }

  Widget _buildComponents(DynamicFormModel component) {
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return DynamicTextField(component: component);
      case FormTypeEnum.selectFormType:
        return DynamicSelect(component: component);
      case FormTypeEnum.textAreaFormType:
        return DynamicTextArea(
          component: component,
          onComplete: (value) =>
              handleFormFieldUpdate(context, component, value),
        );
      case FormTypeEnum.dateTimePickerFormType:
        return DynamicDateTimePicker(
          component: component,
          onComplete: (value) =>
              handleFormFieldUpdate(context, component, value),
        );
      case FormTypeEnum.dateTimeRangePickerFormType:
        return DynamicDateTimeRangePicker(
          component: component,
          onComplete: (value) =>
              handleFormFieldUpdate(context, component, value),
        );
      case FormTypeEnum.dropdownFormType:
        return DynamicDropdown(component: component);
      case FormTypeEnum.checkboxFormType:
        return DynamicCheckbox(component: component);
      case FormTypeEnum.radioFormType:
        return DynamicRadio(component: component);
      case FormTypeEnum.sliderFormType:
        return DynamicSlider(component: component);
      case FormTypeEnum.selectorButtonFormType:
        return DynamicSelectorButton(component: component);
      case FormTypeEnum.switchFormType:
        return DynamicSwitch(component: component);
      case FormTypeEnum.textFieldTagsFormType:
        return DynamicTextFieldTags(component: component);
      case FormTypeEnum.fileUploaderFormType:
        return DynamicFileUploader(component: component);
      case FormTypeEnum.buttonFormType:
        return DynamicButton(
          component: component,
          onAction: _handleButtonAction,
        );
      case FormTypeEnum.container:
        return _buildContainerComponent(component);
      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContainerComponent(DynamicFormModel component) {
    final style = component.style;
    final label = ComponentUtils.getLabel(component);

    final containerContent = Container(
      key: Key(component.id),
      margin: StyleUtils.parsePadding(style['margin']),
      padding: StyleUtils.parsePadding(style['padding']),
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(style['background_color']),
        border: style['border_color'] != null
            ? Border.all(
                color: StyleUtils.parseColor(style['border_color']),
                width: ComponentUtils.getStyleValue<num>(
                  style,
                  'border_width',
                  1.0,
                ).toDouble(),
              )
            : null,
        borderRadius: StyleUtils.parseBorderRadius(style['border_radius']),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) _buildLabel(label, style),

          if (component.children != null)
            ...component.children!.map(
              (child) => DynamicFormRenderer(
                component: child,
                page: widget.page,
                onCompleted: widget.onCompleted,
                onFieldChanged: widget.onFieldChanged,
              ),
            ),
        ],
      ),
    );

    final action = component.config['onTapAction'];
    if (action is String && action.isNotEmpty) {
      return GestureDetector(
        onTap: () => _handleButtonAction(action, component.config['data']),
        behavior: HitTestBehavior.opaque,
        child: containerContent,
      );
    }

    return containerContent;
  }

  Widget _buildLabel(String label, Map<String, dynamic> style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: StyleUtils.parseColor(style['label_color']),
          fontSize: StyleUtils.parseFontSize(style['font_size']),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleButtonAction(String action, Map<String, dynamic>? data) {
    try {
      switch (ButtonAction.fromString(action)) {
        case ButtonAction.previewForm:
          _handlePreviewAction();
          break;
        case ButtonAction.submitForm:
          _handleSubmitAction(data);
          break;
        case ButtonAction.resetForm:
          _handleResetAction();
          break;
      }
    } catch (e) {
      debugPrint('Error handling button action $action: $e');
    }
  }

  void _handlePreviewAction() {
    final page = widget.page;
    if (page == null) {
      debugPrint('❌ No page available for preview');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<DynamicFormBloc>(),
          child: FormPreviewScreen(
            page: page,
            title: page.title.isNotEmpty ? page.title : 'Form Preview',
          ),
        ),
      ),
    );
  }

  void _handleSubmitAction(Map<String, dynamic>? data) {
    if (_isFormComplete()) {
      widget.onCompleted?.call();
      debugPrint('✅ Form completed successfully');
    } else {
      debugPrint('❌ Form incomplete - missing required fields');
    }
  }

  void _handleResetAction() {
    debugPrint('🔄 Resetting form');
  }

  bool _isFormComplete() {
    final page = widget.page;
    if (page == null) return false;

    for (final component in page.components) {
      if (ComponentUtils.isRequired(component)) {
        final value = component.config['value'];

        if (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty)) {
          debugPrint('Component ${component.id} is required but has no value.');
          return false;
        }
      }
    }
    return true;
  }
}
