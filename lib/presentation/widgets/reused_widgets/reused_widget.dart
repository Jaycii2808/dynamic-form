import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_date_time_picker/dynamic_date_time_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_date_time_range_picker/dynamic_date_time_range_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_switch/dynamic_switch_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_text_field/dynamic_text_field_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_text_field_tags/dynamic_text_field_tags_bloc.dart';
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
enum StatesEnum { base, error, success, focused,disabled,loading }

class ReusedWidget {
  static StyleStatesModel? getStateStyle(StatesModel? states, StatesEnum state) {
    switch (state) {
      case StatesEnum.base:
        return states?.base;
      case StatesEnum.error:
        return states?.error;
      case StatesEnum.success:
        return states?.success;
      case StatesEnum.focused:
        return states?.focused;
        //disabled, loading
      default:
        return null;
    }
  }

  /// Reusable widget to build form components with BlocProvider
  static Widget buildFormComponent({
    required DynamicFormModel component,
    required Function(String, dynamic) onComponentValueChange,
    Function(String, FormActionDataModel?)? onButtonAction,
  }) {
    debugPrint(
      '🔍 [ReusedWidget] Building component: ${component.id}, type: ${component.type}',
    );

    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return BlocProvider(
          create: (context) =>
              DynamicTextFieldBloc(initialComponent: component),
          child: DynamicTextField(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.textAreaFormType:
        return BlocProvider(
          create: (context) => DynamicTextAreaBloc(initialComponent: component),
          child: DynamicTextArea(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.switchFormType:
        return BlocProvider(
          create: (context) => DynamicSwitchBloc(initialComponent: component),
          child: DynamicSwitch(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.selectorButtonFormType:
        return BlocProvider(
          create: (context) =>
              DynamicSelectorButtonBloc(initialComponent: component),
          child: DynamicSelectorButton(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.dateTimePickerFormType:
        return BlocProvider(
          create: (context) =>
              DynamicDateTimePickerBloc(initialComponent: component),
          child: DynamicDateTimePicker(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.dateTimeRangePickerFormType:
        return BlocProvider(
          create: (context) =>
              DynamicDateTimeRangePickerBloc(initialComponent: component),
          child: DynamicDateTimeRangePicker(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.buttonFormType:
        return DynamicButton(
          key: Key(component.id),
          component: component,
          onAction: onButtonAction,
        );

      case FormTypeEnum.textFieldTagsFormType:
        return BlocProvider(
          create: (context) =>
              DynamicTextFieldTagsBloc(initialComponent: component),
          child: DynamicTextFieldTags(
            key: Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
          ),
        );

      case FormTypeEnum.container:
        return _buildPlaceholderComponent(component, 'Container Component');

      case FormTypeEnum.unknown:
        return const SizedBox.shrink();

      }
  }

  /// Build placeholder component for unsupported types
  static Widget _buildPlaceholderComponent(
      DynamicFormModel component,
      String title,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.widgets, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Component ID: ${component.id}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          if (component.config?.label != null) ...[
            const SizedBox(height: 4),
            Text(
              'Label: ${component.config!.label}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: const Center(
              child: Text(
                'Component Preview',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
