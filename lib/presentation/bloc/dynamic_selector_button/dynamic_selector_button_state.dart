import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicSelectorButtonState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleModel? styleModel;
  final ComponentStateEnum? formState;
  final String? errorText;

  const DynamicSelectorButtonState({
    this.component,
    this.inputConfig,
    this.styleModel,
    this.formState,
    this.errorText,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    styleModel,
    formState,
    errorText,
  ];
}

class DynamicSelectorButtonInitial extends DynamicSelectorButtonState {
  const DynamicSelectorButtonInitial({super.component});
}

class DynamicSelectorButtonLoading extends DynamicSelectorButtonState {
  DynamicSelectorButtonLoading.fromState({required DynamicSelectorButtonState state})
      : super(
    component: state.component,
    inputConfig: state.inputConfig,
    styleModel: state.styleModel,
    formState: state.formState,
    errorText: state.errorText,
  );
}

class DynamicSelectorButtonSuccess extends DynamicSelectorButtonState {
  const DynamicSelectorButtonSuccess({
    super.component,
    super.inputConfig,
    super.styleModel,
    super.formState,
    super.errorText,
  });
}

class DynamicSelectorButtonError extends DynamicSelectorButtonState {
  final String? errorMessage;

  const DynamicSelectorButtonError({
    required this.errorMessage,
    super.component,
  });

  @override
  List<Object?> get props => [errorMessage, component];
}