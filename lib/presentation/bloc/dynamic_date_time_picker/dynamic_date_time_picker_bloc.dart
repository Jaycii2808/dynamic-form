import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_state.dart';

class DynamicDateTimePickerBloc
    extends Bloc<DynamicDateTimePickerEvent, DynamicDateTimePickerState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;
  final DynamicFormModel initialComponent;

  DynamicDateTimePickerBloc({required this.initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config[ValueKeyEnum.value.key] ?? '',
      ),
      _focusNode = FocusNode(),
      super(DynamicDateTimePickerInitial(component: DynamicFormModel.empty())) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeDateTimePickerEvent>(_onInitializeDateTimePicker);
    on<DateTimePickedEvent>(_onDateTimePicked);
    on<DateTimePickerFocusLostEvent>(_onFocusLost);

    add(const InitializeDateTimePickerEvent());
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      add(DateTimePickerFocusLostEvent(value: _textController.text));
    }
  }

  @override
  Future<void> close() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitializeDateTimePicker(
    InitializeDateTimePickerEvent event,
    Emitter<DynamicDateTimePickerState> emit,
  ) async {
    emit(DynamicDateTimePickerLoading.fromState(state: state));
    try {
      if (initialComponent.id.isEmpty || initialComponent.config.isEmpty) {
        throw Exception("Invalid initial component: ID or config is empty.");
      }
      emit(
        DynamicDateTimePickerSuccess(
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
      final errorMessage = 'Failed to initialize DateTimePicker: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(DynamicDateTimePickerError(errorMessage: errorMessage, component: state.component));
    }
  }

  Future<void> _onDateTimePicked(
    DateTimePickedEvent event,
    Emitter<DynamicDateTimePickerState> emit,
  ) async {
    if (state is! DynamicDateTimePickerSuccess) return;
    final successState = state as DynamicDateTimePickerSuccess;

    _updateState(event.value, successState, emit);
  }

  Future<void> _onFocusLost(
    DateTimePickerFocusLostEvent event,
    Emitter<DynamicDateTimePickerState> emit,
  ) async {
    if (state is! DynamicDateTimePickerSuccess) return;
    final successState = state as DynamicDateTimePickerSuccess;

    _updateState(event.value, successState, emit);
  }

  void _updateState(
    String value,
    DynamicDateTimePickerSuccess currentState,
    Emitter<DynamicDateTimePickerState> emit,
  ) {
    final validationError = ValidationUtils.validateForm(currentState.component!, value);

    FormStateEnum newState = FormStateEnum.base;
    if (validationError != null) {
      newState = FormStateEnum.error;
    } else if (value.isNotEmpty) {
      newState = FormStateEnum.success;
    }
    if (_textController.text != value) {
      _textController.text = value;
    }
    final updatedConfig = Map<String, dynamic>.from(currentState.component!.config);
    updatedConfig[ValueKeyEnum.value.key] = value;
    updatedConfig[ValueKeyEnum.currentState.key] = newState.value;
    updatedConfig[ValueKeyEnum.errorText.key] = validationError;

    final updatedComponent = ComponentUtils.updateComponentConfig(
      currentState.component!,
      updatedConfig,
    );

    emit(
      DynamicDateTimePickerSuccess(
        component: updatedComponent,
        errorText: validationError,
        inputConfig: InputConfig.fromJson(updatedComponent.config),
        styleConfig: StyleConfig.fromJson(updatedComponent.style),
        formState: newState,
        textController: _textController,
        focusNode: _focusNode,
      ),
    );
  }
}
