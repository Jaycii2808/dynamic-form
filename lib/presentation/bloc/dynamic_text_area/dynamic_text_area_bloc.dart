import 'dart:async';

import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_state.dart';

class DynamicTextAreaBloc
    extends Bloc<DynamicTextAreaEvent, DynamicTextAreaState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;
  final DynamicFormModel
  initialComponent; // Lưu initialComponent để sử dụng trong _onInitializeTextArea

  DynamicTextAreaBloc({required this.initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config?.value?.toString() ?? '',
      ),
      _focusNode = FocusNode(),
      super(
        DynamicTextAreaInitial(
          component: DynamicFormModel.empty(),
          inputConfig: null,
          styleModel: null,
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
    // emit(DynamicTextAreaLoading.fromState(state: state));
    try {
      if (initialComponent.id.isEmpty || initialComponent.config == null) {
        throw Exception("Invalid initial component: ID or config is empty.");
      }
      final configState =
          initialComponent.config?.currentState ?? 'base';
      emit(
        DynamicTextAreaSuccess(
          component: initialComponent,
          inputConfig: InputConfig.fromJson(initialComponent.config?.toJson() ?? {}),
          styleModel: initialComponent.style,

          formState: configState,
          textController: _textController,
          focusNode: _focusNode,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to initialize TextArea: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicTextAreaError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onTextAreaFocusLost(
    TextAreaFocusLostEvent event,
    Emitter<DynamicTextAreaState> emit,
  ) async {
    if (state is! DynamicTextAreaSuccess) return;
    final successState = state as DynamicTextAreaSuccess;
    // emit(DynamicTextAreaLoading.fromState(state: successState));

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final validationError = ValidationUtils.validateForm(
        successState.component!,
        event.value,
      );
      debugPrint(
        'DynamicTextAreaBloc: value="${event.value}", validationError=$validationError',
      );

      String newState = 'base';
      if (validationError != null) {
        newState = 'error';
      } else if (event.value.isNotEmpty) {
        newState = 'success';
      }

      final configMap = successState.component!.config?.toJson() ?? {};
      configMap['value'] = event.value;
      configMap['current_state'] = newState;
      configMap['error_text'] = validationError;

      final updatedComponent = ComponentUtils.updateComponentConfig(
        successState.component!,
        ConfigModel.fromJson(configMap),
      );

      final configState = updatedComponent.config?.currentState ?? 'base';

      emit(
        DynamicTextAreaSuccess(
          component: updatedComponent,
          errorText: validationError,
          inputConfig: InputConfig.fromJson(updatedComponent.config?.toJson() ?? {}),
          styleModel: updatedComponent.style,
          formState: configState,
          textController: _textController,
          focusNode: _focusNode,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to handle focus lost for TextArea: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicTextAreaError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }
}
