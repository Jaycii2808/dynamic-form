import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_state.dart';
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

      final styleConfig = StyleConfig.fromJson(initialComponent.style.toJson());
      final inputConfig = InputConfig.fromJson(initialComponent.config);

      // Get initial value
      final value = initialComponent.config[ValueKeyEnum.value.key];
      final isSelected = value == true;

      // Compute editable state
      final isEditable =
          (initialComponent.config['editable'] != false) &&
          (initialComponent.config['disabled'] != true);

      // Compute form state
      final formState = _computeFormState(initialComponent, isSelected);

      // Compute validation error
      final errorText = _validateCheckbox(initialComponent, isSelected);

      // Compute styles
      final computedStyles = _computeStyles(initialComponent, isSelected);

      debugPrint(
        '🟢 [CheckboxBloc] Initialized: ${initialComponent.id}, isSelected: $isSelected, state: $formState',
      );

      emit(
        DynamicCheckboxSuccess(
          component: initialComponent,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          isSelected: isSelected,
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
          formState: currentState.formState,
          errorText: currentState.errorText,
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
      final styleConfig = StyleConfig.fromJson(event.component.style.toJson());
      final inputConfig = InputConfig.fromJson(event.component.config);

      // Get updated value
      final value = event.component.config[ValueKeyEnum.value.key];
      final isSelected = value == true;

      // Compute editable state
      final isEditable =
          (event.component.config['editable'] != false) &&
          (event.component.config['disabled'] != true);

      final formState = _computeFormState(event.component, isSelected);
      final errorText = _validateCheckbox(event.component, isSelected);

      // Recompute styles
      final computedStyles = _computeStyles(event.component, isSelected);

      debugPrint(
        '🔄 [CheckboxBloc] External update: ${event.component.id}, value: $isSelected, state: $formState',
      );

      emit(
        currentState.copyWith(
          component: event.component,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          isSelected: isSelected,
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
    final updatedConfig = Map<String, dynamic>.from(component.config);
    updatedConfig[ValueKeyEnum.value.key] = newValue;

    return DynamicFormModel(
      id: component.id,
      type: component.type,
      config: updatedConfig,
      style: component.style,
      variants: component.variants,
      states: component.states,
      validation: component.validation,
      inputTypes: component.inputTypes,
      order: component.order,
    );
  }

  ComponentStateEnum _computeFormState(
    DynamicFormModel component,
    bool isSelected,
  ) {
    // Checkbox state logic: selected = success, unselected = base
    return isSelected ? ComponentStateEnum.success : ComponentStateEnum.base;
  }

  String? _validateCheckbox(DynamicFormModel component, bool isSelected) {
    return ValidationUtils.validateForm(component, isSelected.toString());
  }

  Map<String, dynamic> _computeStyles(
    DynamicFormModel component,
    bool isSelected,
  ) {
    // Determine current state
    final currentState = isSelected ? 'success' : 'base';

    // Build combined style
    Map<String, dynamic> style = component.style.toJson();

    final StyleStatesModel? stateStyle = _getTypedStateStyle(
      component.states,
      currentState,
    );
    if (stateStyle != null) {
      style.addAll(stateStyle.toJson());
    }
    return style;
  }

  StyleStatesModel? _getTypedStateStyle(StatesModel? states, String key) {
    switch (key) {
      case 'base':
        return states?.base;
      case 'error':
        return states?.error;
      case 'success':
        return states?.success;
      case 'focused':
        return states?.focused;
      default:
        return null;
    }
  }
}
