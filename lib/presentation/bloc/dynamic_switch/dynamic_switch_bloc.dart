import 'dart:async';

import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/components/field_update_data_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_switch/dynamic_switch_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_switch/dynamic_switch_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSwitchBloc extends Bloc<DynamicSwitchEvent, DynamicSwitchState> {
  final DynamicFormModel initialComponent;

  DynamicSwitchBloc({required this.initialComponent})
    : super(DynamicSwitchInitial(component: DynamicFormModel.empty())) {
    on<InitializeSwitchEvent>(_onInitialize);
    on<SwitchToggledEvent>(_onToggled);

    add(const InitializeSwitchEvent());
  }

  Future<void> _onInitialize(
    InitializeSwitchEvent event,
    Emitter<DynamicSwitchState> emit,
  ) async {
    emit(DynamicSwitchLoading.fromState(state: state));
    try {
      if (initialComponent.id.isEmpty) {
        throw Exception("Invalid initial component: ID is empty.");
      }
      emit(
        DynamicSwitchSuccess(
          component: initialComponent,
          inputConfig: InputValidationModel.fromJson(
            initialComponent.config?.toJson() ?? {},
          ),
          styleModel: initialComponent.style,
          formState: initialComponent.config?.currentState ?? StatesEnum.base,
        ),
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to initialize Switch: $e';
      debugPrint('❌ Error: $errorMessage, StackTrace: $stackTrace');
      emit(
        DynamicSwitchError(
          errorMessage: errorMessage,
          component: state.component,
        ),
      );
    }
  }

  Future<void> _onToggled(
    SwitchToggledEvent event,
    Emitter<DynamicSwitchState> emit,
  ) async {
    if (state is! DynamicSwitchSuccess) return;
    final successState = state as DynamicSwitchSuccess;

    // Use centralized method to create update data
    final updateData = ValidationUtils.createFieldUpdateData(
      value: event.value,
      selected: event.value, // for boolean-like components
    );

    final updatedConfig = Map<String, dynamic>.from(
      successState.component!.config?.toJson() ?? {},
    )..addAll(updateData.toLegacyMap());

    final updatedComponent = ComponentUtils.updateComponentConfig(
      successState.component!,
      ConfigModel.fromJson(updatedConfig),
    );

    emit(
      DynamicSwitchSuccess(
        component: updatedComponent,
        inputConfig: InputValidationModel.fromJson(
          updatedComponent.config?.toJson() ?? {},
        ),
        styleModel: updatedComponent.style,
        formState: updateData.currentState,
      ),
    );
  }
}
