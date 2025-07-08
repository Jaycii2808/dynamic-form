import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_state.dart';

class DynamicDateTimeRangePickerBloc extends Bloc<DynamicDateTimeRangePickerEvent,
    DynamicDateTimeRangePickerState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;
  final DynamicFormModel initialComponent;
  final String _displayFormat = DateFormatCustomPattern.mmmDyyyy.pattern;

  DynamicDateTimeRangePickerBloc({required this.initialComponent})
      : _textController = TextEditingController(),
        _focusNode = FocusNode(),
        super(DynamicDateTimeRangePickerInitial(
          component: DynamicFormModel.empty())) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeDateTimeRangePickerEvent>(_onInitialize);
    on<DateTimeRangePickedEvent>(_onRangePicked);
    on<DateTimeRangePickerFocusLostEvent>(_onFocusLost);

    add(const InitializeDateTimeRangePickerEvent());
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      add(const DateTimeRangePickerFocusLostEvent());
    }
  }

  @override
  Future<void> close() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    return super.close();
  }

  void _initializeController(Map<String, dynamic> config) {
    final value = config[ValueKeyEnum.value.key];
    if (value is Map<String, dynamic> &&
        value.containsKey('start') &&
        value.containsKey('end')) {
      try {
        final startDate = DateFormat(_displayFormat).parse(value['start']);
        final endDate = DateFormat(_displayFormat).parse(value['end']);
        _textController.text =
        '${DateFormat(_displayFormat).format(startDate)} - ${DateFormat(_displayFormat).format(endDate)}';
      } catch (e) {
        _textController.text = '';
      }
    }
  }

  Future<void> _onInitialize(
      InitializeDateTimeRangePickerEvent event,
      Emitter<DynamicDateTimeRangePickerState> emit,
      ) async {
    emit(DynamicDateTimeRangePickerLoading.fromState(state: state));
    try {
      if (initialComponent.id.isEmpty) {
        throw Exception("Invalid initial component: ID is empty.");
      }
      _initializeController(initialComponent.config);
      emit(
        DynamicDateTimeRangePickerSuccess(
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
      final errorMessage = 'Failed to initialize DateTimeRangePicker: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(DynamicDateTimeRangePickerError(
          errorMessage: errorMessage, component: state.component));
    }
  }

  Future<void> _onRangePicked(
      DateTimeRangePickedEvent event,
      Emitter<DynamicDateTimeRangePickerState> emit,
      ) async {
    if (state is! DynamicDateTimeRangePickerSuccess) return;
    _updateState(event.value, state as DynamicDateTimeRangePickerSuccess, emit);
  }

  Future<void> _onFocusLost(
      DateTimeRangePickerFocusLostEvent event,
      Emitter<DynamicDateTimeRangePickerState> emit,
      ) async {
    if (state is! DynamicDateTimeRangePickerSuccess) return;
    final successState = state as DynamicDateTimeRangePickerSuccess;

    // Re-validate the current state on focus lost
    final value = successState.component?.config[ValueKeyEnum.value.key];
    DateTimeRange? range;
    if (value is Map<String, dynamic> &&
        value.containsKey('start') &&
        value.containsKey('end')) {
      try {
        range = DateTimeRange(
          start: DateFormat(_displayFormat).parse(value['start']),
          end: DateFormat(_displayFormat).parse(value['end']),
        );
      } catch (_) {
        range = null;
      }
    }
    _updateState(range, successState, emit);
  }

  void _updateState(
      DateTimeRange? range,
      DynamicDateTimeRangePickerSuccess currentState,
      Emitter<DynamicDateTimeRangePickerState> emit,
      ) {
    // Treat null range as empty for validation purposes
    final validationError = ValidationUtils.validateForm(
        currentState.component!, range == null ? '' : 'hasValue');

    FormStateEnum newState = FormStateEnum.base;
    if (validationError != null) {
      newState = FormStateEnum.error;
    } else if (range != null) {
      newState = FormStateEnum.success;
    }

    final Map<String, dynamic>? valueToStore;
    if (range != null) {
      _textController.text =
      '${DateFormat(_displayFormat).format(range.start)} - ${DateFormat(_displayFormat).format(range.end)}';
      valueToStore = {
        'start': DateFormat(_displayFormat).format(range.start),
        'end': DateFormat(_displayFormat).format(range.end),
      };
    } else {
      _textController.text = '';
      valueToStore = null;
    }

    final updatedConfig =
    Map<String, dynamic>.from(currentState.component!.config);
    updatedConfig[ValueKeyEnum.value.key] = valueToStore;
    updatedConfig[ValueKeyEnum.currentState.key] = newState.value;
    updatedConfig[ValueKeyEnum.errorText.key] = validationError;

    final updatedComponent = ComponentUtils.updateComponentConfig(
      currentState.component!,
      updatedConfig,
    );

    emit(
      DynamicDateTimeRangePickerSuccess(
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