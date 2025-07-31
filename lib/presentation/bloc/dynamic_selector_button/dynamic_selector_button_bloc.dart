import 'dart:async';

import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    debugPrint(
      'DynamicSelectorButtonBloc: Initial config: ${initialComponent.config?.toJson()}',
    );
    debugPrint(
      'DynamicSelectorButtonBloc: Initial value: ${initialComponent.config?.value}',
    );
    debugPrint(
      'DynamicSelectorButtonBloc: Initial selected: ${initialComponent.config?.selected}',
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
          inputConfig: InputValidationModel.fromJson(
            initialComponent.config?.toJson() ?? {},
          ),
          styleModel: initialComponent.style,
          formState: initialComponent.config?.currentState ?? StatesEnum.base,
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

    final newState = event.isSelected ? StatesEnum.success : StatesEnum.base;

    final updatedComponent = ComponentUtils.updateComponentWithValue(
      successState.component!,
      event.isSelected,
      currentState: newState,
      selected: event.isSelected,
    );

    debugPrint(
      'DynamicSelectorButtonBloc: Emitting Success after toggle for component: ${initialComponent.id}',
    );
    emit(
      DynamicSelectorButtonSuccess(
        component: updatedComponent,
        inputConfig: InputValidationModel.fromJson(
          updatedComponent.config?.toJson() ?? {},
        ),
        styleModel: updatedComponent.style,
        formState: newState,
      ),
    );
  }
}
