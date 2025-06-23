import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
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

  DynamicFormLoading.fromState({required DynamicFormState state}) : super(page: state.page);

  @override
  List<Object?> get props => [page];
}

class DynamicFormSuccess extends DynamicFormState {
  const DynamicFormSuccess({required DynamicFormPageModel page}) : super(page: page);

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
