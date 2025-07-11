import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_radio/dynamic_radio_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_radio/dynamic_radio_state.dart';
import 'package:flutter/material.dart';

class DynamicRadioBloc extends Bloc<DynamicRadioEvent, DynamicRadioState> {
  final DynamicFormModel initialComponent;
  late FocusNode _focusNode;

  DynamicRadioBloc({required this.initialComponent})
    : super(const DynamicRadioInitial()) {
    _focusNode = FocusNode();

    on<InitializeRadioEvent>(_onInitialize);
    on<RadioValueChangedEvent>(_onValueChanged);
    on<UpdateRadioFromExternalEvent>(_onUpdateFromExternal);
  }

  @override
  Future<void> close() {
    _focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitialize(
    InitializeRadioEvent event,
    Emitter<DynamicRadioState> emit,
  ) async {
    try {
      emit(DynamicRadioLoading(component: initialComponent));

      // Parse configurations
      final styleConfig = StyleConfig.fromJson(initialComponent.style);
      final inputConfig = InputConfig.fromJson(initialComponent.config);

      // Determine initial form state
      final currentState = _getCurrentFormState(initialComponent);
      final errorText = _getErrorText(initialComponent);

      debugPrint('🔵 [RadioBloc] Initialized with state: $currentState');

      emit(
        DynamicRadioSuccess(
          component: initialComponent,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: currentState,
          errorText: errorText,
          focusNode: _focusNode,
        ),
      );
    } catch (e) {
      emit(
        DynamicRadioError(
          errorMessage: 'Failed to initialize radio: $e',
          component: initialComponent,
        ),
      );
    }
  }

  Future<void> _onValueChanged(
    RadioValueChangedEvent event,
    Emitter<DynamicRadioState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! DynamicRadioSuccess) return;

      // Update component with new value
      final updatedConfig = Map<String, dynamic>.from(
        currentState.component!.config,
      );
      updatedConfig[ValueKeyEnum.value.key] = event.value;

      final updatedComponent = ComponentUtils.updateComponentConfig(
        currentState.component!,
        updatedConfig,
      );

      // Validate the new value
      final validationResult = _validateValue(updatedComponent, event.value);
      final formState = validationResult['state'] as FormStateEnum;
      final errorText = validationResult['error'] as String?;

      debugPrint(
        '🔵 [RadioBloc] Value changed to: ${event.value}, state: $formState',
      );

      emit(
        DynamicRadioSuccess(
          component: updatedComponent,
          styleConfig: currentState.styleConfig,
          inputConfig: currentState.inputConfig,
          formState: formState,
          errorText: errorText,
          focusNode: _focusNode,
        ),
      );
    } catch (e) {
      emit(
        DynamicRadioError(
          errorMessage: 'Failed to update radio value: $e',
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateRadioFromExternalEvent event,
    Emitter<DynamicRadioState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! DynamicRadioSuccess) return;

      debugPrint('🔄 [RadioBloc] External update received');

      // Parse updated configurations
      final styleConfig = StyleConfig.fromJson(event.component.style);
      final inputConfig = InputConfig.fromJson(event.component.config);

      // Get current form state from component
      final formState = _getCurrentFormState(event.component);
      final errorText = _getErrorText(event.component);

      emit(
        DynamicRadioSuccess(
          component: event.component,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          focusNode: _focusNode,
        ),
      );
    } catch (e) {
      emit(
        DynamicRadioError(
          errorMessage: 'Failed to update radio from external: $e',
          component: state.component,
        ),
      );
    }
  }

  FormStateEnum _getCurrentFormState(DynamicFormModel component) {
    final currentState = component.config['current_state'];
    if (currentState != null) {
      return FormStateEnum.fromString(currentState) ?? FormStateEnum.base;
    }
    return FormStateEnum.base;
  }

  String? _getErrorText(DynamicFormModel component) {
    return component.config['error_text'] as String?;
  }

  Map<String, dynamic> _validateValue(DynamicFormModel component, bool value) {
    try {
      // For radio buttons, validation is usually about selection requirements
      final isRequired = component.config['is_required'] == true;

      if (isRequired && !value) {
        return {
          'state': FormStateEnum.error,
          'error': 'This option is required',
        };
      }

      return {
        'state': FormStateEnum.success,
        'error': null,
      };
    } catch (e) {
      return {
        'state': FormStateEnum.error,
        'error': 'Validation error: $e',
      };
    }
  }
}
