import 'dart:async';

import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_date_time_picker/dynamic_date_time_picker_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_date_time_picker/dynamic_date_time_picker_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimePickerBloc
    extends Bloc<DynamicDateTimePickerEvent, DynamicDateTimePickerState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;
  final DynamicFormModel initialComponent;

  DynamicDateTimePickerBloc({required this.initialComponent})
    : _textController = TextEditingController(
        text: initialComponent.config?.value?.toString() ?? '',
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
    try {
      if (initialComponent.id.isEmpty) {
        throw Exception("Invalid initial component: ID or config is empty.");
      }
      final initialValue = initialComponent.config?.value?.toString() ?? '';
      final validationError = ValidationUtils.validateForm(
        initialComponent,
        initialValue,
      );
      final configState = validationError != null
          ? StatesEnum.error
          : (initialValue.isNotEmpty ? StatesEnum.success : StatesEnum.base);
      emit(
        DynamicDateTimePickerSuccess(
          component: initialComponent,
          inputConfig: InputValidationModel.fromJson(
            initialComponent.config?.toJson(),
          ),
          styleModel: initialComponent.style,
          formState: configState,
          errorText: validationError,
          textController: _textController,
          focusNode: _focusNode,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to initialize DateTimePicker: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicDateTimePickerError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onDateTimePicked(
    DateTimePickedEvent event,
    Emitter<DynamicDateTimePickerState> emit,
  ) async {
    if (state is! DynamicDateTimePickerSuccess) return;
    final successState = state as DynamicDateTimePickerSuccess;
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      _updateState(event.value, successState, emit);
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to handle date time picked: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicDateTimePickerError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onFocusLost(
    DateTimePickerFocusLostEvent event,
    Emitter<DynamicDateTimePickerState> emit,
  ) async {
    if (state is! DynamicDateTimePickerSuccess) return;
    final successState = state as DynamicDateTimePickerSuccess;
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      _updateState(event.value, successState, emit);
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to handle focus lost for DateTimePicker: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicDateTimePickerError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  void _updateState(
    String value,
    DynamicDateTimePickerSuccess currentState,
    Emitter<DynamicDateTimePickerState> emit,
  ) {
    // Check if component is null to prevent runtime error
    if (currentState.component == null) {
      debugPrint('❌ Error: Component is null in _updateState');
      emit(
        const DynamicDateTimePickerError(
          errorMessage: 'Component is null',
          component: null,
        ),
      );
      return;
    }

    final validationError = ValidationUtils.validateForm(
      currentState.component!,
      value,
    );
    debugPrint(
      'DynamicDateTimePickerBloc: value="$value", validationError=$validationError',
    );

    final newState = validationError != null
        ? StatesEnum.error
        : (value.isNotEmpty ? StatesEnum.success : StatesEnum.base);
    if (_textController.text != value) {
      _textController.text = value;
    }

    final configData = ConfigDataModel(
      value: value,
      currentState: newState,
      errorText: validationError,
      placeholder: currentState.component!.config?.placeholder,
      required: currentState.component!.config?.isRequired,
      type: currentState.component!.config?.pickerMode,
    );

    final updatedComponent = ComponentUtils.updateComponentConfig(
      currentState.component!,
      ConfigModel.fromJson(configData.toJson()),
    );

    emit(
      DynamicDateTimePickerSuccess(
        component: updatedComponent,
        errorText: validationError,
        inputConfig: InputValidationModel.fromJson(
          updatedComponent.config?.toJson(),
        ),
        styleModel: updatedComponent.style,
        formState: newState,
        textController: _textController,
        focusNode: _focusNode,
      ),
    );
  }
}
