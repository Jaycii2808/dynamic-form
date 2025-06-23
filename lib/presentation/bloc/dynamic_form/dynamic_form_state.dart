import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicFormState extends Equatable {
  final DynamicFormPageModel? page;
  final String? errorMessage;

  const DynamicFormState({this.page, this.errorMessage});

  @override
  List<Object?> get props => [page, errorMessage];
}

class DynamicFormInitial extends DynamicFormState {
  const DynamicFormInitial({super.page, super.errorMessage});

  @override
  List<Object?> get props => [page, errorMessage];
}

class DynamicFormLoading extends DynamicFormState {
  const DynamicFormLoading({super.page, super.errorMessage});

  DynamicFormLoading.fromState({required DynamicFormState state})
    : super(page: state.page, errorMessage: state.errorMessage);

  @override
  List<Object?> get props => [page, errorMessage];
}

class DynamicFormSuccess extends DynamicFormState {
  const DynamicFormSuccess({
    required DynamicFormPageModel page,
    super.errorMessage,
  }) : super(page: page);

  DynamicFormSuccess.fromState({
    required DynamicFormState state,
    required DynamicFormPageModel page,
  }) : super(page: page, errorMessage: state.errorMessage);

  @override
  List<Object?> get props => [page, errorMessage];
}

class DynamicFormError extends DynamicFormState {
  const DynamicFormError({required String errorMessage, super.page})
    : super(errorMessage: errorMessage);

  @override
  List<Object?> get props => [page, errorMessage];
}

class DynamicFormEmpty extends DynamicFormState {
  const DynamicFormEmpty({super.page, super.errorMessage});

  @override
  List<Object?> get props => [page, errorMessage];
}
