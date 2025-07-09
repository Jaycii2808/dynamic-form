import 'dart:async';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_state.dart';

class DynamicTextFieldBloc
    extends Bloc<DynamicTextFieldEvent, DynamicTextFieldState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;

  DynamicTextFieldBloc({required DynamicFormModel initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config[ValueKeyEnum.value.key]?.toString() ?? '',
      ),
      _focusNode = FocusNode(),
      super(
        DynamicTextFieldInitial(component: initialComponent),
      ) {
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
    emit(DynamicTextFieldLoading.fromState(state: state));
    try {
      final component = state.component;
      if (component == null) {
        throw Exception("Component cannot be null for initialization.");
      }

      emit(
        DynamicTextFieldSuccess(
          component: component,
          inputConfig: InputConfig.fromJson(component.config),
          styleConfig: StyleConfig.fromJson(component.style),
          formState:
              FormStateEnum.fromString(component.config['current_state']) ??
              FormStateEnum.base,
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
      final updatedConfig = Map<String, dynamic>.from(
        successState.component!.config,
      );
      updatedConfig['value'] = event.value;
      final updatedComponent = ComponentUtils.updateComponentConfig(
        successState.component!,
        updatedConfig,
      );

      emit(
        successState.copyWith(
          component: updatedComponent,
          inputConfig: InputConfig.fromJson(updatedComponent.config),
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
    emit(DynamicTextFieldLoading.fromState(state: successState));

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final validationError = _validateTextField(
        successState.component!,
        event.value,
      );

      FormStateEnum newState = FormStateEnum.base;
      if (validationError != null) {
        newState = FormStateEnum.error;
      } else if (event.value.isNotEmpty) {
        newState = FormStateEnum.success;
      }

      final updatedConfig = Map<String, dynamic>.from(
        successState.component!.config,
      );
      updatedConfig[ValueKeyEnum.value.key] = event.value;
      updatedConfig['current_state'] = newState.value;
      updatedConfig['error_text'] = validationError;

      final updatedComponent = ComponentUtils.updateComponentConfig(
        successState.component!,
        updatedConfig,
      );

      emit(
        DynamicTextFieldSuccess(
          component: updatedComponent,
          errorText: validationError,
          inputConfig: InputConfig.fromJson(updatedComponent.config),
          styleConfig: StyleConfig.fromJson(updatedComponent.style),
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
    final successState = state as DynamicTextFieldSuccess;

    try {
      // Update text controller if value changed
      final newValue =
          event.component.config[ValueKeyEnum.value.key]?.toString() ?? '';
      if (_textController.text != newValue) {
        _textController.text = newValue;
      }

      emit(
        DynamicTextFieldSuccess(
          component: event.component,
          inputConfig: InputConfig.fromJson(event.component.config),
          styleConfig: StyleConfig.fromJson(event.component.style),
          formState:
              FormStateEnum.fromString(
                event.component.config['current_state'],
              ) ??
              FormStateEnum.base,
          textController: _textController,
          focusNode: _focusNode,
          errorText: event.component.config['error_text']?.toString(),
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
    final validation =
        inputTypes?['text']?['validation'] as Map<String, dynamic>?;
    if (validation == null) return null;

    // Min length
    if (validation['min_length'] != null &&
        value.length < validation['min_length']) {
      return validation['error_message'] ?? 'Too short';
    }
    // Max length
    if (validation['max_length'] != null &&
        value.length > validation['max_length']) {
      return validation['error_message'] ?? 'Too long';
    }
    // Regex
    if (validation['regex'] != null && value.isNotEmpty) {
      final regex = RegExp(validation['regex']);
      if (!regex.hasMatch(value)) {
        return validation['error_message'] ?? 'Invalid format';
      }
    }
    return null;
  }
}
