import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';

abstract class UserFormsState extends Equatable {
  final List<Map<String, dynamic>> userForms;
  final List<Map<String, dynamic>> formTemplates;
  final bool isLoading;
  final FormBuilderModel? importedForm;
  final String? openFormId;
  final FormBuilderModel? openFormModel;

  const UserFormsState({
    this.userForms = const [],
    this.formTemplates = const [],
    this.isLoading = false,
    this.importedForm,
    this.openFormId,
    this.openFormModel,
  });

  @override
  List<Object?> get props => [
    userForms,
    formTemplates,
    isLoading,
    importedForm,
    openFormId,
    openFormModel,
  ];
}

class UserFormsInitial extends UserFormsState {
  const UserFormsInitial();
}

class UserFormsLoading extends UserFormsState {
  const UserFormsLoading({
    super.userForms,
    super.formTemplates,
    super.importedForm,
    super.openFormId,
    super.openFormModel,
  });

  UserFormsLoading.fromState({required UserFormsState state})
    : super(
        userForms: state.userForms,
        formTemplates: state.formTemplates,
        isLoading: true,
        importedForm: state.importedForm,
        openFormId: state.openFormId,
        openFormModel: state.openFormModel,
      );
}

class UserFormsSuccess extends UserFormsState {
  const UserFormsSuccess({
    required super.userForms,
    required super.formTemplates,
    super.importedForm,
    super.openFormId,
    super.openFormModel,
  });

  UserFormsSuccess.fromState({required UserFormsState state})
    : super(
        userForms: state.userForms,
        formTemplates: state.formTemplates,
        isLoading: false,
        importedForm: state.importedForm,
        openFormId: state.openFormId,
        openFormModel: state.openFormModel,
      );

  UserFormsSuccess copyWith({
    List<Map<String, dynamic>>? userForms,
    List<Map<String, dynamic>>? formTemplates,
    FormBuilderModel? importedForm,
    String? openFormId,
    FormBuilderModel? openFormModel,
  }) {
    return UserFormsSuccess(
      userForms: userForms ?? this.userForms,
      formTemplates: formTemplates ?? this.formTemplates,
      importedForm: importedForm ?? this.importedForm,
      openFormId: openFormId ?? this.openFormId,
      openFormModel: openFormModel ?? this.openFormModel,
    );
  }
}

class UserFormsError extends UserFormsState {
  final String errorMessage;

  const UserFormsError({
    required this.errorMessage,
    super.userForms,
    super.formTemplates,
    super.importedForm,
    super.openFormId,
    super.openFormModel,
  });

  UserFormsError.fromState({
    required UserFormsState state,
    required this.errorMessage,
  }) : super(
         userForms: state.userForms,
         formTemplates: state.formTemplates,
         isLoading: false,
         importedForm: state.importedForm,
         openFormId: state.openFormId,
         openFormModel: state.openFormModel,
       );

  @override
  List<Object?> get props => [
    ...super.props,
    errorMessage,
  ];
}
