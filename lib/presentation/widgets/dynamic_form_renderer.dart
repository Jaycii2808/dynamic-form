import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_button.dart';
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
import 'package:dynamic_form_bi/presentation/screens/form_preview_screen.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textfield_tags/textfield_tags.dart';

IconData? mapIconNameToIconData(String name) {
  return IconTypeEnum.fromString(name).toIconData();
}

class FormContainer extends StatelessWidget {
  final List<Widget> children;

  const FormContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: FocusScope(autofocus: false, child: Column(children: children)),
    );
  }
}

class FormWrapper extends StatelessWidget {
  final Widget child;

  const FormWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: FocusScope(autofocus: false, child: child),
    );
  }
}

class UnfocusOnTapOutside extends StatelessWidget {
  final Widget child;

  const UnfocusOnTapOutside({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: child,
      ),
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
  late StringTagController<String> tagController;

  // Cache component properties to avoid recalculation in build
  late final String _componentId;
  late final Map<String, dynamic> _componentConfig;
  late final bool _isRequired;
  late final bool _isDisabled;

  @override
  void initState() {
    super.initState();
    _initializeComponentProps();
  }

  void _initializeComponentProps() {
    _componentId = widget.component.id;
    _componentConfig = widget.component.config;
    _isRequired = ComponentUtils.isRequired(widget.component);
    _isDisabled = ComponentUtils.isComponentDisabled(widget.component);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleButtonAction(String action, Map<String, dynamic>? data) {
    try {
      switch (action) {
        case 'preview_form':
          _handlePreviewAction();
          break;
        case 'submit_form':
          _handleSubmitAction(data);
          break;
        case 'reset_form':
          _handleResetAction();
          break;
        default:
          debugPrint('Unknown action: $action');
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
    // Check if all required fields are completed
    if (_checkFormCompletion()) {
      widget.onCompleted?.call();
      debugPrint('✅ Form completed successfully');
    } else {
      debugPrint('❌ Form incomplete - missing required fields');
    }
  }

  void _handleResetAction() {
    // Reset form fields logic would go here
    debugPrint('🔄 Resetting form');
  }

  bool _checkFormCompletion() {
    final page = widget.page;
    if (page == null) return false;

    // Check if all required components have values
    for (final component in page.components) {
      if (ComponentUtils.isRequired(component)) {
        final value = component.config['value'];
        if (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  void _notifyFieldChanged(dynamic value) {
    widget.onFieldChanged?.call(_componentId, value);
  }

  @override
  Widget build(BuildContext context) {
    return buildForm();
  }

  Widget buildForm() {
    // Use cached component to avoid repeated property access
    final component = widget.component;

    // Performance optimization: Build component based on type
    // Using const enum for better performance
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
      case FormTypeEnum.checkboxFormType:
        return DynamicCheckbox(component: component);
      case FormTypeEnum.radioFormType:
        return DynamicRadio(component: component);
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
        return DynamicButton(
          component: component,
          onAction: _handleButtonAction,
        );
      case FormTypeEnum.container:
        return _buildContainer(component);
      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }

  /// Build container with performance optimization and null safety
  Widget _buildContainer(DynamicFormModel component) {
    // Cache style properties to avoid repeated map lookups
    final style = component.style;
    final config = component.config;

    // Get label with null safety
    final label = ComponentUtils.getLabel(component);

    return Container(
      key: Key(_componentId),
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
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label,
                style: TextStyle(
                  color: StyleUtils.parseColor(style['label_color']),
                  fontSize: StyleUtils.parseFontSize(style['font_size']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Build children with null safety
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
  }
}
