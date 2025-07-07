import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicFormState extends Equatable {
  final DynamicFormPageModel? page;

  const DynamicFormState({this.page});

  @override
  List<Object?> get props => [page];
}

class DynamicFormInitial extends DynamicFormState {
  const DynamicFormInitial({super.page});

  @override
  List<Object?> get props => [page];
}

class DynamicFormLoading extends DynamicFormState {
  const DynamicFormLoading({super.page});

  DynamicFormLoading.fromState({required DynamicFormState state})
    : super(page: state.page);

  @override
  List<Object?> get props => [page];
}

class DynamicFormSuccess extends DynamicFormState {
  const DynamicFormSuccess({required DynamicFormPageModel page})
    : super(page: page);

  const DynamicFormSuccess.fromState({
    required DynamicFormState state,
    required DynamicFormPageModel page,
  }) : super(page: page);

  @override
  List<Object?> get props => [page];
}

class DynamicFormError extends DynamicFormState {
  final String? errorMessage;

  const DynamicFormError({required this.errorMessage, super.page});

  @override
  List<Object?> get props => [page, errorMessage];
}

extension DynamicFormStateX on DynamicFormState {
  DynamicFormModel get component {
    return page?.components.isNotEmpty == true
        ? page!.components.first
        : DynamicFormModel.empty();
  }

  InputConfig? get inputConfig => component.config.isNotEmpty
      ? InputConfig.fromJson(component.config)
      : null;

  FormStateEnum get currentState => inputConfig?.currentState != null
      ? FormStateEnum.fromString(inputConfig!.currentState) ??
            FormStateEnum.base
      : FormStateEnum.base;

  StyleConfig? get styleConfig =>
      component.style.isNotEmpty ? StyleConfig.fromJson(component.style) : null;

  DynamicFormModel? get widgetComponent => null;

  DynamicFormModel getComponentById(String componentId) {
    return page?.components.firstWhere(
          (component) => component.id == componentId,
          orElse: () => DynamicFormModel.empty(),
        ) ??
        DynamicFormModel.empty();
  }

  InputConfig? getInputConfig(String componentId) {
    final component = getComponentById(componentId);
    return component.config.isNotEmpty
        ? InputConfig.fromJson(component.config)
        : null;
  }

  FormStateEnum getCurrentState(String componentId) {
    final inputConfig = getInputConfig(componentId);
    return inputConfig?.currentState != null
        ? FormStateEnum.fromString(inputConfig!.currentState) ??
              FormStateEnum.base
        : FormStateEnum.base;
  }

  StyleConfig? getStyleConfig(String componentId) {
    final component = getComponentById(componentId);
    return component.style.isNotEmpty
        ? StyleConfig.fromJson(component.style)
        : null;
  }
}
