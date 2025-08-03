import 'dart:async';

import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_data_model.dart';
import 'package:dynamic_form_bi/data/models/date_time_range/date_time_range_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_date_time_range_picker/dynamic_date_time_range_picker_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_date_time_range_picker/dynamic_date_time_range_picker_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimeRangePickerBloc
    extends
        Bloc<DynamicDateTimeRangePickerEvent, DynamicDateTimeRangePickerState> {
  final DynamicFormModel initialComponent;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  DynamicDateTimeRangePickerBloc({required this.initialComponent})
    : super(
        DynamicDateTimeRangePickerInitial(component: DynamicFormModel.empty()),
      ) {
    on<InitializeDateTimeRangePickerEvent>(_onInitializeDateTimeRangePicker);
    on<DateTimeRangePickedEvent>(_onDateTimeRangePicked);
    on<DateTimeRangePickerFocusLostEvent>(_onFocusLost);

    _focusNode.addListener(_onFocusChange);

    add(const InitializeDateTimeRangePickerEvent());
  }


  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final currentValue = _parseTextControllerValue(_textController.text);
      add(DateTimeRangePickerFocusLostEvent(value: currentValue));
    }
  }

  DateTimeRangeModel? _parseTextControllerValue(String text) {
    if (text.isEmpty) return null;
    final parts = text.split(' - ');
    if (parts.length == 2) {
      return DateTimeRangeModel(start: parts[0], end: parts[1]);
    }
    return null;
  }

  @override
  Future<void> close() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitializeDateTimeRangePicker(
    InitializeDateTimeRangePickerEvent event,
    Emitter<DynamicDateTimeRangePickerState> emit,
  ) async {
    try {
      if (initialComponent.id.isEmpty) {
        throw Exception("Invalid initial component: ID or config is empty.");
      }
      final initialValue = initialComponent.config?.value;
      String valueForValidation = '';
      if (initialValue is DateTimeRangeModel && initialValue.hasValue) {
        valueForValidation = 'hasValue';
      }

      final validationError = ValidationUtils.validateForm(
        initialComponent,
        valueForValidation,
      );
      final StatesEnum configState = validationError != null
          ? StatesEnum.error
          : (valueForValidation.isNotEmpty
                ? StatesEnum.success
                : StatesEnum.base);

      emit(
        DynamicDateTimeRangePickerSuccess(
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
      final errorMessage = 'Failed to initialize DateTimeRangePicker: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicDateTimeRangePickerError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onDateTimeRangePicked(
    DateTimeRangePickedEvent event,
    Emitter<DynamicDateTimeRangePickerState> emit,
  ) async {
    if (state is! DynamicDateTimeRangePickerSuccess) return;
    final successState = state as DynamicDateTimeRangePickerSuccess;
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      _updateState(event.value, successState, emit);
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to handle date time range picked: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicDateTimeRangePickerError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onFocusLost(
    DateTimeRangePickerFocusLostEvent event,
    Emitter<DynamicDateTimeRangePickerState> emit,
  ) async {
    if (state is! DynamicDateTimeRangePickerSuccess) return;
    final successState = state as DynamicDateTimeRangePickerSuccess;
    try {
      _updateState(event.value, successState, emit);
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to handle focus lost: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicDateTimeRangePickerError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  void _updateState(
    DateTimeRangeModel? rangeValue,
    DynamicDateTimeRangePickerSuccess currentState,
    Emitter<DynamicDateTimeRangePickerState> emit,
  ) {
    // Update text controller
    if (rangeValue != null && rangeValue.hasValue) {
      _textController.text = '${rangeValue.start} - ${rangeValue.end}';
    } else {
      _textController.text = '';
    }

    // Validate
    final validationError = ValidationUtils.validateForm(
      currentState.component!,
      rangeValue != null ? 'hasValue' : '',
    );

    // Determine state
    StatesEnum newState = StatesEnum.base;
    if (validationError != null) {
      newState = StatesEnum.error;
    } else if (rangeValue != null) {
      newState = StatesEnum.success;
    }

    // Update component config using ConfigDataModel
    final configData = ConfigDataModel(
      value: rangeValue, // Save the model directly, not toJson()
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
      DynamicDateTimeRangePickerSuccess(
        component: updatedComponent,
        inputConfig: InputValidationModel.fromJson(
          updatedComponent.config?.toJson(),
        ),
        styleModel: updatedComponent.style,
        formState: newState,
        errorText: validationError,
        textController: _textController,
        focusNode: _focusNode,
      ),
    );
  }
}
