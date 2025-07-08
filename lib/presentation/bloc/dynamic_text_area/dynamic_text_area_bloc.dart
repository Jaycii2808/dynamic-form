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
  final DynamicFormModel
  initialComponent; // Lưu initialComponent để sử dụng trong _onInitializeTextArea

  DynamicTextAreaBloc({required this.initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config[ValueKeyEnum.value.key] ?? '',
      ),
      _focusNode = FocusNode(),
      super(
        DynamicTextAreaInitial(
          component: DynamicFormModel.empty(),
          inputConfig: null,
          styleConfig: null,
          formState: null,
          errorText: null,
          textController: null,
          focusNode: null,
        ),
      ) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeTextAreaEvent>(_onInitializeTextArea);
    on<TextAreaFocusLostEvent>(_onTextAreaFocusLost);
    add(const InitializeTextAreaEvent());
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
      if (initialComponent.id.isEmpty || initialComponent.config.isEmpty) {
        throw Exception("Invalid initial component: ID or config is empty.");
      }
      emit(
        DynamicTextAreaSuccess(
          component: initialComponent,
          inputConfig: InputConfig.fromJson(initialComponent.config),
          styleConfig: StyleConfig.fromJson(initialComponent.style),
          formState:
              FormStateEnum.fromString(initialComponent.config['currentState']) ??
              FormStateEnum.base,

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
