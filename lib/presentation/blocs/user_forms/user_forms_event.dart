import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';

abstract class UserFormsEvent extends Equatable {
  const UserFormsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserFormsEvent extends UserFormsEvent {
  final String? userId;

  const LoadUserFormsEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}

class SaveUserFormEvent extends UserFormsEvent {
  final FormBuilderModel formBuilderModel;
  final String? userId;

  const SaveUserFormEvent({
    required this.formBuilderModel,
    this.userId,
  });

  @override
  List<Object?> get props => [formBuilderModel, userId];
}

class UpdateUserFormEvent extends UserFormsEvent {
  final String formId;
  final FormBuilderModel formBuilderModel;
  final String? userId;

  const UpdateUserFormEvent({
    required this.formId,
    required this.formBuilderModel,
    this.userId,
  });

  @override
  List<Object?> get props => [formId, formBuilderModel, userId];
}

class DeleteUserFormEvent extends UserFormsEvent {
  final String formId;
  final String? userId;

  const DeleteUserFormEvent({
    required this.formId,
    this.userId,
  });

  @override
  List<Object?> get props => [formId, userId];
}

class CreateUserFormFromTemplateEvent extends UserFormsEvent {
  final Map<String, dynamic> templateData;
  final String templateName;
  final String? userId;

  const CreateUserFormFromTemplateEvent({
    required this.templateData,
    required this.templateName,
    this.userId,
  });

  @override
  List<Object?> get props => [templateData, templateName, userId];
}

class LoadFormTemplatesEvent extends UserFormsEvent {
  const LoadFormTemplatesEvent();
}
