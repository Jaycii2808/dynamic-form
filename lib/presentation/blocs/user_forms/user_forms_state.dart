import 'package:equatable/equatable.dart';

abstract class UserFormsState extends Equatable {
  final List<Map<String, dynamic>> userForms;
  final List<Map<String, dynamic>> formTemplates;
  final bool isLoading;

  const UserFormsState({
    this.userForms = const [],
    this.formTemplates = const [],
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    userForms,
    formTemplates,
    isLoading,
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
       );

  @override
  List<Object?> get props => [
    userForms,
    formTemplates,
    isLoading,
    errorMessage,
  ];
}
