import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';

abstract class UserFormsState extends Equatable {
  final List<Map<String, dynamic>> userForms;
  final List<Map<String, dynamic>> formTemplates;
  final bool isLoading;
  final String? errorMessage;

  const UserFormsState({
    this.userForms = const [],
    this.formTemplates = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    userForms,
    formTemplates,
    isLoading,
    errorMessage,
  ];
}

class UserFormsInitial extends UserFormsState {
  const UserFormsInitial();
}

class UserFormsLoading extends UserFormsState {
  const UserFormsLoading({
    super.userForms,
    super.formTemplates,
  });

  UserFormsLoading.fromState({required UserFormsState state})
    : super(
        userForms: state.userForms,
        formTemplates: state.formTemplates,
        isLoading: true,
        errorMessage: state.errorMessage,
      );
}

class UserFormsSuccess extends UserFormsState {
  const UserFormsSuccess({
    required super.userForms,
    required super.formTemplates,
  });

  UserFormsSuccess.fromState({required UserFormsState state})
    : super(
        userForms: state.userForms,
        formTemplates: state.formTemplates,
        isLoading: false,
        errorMessage: state.errorMessage,
      );

  UserFormsSuccess copyWith({
    List<Map<String, dynamic>>? userForms,
    List<Map<String, dynamic>>? formTemplates,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserFormsSuccess(
      userForms: userForms ?? this.userForms,
      formTemplates: formTemplates ?? this.formTemplates,
    );
  }
}

class UserFormsError extends UserFormsState {
  final String errorMessage;

  const UserFormsError({
    required this.errorMessage,
    super.userForms,
    super.formTemplates,
  });

  UserFormsError.fromState({
    required UserFormsState state,
    required this.errorMessage,
  }) : super(
         userForms: state.userForms,
         formTemplates: state.formTemplates,
         isLoading: false,
         errorMessage: errorMessage,
       );

  @override
  List<Object?> get props => [
    userForms,
    formTemplates,
    isLoading,
    errorMessage,
  ];
}
