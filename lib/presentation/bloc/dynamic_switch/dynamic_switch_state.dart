import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicSwitchState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleModel? styleModel;
  final StatesEnum? formState;

  const DynamicSwitchState({
    this.component,
    this.inputConfig,
    this.styleModel,
    this.formState,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    styleModel,
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
        styleModel: state.styleModel,
        formState: state.formState,
      );
}

class DynamicSwitchSuccess extends DynamicSwitchState {
  const DynamicSwitchSuccess({
    super.component,
    super.inputConfig,
    super.styleModel,
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
