import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/validation/button_condition_validation_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_factory.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_button/dynamic_button_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_button/dynamic_button_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final buttonText = component.config?.label ?? 'Button';

    // Get button action
    final actionString =
        component.config?.action ?? ButtonAction.submitForm.value;
    final action = ButtonAction.fromString(actionString);

    // Check visibility
    final visible = component.config?.toJson()['visible'] != false;

    // Check disabled state based on conditions
    final disabled = _isButtonDisabled(component);

    // Get icon
    final iconString = component.config?.icon;
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
    if (component.config?.toJson()['disabled'] == true) {
      debugPrint('🔴 Button ${component.id} manually disabled');
      return true;
    }

    // Check validation conditions using proper model
    final validateJson = component.config?.toJson()['validate'];
    final validation = ValidationFactory.fromJson(validateJson);

    if (validation is ButtonConditionValidationModel) {
      final conditions = validation.conditions;
      if (conditions.isNotEmpty && formBloc.state.page != null) {
        debugPrint(
          '🔍 Checking ${conditions.length} validation conditions for button ${component.id}',
        );

        for (final condition in conditions) {
          final id = condition.idComponent;
          final isRequired = condition.isRequired ?? false;
          final regex = condition.regex ?? '';

          if (isRequired && id.isNotEmpty) {
            final targetComponent = formBloc.state.page!.components.firstWhere(
              (comp) => comp.id == id,
              orElse: () => DynamicFormModel.empty(),
            );

            if (targetComponent.id.isEmpty) {
              debugPrint(
                '❌ Component $id not found for button ${component.id}',
              );
              return true;
            }

            final value = targetComponent.config?.value;
            debugPrint(
              '🔍 Validating $id: value=$value, isRequired=$isRequired, regex=$regex',
            );

            // Check required condition
            if (isRequired &&
                (value == null ||
                    (value is bool
                        ? value == false
                        : value.toString().trim().isEmpty))) {
              debugPrint(
                '❌ Required validation failed for $id in button ${component.id}',
              );
              return true;
            }

            // Check regex condition
            if (regex.isNotEmpty &&
                value != null &&
                value.toString().isNotEmpty) {
              try {
                final regexPattern = RegExp(regex);
                if (!regexPattern.hasMatch(value.toString())) {
                  debugPrint(
                    '❌ Regex validation failed for $id in button ${component.id}',
                  );
                  return true;
                }
              } catch (e) {
                debugPrint(
                  '❌ Invalid regex pattern: $regex for button ${component.id}',
                );
                return true;
              }
            }
          }
        }

        debugPrint(
          '✅ All validation conditions passed for button ${component.id}',
        );
      }
    }

    return false;
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
