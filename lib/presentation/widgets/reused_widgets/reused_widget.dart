import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_switch/dynamic_switch_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_switch.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_dropdown.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_button.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_short_answer.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_short_answer/dynamic_short_answer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum StatesEnum { base, error, success, focused, disabled, loading }

class ReusedWidget {
  static StyleStatesModel? getStateStyle(
    StatesModel? states,
    StatesEnum state,
  ) {
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
    Key? key, // Add key parameter
    required DynamicFormModel component,
    required Function(String, dynamic) onComponentValueChange,
    Function(String, FormActionDataModel?)? onButtonAction,
    Function(DynamicFormModel)?
    onComponentUpdate, // Add callback for component updates
    bool isSharedForm = false, // Add parameter to indicate shared form mode
    String? currentPageId, // Add page ID for navigation tracking
  }) {
    // Logging removed; use Bloc Observer
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return _buildPlaceholderComponent(component, 'Text Field Component');

      case FormTypeEnum.textAreaFormType:
        return _buildPlaceholderComponent(component, 'Text Area Component');

      case FormTypeEnum.switchFormType:
        return BlocProvider(
          create: (context) => DynamicSwitchBloc(initialComponent: component),
          child: DynamicSwitch(
            key: key ?? Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
            onComponentUpdate: onComponentUpdate,
            isSharedForm: isSharedForm, // Pass the shared form flag
          ),
        );

      case FormTypeEnum.selectorButtonFormType:
        return _buildPlaceholderComponent(
          component,
          'Selector Button Component',
        );

      case FormTypeEnum.dateTimePickerFormType:
        return _buildPlaceholderComponent(
          component,
          'Date Time Picker Component',
        );

      case FormTypeEnum.dateTimeRangePickerFormType:
        return _buildPlaceholderComponent(
          component,
          'Date Time Range Picker Component',
        );

      case FormTypeEnum.buttonFormType:
        return DynamicButton(
          key: key ?? Key(component.id),
          component: component,
          onAction: onButtonAction,
        );

      case FormTypeEnum.textFieldTagsFormType:
        return _buildPlaceholderComponent(
          component,
          'Text Field Tags Component',
        );

      case FormTypeEnum.dropdownFormType:
        // Logging removed; use Bloc Observer
        return BlocProvider(
          create: (context) => DynamicDropdownBloc(
            initialComponent: component,
            currentPageId: currentPageId,
          ),
          child: DynamicDropdown(
            key: key ?? Key(component.id),
            component: component,
            onComplete: (value) => onComponentValueChange(component.id, value),
            onComponentUpdate: onComponentUpdate,
            isSharedForm: isSharedForm,
            currentPageId: currentPageId,
          ),
        );

      case FormTypeEnum.shortAnswerFormType:
        // Logging removed; use Bloc Observer
        return BlocProvider(
          create: (context) => DynamicShortAnswerBloc(),
          child: DynamicShortAnswer(
            key: key ?? Key(component.id),
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
