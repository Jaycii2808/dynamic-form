import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicSwitchState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleConfig? styleConfig;
  final FormStateEnum? formState;

  const DynamicSwitchState({
    this.component,
    this.inputConfig,
    this.styleConfig,
    this.formState,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    styleConfig,
    formState,
  ];
}

class DynamicSwitchInitial extends DynamicSwitchState {
  const DynamicSwitchInitial({super.component});
}

class DynamicSwitchLoading extends DynamicSwitchState {
  DynamicSwitchLoading.fromState({required DynamicSwitchState state})
      : super(
    component: state.component,
    inputConfig: state.inputConfig,
    styleConfig: state.styleConfig,
    formState: state.formState,
  );
}

class DynamicSwitchSuccess extends DynamicSwitchState {
  const DynamicSwitchSuccess({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
  });
}

class DynamicSwitchError extends DynamicSwitchState {
  final String? errorMessage;

  const DynamicSwitchError({
    required this.errorMessage,
    super.component,
  });

  @override
  List<Object?> get props => [errorMessage, component];
}