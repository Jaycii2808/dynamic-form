import 'dart:async';

import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextFieldBloc
    extends Bloc<DynamicTextFieldEvent, DynamicTextFieldState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;

  DynamicTextFieldBloc({required DynamicFormModel initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config?.value?.toString() ?? '',
      ),
      _focusNode = FocusNode(),
      super(DynamicTextFieldInitial(component: initialComponent)) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeTextFieldEvent>(_onInitializeTextField);
    on<TextFieldValueChangedEvent>(_onTextFieldValueChanged);
    on<TextFieldFocusLostEvent>(_onTextFieldFocusLost);
    on<UpdateTextFieldFromExternalEvent>(_onUpdateFromExternal);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      add(TextFieldFocusLostEvent(value: _textController.text));
    }
  }

  @override
  Future<void> close() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitializeTextField(
    InitializeTextFieldEvent event,
    Emitter<DynamicTextFieldState> emit,
  ) async {
    //emit(DynamicTextFieldLoading.fromState(state: state));
    try {
      final component = state.component;
      if (component == null) {
        throw Exception("Component cannot be null for initialization.");
      }

      emit(
        DynamicTextFieldSuccess(
          component: component,
          inputConfig: InputValidationModel.fromJson(component.config?.toJson() ?? {}),
          styleModel: component.style,
          formState: component.config?.currentState ?? StatesEnum.base,
          textController: _textController,
          focusNode: _focusNode,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to initialize TextField: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicTextFieldError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  void _onTextFieldValueChanged(
    TextFieldValueChangedEvent event,
    Emitter<DynamicTextFieldState> emit,
  ) {
    if (state is! DynamicTextFieldSuccess) return;
    final successState = state as DynamicTextFieldSuccess;
    try {
      // Create new config model directly with updated value
      final updatedConfig = ConfigModel(
        label: successState.component!.config?.label,
        placeholder: successState.component!.config?.placeholder,
        isRequired: successState.component!.config?.isRequired,
        value: event.value,
        currentState: successState.component!.config?.currentState,
        errorText: successState.component!.config?.errorText,
        defaultFormat: successState.component!.config?.defaultFormat,
        initialTags: successState.component!.config?.initialTags,
        textSeparators: successState.component!.config?.textSeparators,
        pickerMode: successState.component!.config?.pickerMode,
        selected: successState.component!.config?.selected,
        range: successState.component!.config?.range,
        min: successState.component!.config?.min,
        max: successState.component!.config?.max,
        values: successState.component!.config?.values,
        prefix: successState.component!.config?.prefix,
        icon: successState.component!.config?.icon,
        title: successState.component!.config?.title,
        buttonText: successState.component!.config?.buttonText,
        allowedExtensions: successState.component!.config?.allowedExtensions,
        action: successState.component!.config?.action,
        conditions: successState.component!.config?.conditions,
        options: successState.component!.config?.options,
        hint: successState.component!.config?.hint,
        height: successState.component!.config?.height,
        statusText: successState.component!.config?.statusText,
        validate: successState.component!.config?.validate,
      );

      final updatedComponent = ComponentUtils.updateComponentConfig(
        successState.component!,
        updatedConfig,
      );

      emit(
        successState.copyWith(
          component: updatedComponent,
          inputConfig: InputValidationModel.fromJson(
            updatedComponent.config?.toJson() ?? {},
          ),
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to update TextField value: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicTextFieldError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onTextFieldFocusLost(
    TextFieldFocusLostEvent event,
    Emitter<DynamicTextFieldState> emit,
  ) async {
    if (state is! DynamicTextFieldSuccess) return;
    final successState = state as DynamicTextFieldSuccess;
   // emit(DynamicTextFieldLoading.fromState(state: successState));

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final validationError = _validateTextField(
        successState.component!,
        event.value,
      );

      StatesEnum newState = StatesEnum.base;
      if (validationError != null) {
        newState = StatesEnum.error;
      } else if (event.value.isNotEmpty) {
        newState = StatesEnum.success;
      }

      // Create new config model directly with updated properties
      final updatedConfig = ConfigModel(
        label: successState.component!.config?.label,
        placeholder: successState.component!.config?.placeholder,
        isRequired: successState.component!.config?.isRequired,
        value: event.value,
        currentState: newState,
        errorText: validationError,
        defaultFormat: successState.component!.config?.defaultFormat,
        initialTags: successState.component!.config?.initialTags,
        textSeparators: successState.component!.config?.textSeparators,
        pickerMode: successState.component!.config?.pickerMode,
        selected: successState.component!.config?.selected,
        range: successState.component!.config?.range,
        min: successState.component!.config?.min,
        max: successState.component!.config?.max,
        values: successState.component!.config?.values,
        prefix: successState.component!.config?.prefix,
        icon: successState.component!.config?.icon,
        title: successState.component!.config?.title,
        buttonText: successState.component!.config?.buttonText,
        allowedExtensions: successState.component!.config?.allowedExtensions,
        action: successState.component!.config?.action,
        conditions: successState.component!.config?.conditions,
        options: successState.component!.config?.options,
        hint: successState.component!.config?.hint,
        height: successState.component!.config?.height,
        statusText: successState.component!.config?.statusText,
        validate: successState.component!.config?.validate,
      );

      final updatedComponent = ComponentUtils.updateComponentConfig(
        successState.component!,
        updatedConfig,
      );

      emit(
        DynamicTextFieldSuccess(
          component: updatedComponent,
          errorText: validationError,
          inputConfig: InputValidationModel.fromJson(
            updatedComponent.config?.toJson() ?? {},
          ),
          styleModel: updatedComponent.style,
          formState: newState,
          textController: _textController,
          focusNode: _focusNode,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to handle focus lost for TextField: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicTextFieldError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateTextFieldFromExternalEvent event,
    Emitter<DynamicTextFieldState> emit,
  ) async {
    if (state is! DynamicTextFieldSuccess) return;

    try {
      // Update text controller if value changed
      final newValue = event.component.config?.value?.toString() ?? '';
      if (_textController.text != newValue) {
        _textController.text = newValue;
      }

      emit(
        DynamicTextFieldSuccess(
          component: event.component,
          inputConfig: InputValidationModel.fromJson(
            event.component.config?.toJson() ?? {},
          ),
          styleModel: event.component.style,
          formState: event.component.config?.currentState ?? StatesEnum.base,
          textController: _textController,
          focusNode: _focusNode,
          errorText: event.component.config?.errorText,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to update from external: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicTextFieldError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  String? _validateTextField(DynamicFormModel component, String value) {
    final inputTypes = component.inputTypes;
    final validation = inputTypes?.text;
    if (validation != null) {
      if (validation.minLength != null &&
          value.length < validation.minLength!) {
        return validation.errorMessage ?? 'Too short';
      }
      if (validation.maxLength != null &&
          value.length > validation.maxLength!) {
        return validation.errorMessage ?? 'Too long';
      }
      if (validation.regex != null &&
          !RegExp(validation.regex!).hasMatch(value)) {
        return validation.errorMessage ?? 'Incorrect format';
      }
    }
    return null;
  }
}
