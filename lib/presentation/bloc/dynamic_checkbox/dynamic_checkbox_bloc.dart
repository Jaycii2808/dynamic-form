import 'dart:async';

import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicCheckboxBloc
    extends Bloc<DynamicCheckboxEvent, DynamicCheckboxState> {
  final DynamicFormModel initialComponent;
  late FocusNode focusNode;

  DynamicCheckboxBloc({required this.initialComponent})
    : super(const DynamicCheckboxInitial()) {
    focusNode = FocusNode();

    on<InitializeCheckboxEvent>(_onInitialize);
    on<CheckboxValueChangedEvent>(_onValueChanged);
    on<UpdateCheckboxFromExternalEvent>(_onUpdateFromExternal);
  }

  @override
  Future<void> close() {
    focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitialize(
    InitializeCheckboxEvent event,
    Emitter<DynamicCheckboxState> emit,
  ) async {
    try {
      emit(
        DynamicCheckboxLoading(
          component: initialComponent,
        ),
      );

      final styleModel = initialComponent.style;
      final inputConfig = InputValidationModel.fromJson(
        initialComponent.config?.toJson() ?? {},
      );

      // Get initial value
      final value = initialComponent.config?.value == true;

      // Compute editable state - create fallback if properties don't exist
      final isEditable = true; // Default to editable if properties don't exist

      // Compute form state
      final formState =
          initialComponent.config?.currentState ?? StatesEnum.base;

      // Compute validation error
      final errorText = _validateCheckbox(initialComponent, value);

      // Compute styles
      final computedStyles = _computeStyles(initialComponent, value);

      debugPrint(
        '🟢 [CheckboxBloc] Initialized: ${initialComponent.id}, isSelected: $value, state: $formState',
      );

      emit(
        DynamicCheckboxSuccess(
          component: initialComponent,
          styleModel: styleModel,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          isSelected: value,
          isEditable: isEditable,
          focusNode: focusNode,
          backgroundColor:
              computedStyles['backgroundColor'] ?? Colors.transparent,
          borderColor: computedStyles['borderColor'] ?? Colors.grey,
          borderWidth: computedStyles['borderWidth'] ?? 1.0,
          iconColor: computedStyles['iconColor'] ?? Colors.white,
          controlWidth: computedStyles['controlWidth'] ?? 40.0,
          controlHeight: computedStyles['controlHeight'] ?? 40.0,
          controlBorderRadius: computedStyles['controlBorderRadius'] ?? 8.0,
          leadingIconData: computedStyles['leadingIconData'],
        ),
      );
    } catch (e) {
      debugPrint('❌ [CheckboxBloc] Initialization error: $e');
      emit(
        DynamicCheckboxError(
          errorMessage: 'Failed to initialize checkbox: ${e.toString()}',
          component: initialComponent,
        ),
      );
    }
  }

  Future<void> _onValueChanged(
    CheckboxValueChangedEvent event,
    Emitter<DynamicCheckboxState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicCheckboxSuccess) return;

    try {
      final updatedComponent = _updateComponentValue(
        currentState.component!,
        event.value,
      );

      final formState = _computeFormState(updatedComponent, event.value);
      final errorText = _validateCheckbox(updatedComponent, event.value);

      // Recompute styles with new value
      final computedStyles = _computeStyles(updatedComponent, event.value);

      debugPrint(
        '🔄 [CheckboxBloc] Value changed: ${updatedComponent.id} = ${event.value}',
      );

      emit(
        currentState.copyWith(
          component: updatedComponent,
          isSelected: event.value,
          formState: formState,
          errorText: errorText,
          backgroundColor:
              computedStyles['backgroundColor'] ?? Colors.transparent,
          borderColor: computedStyles['borderColor'] ?? Colors.grey,
          borderWidth: computedStyles['borderWidth'] ?? 1.0,
          iconColor: computedStyles['iconColor'] ?? Colors.white,
          controlWidth: computedStyles['controlWidth'] ?? 40.0,
          controlHeight: computedStyles['controlHeight'] ?? 40.0,
          controlBorderRadius: computedStyles['controlBorderRadius'] ?? 8.0,
          leadingIconData: computedStyles['leadingIconData'],
        ),
      );
    } catch (e) {
      debugPrint('❌ [CheckboxBloc] Value change error: $e');
      emit(
        DynamicCheckboxError(
          errorMessage: 'Failed to update value: ${e.toString()}',
          component: currentState.component,
        ),
      );
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateCheckboxFromExternalEvent event,
    Emitter<DynamicCheckboxState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicCheckboxSuccess) return;

    try {
      final styleModel = event.component.style; // Direct access
      final inputConfig = InputValidationModel.fromJson(
        event.component.config?.toJson() ?? {},
      );

      // Get updated value
      final value = event.component.config?.value == true;

      // Compute editable state - create fallback if properties don't exist
      final isEditable = true; // Default to editable

      final formState = _computeFormState(event.component, value);
      final errorText = _validateCheckbox(event.component, value);

      // Recompute styles
      final computedStyles = _computeStyles(event.component, value);

      debugPrint(
        '🔄 [CheckboxBloc] External update: ${event.component.id}, value: $value, state: $formState',
      );

      emit(
        currentState.copyWith(
          component: event.component,
          styleModel: styleModel,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          isSelected: value,
          isEditable: isEditable,
          backgroundColor:
              computedStyles['backgroundColor'] ?? Colors.transparent,
          borderColor: computedStyles['borderColor'] ?? Colors.grey,
          borderWidth: computedStyles['borderWidth'] ?? 1.0,
          iconColor: computedStyles['iconColor'] ?? Colors.white,
          controlWidth: computedStyles['controlWidth'] ?? 40.0,
          controlHeight: computedStyles['controlHeight'] ?? 40.0,
          controlBorderRadius: computedStyles['controlBorderRadius'] ?? 8.0,
          leadingIconData: computedStyles['leadingIconData'],
        ),
      );
    } catch (e) {
      debugPrint('❌ [CheckboxBloc] External update error: $e');
      emit(
        DynamicCheckboxError(
          errorMessage: 'Failed to update from external: ${e.toString()}',
          component: event.component,
        ),
      );
    }
  }

  DynamicFormModel _updateComponentValue(
    DynamicFormModel component,
    bool newValue,
  ) {
    final updatedConfig = component.config?.toJson() ?? {};
    updatedConfig['value'] = newValue;

    return DynamicFormModel(
      id: component.id,
      type: component.type,
      config: ConfigModel.fromJson(updatedConfig),
      style: component.style,
      variants: component.variants,
      states: component.states,
      validation: component.validation,
      inputTypes: component.inputTypes,
      order: component.order,
    );
  }

  StatesEnum _computeFormState(
    DynamicFormModel component,
    bool isSelected,
  ) {
    // Checkbox state logic: selected = success, unselected = base
    return isSelected ? StatesEnum.success : StatesEnum.base;
  }

  String? _validateCheckbox(DynamicFormModel component, bool isSelected) {
    return ValidationUtils.validateForm(component, isSelected.toString());
  }

  Map<String, dynamic> _computeStyles(
    DynamicFormModel component,
    bool isSelected,
  ) {
    // Determine current state
    final currentState = isSelected ? StatesEnum.success : StatesEnum.base;

    // Build combined style - use direct properties instead of toJson()
    Map<String, dynamic> style = {
      'backgroundColor': component.style.backgroundColor ?? Colors.transparent,
      'borderColor': component.style.borderColor ?? Colors.grey,
      'borderWidth': component.style.borderWidth ?? 1.0,
      'iconColor': component.style.iconColor ?? Colors.white,
      'controlWidth': 40.0,
      'controlHeight': 40.0,
      'controlBorderRadius': component.style.borderRadius ?? 8.0,
    };

    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
      component.states,
      currentState,
    );
    if (stateStyle != null) {
      // Apply state-specific styles if available - use basic properties
      style['backgroundColor'] = Colors.green; // Success state color
      style['borderColor'] = Colors.green;
    }
    return style;
  }
}
