import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/button_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/components/component_value_update_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_switch/dynamic_switch_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_button.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_range_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_selector_button.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_switch.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_area.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field_tags.dart';
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
  final Function(String action, ButtonActionDataModel? data)? onButtonAction;

  const DynamicFormRenderer({
    super.key,
    required this.component,
    this.page,
    this.onCompleted,
    this.onFieldChanged,
    this.onButtonAction,
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
      if (widget.onFieldChanged != null) {
        widget.onFieldChanged!(component.id, value);
      } else {
        // Create ComponentValueUpdateModel from simple value
        final updateModel = ComponentValueUpdateModel.create(
          componentId: component.id,
          value: value,
        );

        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(componentId: component.id, value: updateModel),
        );
      }
    } else {
      debugPrint("Error: No value received");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildComponents(widget.component);
  }

  Widget _buildComponents(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormRenderer] Building component: ${component.id}, type: ${component.type}',
    );
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return _buildTextFieldBlocProvider(component);
      case FormTypeEnum.textAreaFormType:
        return _buildTextAreaBlocProvider(component);
      case FormTypeEnum.dateTimePickerFormType:
        return _buildDateTimePickerBlocProvider(component);
      case FormTypeEnum.dateTimeRangePickerFormType:
        return _buildDateTimeRangePickerBlocProvider(component);
      case FormTypeEnum.selectorButtonFormType:
        return _buildSelectorButtonBlocProvider(component);
      case FormTypeEnum.switchFormType:
        return _buildSwitchBlocProvider(component);
      case FormTypeEnum.textFieldTagsFormType:
        return _buildTextFieldTagsBlocProvider(component);
      case FormTypeEnum.buttonFormType:
        return DynamicButton(
          component: component,
          onAction: widget.onButtonAction,
        );
      // case FormTypeEnum.dropdownFormType:
      //   return DynamicDropdown(component: component);
      // case FormTypeEnum.checkboxFormType:
      //   return DynamicCheckbox(component: component);
      // case FormTypeEnum.radioFormType:
      //   return _buildRadioBlocProvider(component);
      // case FormTypeEnum.sliderFormType:
      //   return DynamicSlider(component: component);
      // case FormTypeEnum.fileUploaderFormType:
      //   return DynamicFileUploader(component: component);
      // case FormTypeEnum.selectFormType:
      //   return DynamicSelect(component: component);
      case FormTypeEnum.container:
        return _buildContainerComponent(component);
      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextFieldBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) => DynamicTextFieldBloc(initialComponent: component),
      child: DynamicTextField(
        key: Key(component.id),
        component: component,
        // onComplete: (value) => handleFormFieldUpdate(context, component, value)
      ),
    );
  }

  Widget _buildTextFieldTagsBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) =>
          DynamicTextFieldTagsBloc(initialComponent: component),
      child: DynamicTextFieldTags(
        key: Key(component.id),
        component: component,
        onComplete: (value) => handleFormFieldUpdate(context, component, value),
      ),
    );
  }

  Widget _buildSelectorButtonBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) =>
          DynamicSelectorButtonBloc(initialComponent: component),
      child: DynamicSelectorButton(
        key: Key(component.id),
        component: component,
        onComplete: (value) => handleFormFieldUpdate(context, component, value),
      ),
    );
  }

  Widget _buildSwitchBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) => DynamicSwitchBloc(initialComponent: component),
      child: DynamicSwitch(
        key: Key(component.id),
        component: component,
        onComplete: (value) => handleFormFieldUpdate(context, component, value),
      ),
    );
  }

  Widget _buildDateTimeRangePickerBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) =>
          DynamicDateTimeRangePickerBloc(initialComponent: component),
      child: DynamicDateTimeRangePicker(
        key: Key(component.id),
        component: component,
        onComplete: (value) => handleFormFieldUpdate(context, component, value),
      ),
    );
  }

  //
  Widget _buildDateTimePickerBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) =>
          DynamicDateTimePickerBloc(initialComponent: component),
      child: DynamicDateTimePicker(
        key: Key(component.id),
        component: component,
        onComplete: (value) => handleFormFieldUpdate(context, component, value),
      ),
    );
  }

  //
  Widget _buildTextAreaBlocProvider(DynamicFormModel component) {
    return BlocProvider(
      create: (context) => DynamicTextAreaBloc(initialComponent: component),
      child: DynamicTextArea(
        key: Key(component.id),
        component: component,
        onComplete: (value) => handleFormFieldUpdate(context, component, value),
      ),
    );
  }

  // Widget _buildRadioBlocProvider(DynamicFormModel component) {
  //   return BlocProvider(
  //     create: (context) => DynamicRadioBloc(initialComponent: component),
  //     child: DynamicRadio(
  //       key: Key(component.id),
  //       component: component,
  //     ),
  //   );
  // }

  Widget _buildContainerComponent(DynamicFormModel component) {
    return const Text("ABCCCCCCCCC");
  }
}
