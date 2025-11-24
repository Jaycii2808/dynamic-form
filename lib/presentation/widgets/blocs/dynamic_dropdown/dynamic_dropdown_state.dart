import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';

abstract class DynamicDropdownState extends Equatable {
  final DynamicFormModel component;
  final InputValidationModel inputConfig;
  final String? currentValue;
  final String? errorText;
  final StatesEnum currentState;

  const DynamicDropdownState({
    required this.component,
    required this.inputConfig,
    this.currentValue,
    this.errorText,
    required this.currentState,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    currentValue,
    errorText,
    currentState,
  ];
}

class DynamicDropdownInitial extends DynamicDropdownState {
  const DynamicDropdownInitial({
    required super.component,
    required super.inputConfig,
    super.currentValue,
    super.errorText,
    super.currentState = StatesEnum.base,
  });
}

class DynamicDropdownLoading extends DynamicDropdownState {
  const DynamicDropdownLoading({
    required super.component,
    required super.inputConfig,
    super.currentValue,
    super.errorText,
    super.currentState = StatesEnum.loading,
  });

  DynamicDropdownLoading.fromState({required DynamicDropdownState state})
    : super(
        component: state.component,
        inputConfig: state.inputConfig,
        currentValue: state.currentValue,
        errorText: state.errorText,
        currentState: StatesEnum.loading,
      );
}

class DynamicDropdownSuccess extends DynamicDropdownState {
  const DynamicDropdownSuccess({
    required super.component,
    required super.inputConfig,
    super.currentValue,
    super.errorText,
    super.currentState = StatesEnum.success,
  });

  DynamicDropdownSuccess.fromState({required DynamicDropdownState state})
    : super(
        component: state.component,
        inputConfig: state.inputConfig,
        currentValue: state.currentValue,
        errorText: state.errorText,
        currentState: StatesEnum.success,
      );

  DynamicDropdownSuccess copyWith({
    DynamicFormModel? component,
    InputValidationModel? inputConfig,
    String? currentValue,
    String? errorText,
    StatesEnum? currentState,
  }) {
    return DynamicDropdownSuccess(
      component: component ?? this.component,
      inputConfig: inputConfig ?? this.inputConfig,
      currentValue: currentValue ?? this.currentValue,
      errorText: errorText ?? this.errorText,
      currentState: currentState ?? this.currentState,
    );
  }
}

class DynamicDropdownError extends DynamicDropdownState {
  final String? errorMessage;

  const DynamicDropdownError({
    required super.component,
    required super.inputConfig,
    super.currentValue,
    super.errorText,
    super.currentState = StatesEnum.error,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    currentValue,
    errorText,
    currentState,
    errorMessage,
  ];
}
