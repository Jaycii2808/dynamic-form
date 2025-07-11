import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_button/dynamic_button_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_button/dynamic_button_state.dart';

class DynamicButtonBloc extends Bloc<DynamicButtonEvent, DynamicButtonState> {
  final DynamicFormBloc formBloc;

  DynamicButtonBloc({required this.formBloc}) : super(DynamicButtonInitial()) {
    on<InitializeDynamicButtonEvent>(_onInitialize);
    on<ComponentUpdatedEvent>(_onComponentUpdated);
    on<ButtonPressedEvent>(_onButtonPressed);
    on<ButtonLoadingEvent>(_onButtonLoading);
  }

  Future<void> _onInitialize(
    InitializeDynamicButtonEvent event,
    Emitter<DynamicButtonState> emit,
  ) async {
    try {
      emit(DynamicButtonLoading());

      final computedValues = _computeAllValues(event.component);

      debugPrint(
        '[Button][_computeAllValues] id=${event.component.id} '
        'text=${computedValues['text']} '
        'action=${computedValues['action']} '
        'visible=${computedValues['visible']} '
        'disabled=${computedValues['disabled']}',
      );

      emit(
        DynamicButtonSuccess(
          component: event.component,
          buttonText: computedValues['text'] as String,
          action: computedValues['action'] as ButtonAction,
          isVisible: computedValues['visible'] as bool,
          isDisabled: computedValues['disabled'] as bool,
          iconData: computedValues['iconData'] as IconData?,
        ),
      );
    } catch (e) {
      debugPrint('❌ [ButtonBloc] Initialization error: $e');
      emit(
        DynamicButtonError(
          errorMessage: 'Failed to initialize button: ${e.toString()}',
          component: event.component,
        ),
      );
    }
  }

  Future<void> _onComponentUpdated(
    ComponentUpdatedEvent event,
    Emitter<DynamicButtonState> emit,
  ) async {
    if (state is! DynamicButtonSuccess) return;

    try {
      final computedValues = _computeAllValues(event.component);

      emit(
        DynamicButtonSuccess(
          component: event.component,
          buttonText: computedValues['text'] as String,
          action: computedValues['action'] as ButtonAction,
          isVisible: computedValues['visible'] as bool,
          isDisabled: computedValues['disabled'] as bool,
          iconData: computedValues['iconData'] as IconData?,
        ),
      );
    } catch (e) {
      debugPrint('❌ [ButtonBloc] Component update error: $e');
      emit(
        DynamicButtonError(
          errorMessage: 'Failed to update component: ${e.toString()}',
          component: event.component,
        ),
      );
    }
  }

  Future<void> _onButtonPressed(
    ButtonPressedEvent event,
    Emitter<DynamicButtonState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicButtonSuccess) return;

    try {
      // Set loading state
      emit(currentState.copyWith(isLoading: true));

      // Handle button action
      await _handleButtonAction(currentState.action, event.buttonId);

      // Reset loading state
      emit(currentState.copyWith(isLoading: false));
    } catch (e) {
      debugPrint('❌ [ButtonBloc] Button press error: $e');
      emit(
        DynamicButtonError(
          errorMessage: 'Failed to handle button press: ${e.toString()}',
          component: currentState.component,
        ),
      );
    }
  }

  Future<void> _onButtonLoading(
    ButtonLoadingEvent event,
    Emitter<DynamicButtonState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicButtonSuccess) return;

    emit(currentState.copyWith(isLoading: event.isLoading));
  }

  Map<String, dynamic> _computeAllValues(DynamicFormModel component) {
    // Get button text
    final buttonText = component.config['label'] as String? ?? 'Button';

    // Get button action
    final actionString = component.config['action'] as String? ?? 'submit_form';
    final action = ButtonAction.fromString(actionString);

    // Check visibility
    final visible = component.config['visible'] != false;

    // Check disabled state based on conditions
    final disabled = _isButtonDisabled(component);

    // Get icon
    final iconString = component.config['icon'] as String?;
    final iconData = iconString != null
        ? IconTypeEnum.fromString(iconString).toIconData()
        : null;

    return {
      'text': buttonText,
      'action': action,
      'visible': visible,
      'disabled': disabled,
      'iconData': iconData,
    };
  }

  bool _isButtonDisabled(DynamicFormModel component) {
    // Check if manually disabled
    if (component.config['disabled'] == true) return true;

    // Check form-level conditions
    final conditions = component.config['conditions'] as List?;
    if (conditions != null && formBloc.state.page != null) {
      return !_checkConditions(conditions, formBloc.state.page!.components);
    }

    return false;
  }

  bool _checkConditions(
    List conditions,
    List<DynamicFormModel> formComponents,
  ) {
    for (final condition in conditions) {
      final componentId = condition['component_id'] as String?;
      if (componentId == null) continue;

      final component = formComponents.firstWhere(
        (comp) => comp.id == componentId,
        orElse: () => DynamicFormModel.empty(),
      );

      if (component.id.isEmpty) continue; // Component not found

      final rule = condition['rule'] as String?;
      final expectedValue = condition['expected_value'];

      if (!_validateCondition(component, rule, expectedValue)) {
        return false;
      }
    }
    return true;
  }

  bool _validateCondition(
    DynamicFormModel component,
    String? rule,
    dynamic expectedValue,
  ) {
    final currentValue = component.config['value'];

    switch (rule) {
      case 'not_null':
        return currentValue != null && currentValue.toString().isNotEmpty;
      case 'equals':
        return currentValue == expectedValue;
      case 'not_equals':
        return currentValue != expectedValue;
      default:
        return true;
    }
  }

  Future<void> _handleButtonAction(ButtonAction action, String buttonId) async {
    debugPrint(
      '🎯 [ButtonBloc] Handling action: $action for button: $buttonId',
    );

    // For now, just log the action
    /*
    switch (action) {
      case ButtonAction.previewForm:
        debugPrint('🔍 [ButtonBloc] Preview form action triggered');
        // formBloc.add(PreviewFormEvent());
        break;
      case ButtonAction.submitForm:
        debugPrint('💾 [ButtonBloc] Submit form action triggered');
        // formBloc.add(SubmitFormEvent(buttonId: buttonId));
        break;
      case ButtonAction.resetForm:
        debugPrint('🔄 [ButtonBloc] Reset form action triggered');
        // formBloc.add(ResetFormEvent());
        break;
    }
    */
  }
}
