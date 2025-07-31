import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_errors_model.dart';
import 'package:equatable/equatable.dart';

abstract class MultiPageFormState extends Equatable {
  final DynamicMultiPageFormModel? formModel;
  final int currentPageIndex;
  final ComponentValuesModel componentValues;
  final ValidationErrorsModel validationErrors;

  const MultiPageFormState({
    this.formModel,
    this.currentPageIndex = 0,
    this.componentValues = const ComponentValuesModel(),
    this.validationErrors = const ValidationErrorsModel(),
  });

  // Getter to easily access the current page model
  FormForMultiPageModel? get currentPage =>
      formModel != null && formModel!.pages.length > currentPageIndex
      ? formModel!.pages[currentPageIndex]
      : null;

  @override
  List<Object?> get props => [
    formModel,
    currentPageIndex,
    componentValues,
    validationErrors,
  ];
}

class MultiPageFormInitial extends MultiPageFormState {
  const MultiPageFormInitial({
    super.formModel,
    super.currentPageIndex = 0,
    super.componentValues = const ComponentValuesModel(),
    super.validationErrors = const ValidationErrorsModel(),
  });
}

class MultiPageFormLoading extends MultiPageFormState {
  const MultiPageFormLoading({
    super.formModel,
    super.currentPageIndex,
    super.componentValues,
    super.validationErrors,
  });

  factory MultiPageFormLoading.fromState(MultiPageFormState state) {
    return MultiPageFormLoading(
      formModel: state.formModel,
      currentPageIndex: state.currentPageIndex,
      componentValues: state.componentValues,
      validationErrors: state.validationErrors,
    );
  }
}

class MultiPageFormSuccess extends MultiPageFormState {
  const MultiPageFormSuccess({
    super.formModel,
    super.currentPageIndex,
    super.componentValues,
    super.validationErrors,
  });

  MultiPageFormSuccess copyWith({
    DynamicMultiPageFormModel? formModel,
    int? currentPageIndex,
    ComponentValuesModel? componentValues,
    ValidationErrorsModel? validationErrors,
  }) {
    return MultiPageFormSuccess(
      formModel: formModel ?? this.formModel,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      componentValues: componentValues ?? this.componentValues,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

class MultiPageFormError extends MultiPageFormState {
  final String? errorMessage;

  const MultiPageFormError({
    this.errorMessage,
    super.formModel,
    super.currentPageIndex,
    super.componentValues,
    super.validationErrors,
  });

  @override
  List<Object?> get props => [
    errorMessage,
    formModel,
    currentPageIndex,
    componentValues,
    validationErrors,
  ];
}
