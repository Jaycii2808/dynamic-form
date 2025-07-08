import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_state.dart';

class DynamicSelectorButtonBloc
    extends Bloc<DynamicSelectorButtonEvent, DynamicSelectorButtonState> {
  final DynamicFormModel initialComponent;

  DynamicSelectorButtonBloc({required this.initialComponent})
    : super(DynamicSelectorButtonInitial(component: DynamicFormModel.empty())) {
    debugPrint(
      'DynamicSelectorButtonBloc created for component: ${initialComponent.id}',
    );
    on<InitializeSelectorButtonEvent>(_onInitialize);
    on<SelectorButtonToggledEvent>(_onToggled);
    add(const InitializeSelectorButtonEvent());
  }

  Future<void> _onInitialize(
    InitializeSelectorButtonEvent event,
    Emitter<DynamicSelectorButtonState> emit,
  ) async {
    debugPrint(
      'DynamicSelectorButtonBloc: _onInitialize called for component: ${initialComponent.id}',
    );
    emit(DynamicSelectorButtonLoading.fromState(state: state));
    try {
      if (initialComponent.id.isEmpty) {
        debugPrint('DynamicSelectorButtonBloc: initialComponent.id is empty!');
        throw Exception("Invalid initial component: ID is empty.");
      }
      debugPrint(
        'DynamicSelectorButtonBloc: Emitting Success for component: ${initialComponent.id}',
      );
      emit(
        DynamicSelectorButtonSuccess(
          component: initialComponent,
          inputConfig: InputConfig.fromJson(initialComponent.config),
          styleConfig: StyleConfig.fromJson(initialComponent.style),
          formState:
              FormStateEnum.fromString(
                initialComponent.config['currentState'],
              ) ??
              FormStateEnum.base,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to initialize SelectorButton: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicSelectorButtonError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onToggled(
    SelectorButtonToggledEvent event,
    Emitter<DynamicSelectorButtonState> emit,
  ) async {
    debugPrint(
      'DynamicSelectorButtonBloc: _onToggled called for component: ${initialComponent.id}, isSelected: ${event.isSelected}',
    );
    if (state is! DynamicSelectorButtonSuccess) {
      debugPrint(
        'DynamicSelectorButtonBloc: _onToggled ignored, state is not Success',
      );
      return;
    }
    final successState = state as DynamicSelectorButtonSuccess;

    final newState = event.isSelected
        ? FormStateEnum.success
        : FormStateEnum.base;

    final updatedConfig = Map<String, dynamic>.from(
      successState.component!.config,
    );
    updatedConfig[ValueKeyEnum.value.key] = event.isSelected;
    updatedConfig['selected'] = event.isSelected; // For compatibility
    updatedConfig[ValueKeyEnum.currentState.key] = newState.value;
    updatedConfig[ValueKeyEnum.errorText.key] =
        null; // No validation error for this component

    final updatedComponent = ComponentUtils.updateComponentConfig(
      successState.component!,
      updatedConfig,
    );

    debugPrint(
      'DynamicSelectorButtonBloc: Emitting Success after toggle for component: ${initialComponent.id}',
    );
    emit(
      DynamicSelectorButtonSuccess(
        component: updatedComponent,
        inputConfig: InputConfig.fromJson(updatedComponent.config),
        styleConfig: StyleConfig.fromJson(updatedComponent.style),
        formState: newState,
      ),
    );
  }
}
