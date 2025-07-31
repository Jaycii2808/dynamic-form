import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimeRangePickerBloc
    extends
        Bloc<DynamicDateTimeRangePickerEvent, DynamicDateTimeRangePickerState> {
  final TextEditingController _textController;
  final FocusNode _focusNode;
  final DynamicFormModel initialComponent;
  //final String _displayFormat = 'MMM d, yyyy';

  DynamicDateTimeRangePickerBloc({required this.initialComponent})
    : _textController = TextEditingController(
        text: _formatInitialValue(initialComponent.config?.value),
      ),
      _focusNode = FocusNode(),
      super(
        DynamicDateTimeRangePickerInitial(component: DynamicFormModel.empty()),
      ) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeDateTimeRangePickerEvent>(_onInitializeDateTimeRangePicker);
    on<DateTimeRangePickedEvent>(_onDateTimeRangePicked);
    on<DateTimeRangePickerFocusLostEvent>(_onFocusLost);

    add(const InitializeDateTimeRangePickerEvent());
  }

  static String _formatInitialValue(dynamic value) {
    if (value is Map<String, dynamic> &&
        value.containsKey('start') &&
        value.containsKey('end')) {
      return '${value['start']} - ${value['end']}';
    }
    return '';
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final currentValue = _parseTextControllerValue(_textController.text);
      add(DateTimeRangePickerFocusLostEvent(value: currentValue));
    }
  }

  Map<String, String>? _parseTextControllerValue(String text) {
    if (text.isEmpty) return null;
    final parts = text.split(' - ');
    if (parts.length == 2) {
      return {'start': parts[0], 'end': parts[1]};
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
      if (initialValue is Map<String, dynamic> &&
          initialValue.containsKey('start') &&
          initialValue.containsKey('end')) {
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
          inputConfig: InputValidationModel.fromJson(initialComponent.config?.toJson()),
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
    Map<String, String>? rangeValue,
    DynamicDateTimeRangePickerSuccess currentState,
    Emitter<DynamicDateTimeRangePickerState> emit,
  ) {
    // Update text controller
    if (rangeValue != null &&
        rangeValue.containsKey('start') &&
        rangeValue.containsKey('end')) {
      _textController.text = '${rangeValue['start']} - ${rangeValue['end']}';
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

    // Update component config
    final updatedConfig = Map<String, dynamic>.from(
      currentState.component!.config?.toJson() ?? {},
    );
    updatedConfig['value'] = rangeValue;
    updatedConfig['current_state'] = newState;
    updatedConfig['error_text'] = validationError;

    final updatedComponent = ComponentUtils.updateComponentConfig(
      currentState.component!,
      ConfigModel.fromJson(updatedConfig),
    );

    emit(
      DynamicDateTimeRangePickerSuccess(
        component: updatedComponent,
        inputConfig: InputValidationModel.fromJson(updatedComponent.config?.toJson()),
        styleModel: updatedComponent.style,
        formState: newState,
        errorText: validationError,
        textController: _textController,
        focusNode: _focusNode,
      ),
    );
  }
}
