import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_bloc.dart';
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
      case FormTypeEnum.buttonFormType:
        return DynamicButton(
          key: key ?? Key(component.id),
          component: component,
          onAction: onButtonAction,
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

      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }
}
