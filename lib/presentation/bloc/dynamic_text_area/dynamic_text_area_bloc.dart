import 'dart:async';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_state.dart';

class DynamicTextAreaBloc extends Bloc<DynamicTextAreaEvent, DynamicTextAreaState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;

  DynamicTextAreaBloc({required DynamicFormModel initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config[ValueKeyEnum.value.key] ?? '',
      ),
      _focusNode = FocusNode(),
      super(
        DynamicTextAreaInitial(component: initialComponent),
      ) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeTextAreaEvent>(_onInitializeTextArea);
    on<TextAreaValueChangedEvent>(_onTextAreaValueChanged);
    on<TextAreaFocusLostEvent>(_onTextAreaFocusLost);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      add(TextAreaFocusLostEvent(value: _textController.text));
    }
  }

  @override
  Future<void> close() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitializeTextArea(
    InitializeTextAreaEvent event,
    Emitter<DynamicTextAreaState> emit,
  ) async {
    emit(DynamicTextAreaLoading.fromState(state: state));
    try {
      final component = state.component;
      if (component == null) {
        throw Exception("Component cannot be null for initialization.");
      }
     // await Future.delayed(const Duration(milliseconds: 50));

      emit(
        DynamicTextAreaSuccess(
          component: component,
          inputConfig: InputConfig.fromJson(component.config),
          styleConfig: StyleConfig.fromJson(component.style),
          formState:
              FormStateEnum.fromString(component.config['currentState']) ?? FormStateEnum.base,

          textController: _textController,
          focusNode: _focusNode,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to initialize TextArea: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(DynamicTextAreaError(errorMessage: errorMessage, component: state.component));
    }
  }

  void _onTextAreaValueChanged(
    TextAreaValueChangedEvent event,
    Emitter<DynamicTextAreaState> emit,
  ) {
    if (state is! DynamicTextAreaSuccess) return;
    final successState = state as DynamicTextAreaSuccess;
    try {
      final updatedConfig = Map<String, dynamic>.from(successState.component!.config);
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
      final errorMessage = 'Failed to update TextArea value: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(DynamicTextAreaError(errorMessage: errorMessage, component: state.component));
    }
  }

  Future<void> _onTextAreaFocusLost(
    TextAreaFocusLostEvent event,
    Emitter<DynamicTextAreaState> emit,
  ) async {
    if (state is! DynamicTextAreaSuccess) return;
    final successState = state as DynamicTextAreaSuccess;
    emit(DynamicTextAreaLoading.fromState(state: successState));

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final validationError = ValidationUtils.validateForm(successState.component!, event.value);

      FormStateEnum newState = FormStateEnum.base;
      if (validationError != null) {
        newState = FormStateEnum.error;
      } else if (event.value.isNotEmpty) {
        newState = FormStateEnum.success;
      }

      final updatedConfig = Map<String, dynamic>.from(successState.component!.config);
      updatedConfig[ValueKeyEnum.value.key] = event.value;
      updatedConfig[ValueKeyEnum.currentState.key] = newState.value;
      updatedConfig[ValueKeyEnum.errorText.key] = validationError;

      final updatedComponent = ComponentUtils.updateComponentConfig(
        successState.component!,
        updatedConfig,
      );

      emit(
        DynamicTextAreaSuccess(
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
      final errorMessage = 'Failed to handle focus lost for TextArea: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(DynamicTextAreaError(errorMessage: errorMessage, component: state.component));
    }
  }
}
