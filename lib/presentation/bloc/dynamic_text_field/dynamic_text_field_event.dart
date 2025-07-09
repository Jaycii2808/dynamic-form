import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicTextFieldEvent extends Equatable {
  const DynamicTextFieldEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTextFieldEvent extends DynamicTextFieldEvent {
  const InitializeTextFieldEvent();
}

class TextFieldValueChangedEvent extends DynamicTextFieldEvent {
  final String value;

  const TextFieldValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class TextFieldFocusLostEvent extends DynamicTextFieldEvent {
  final String value;

  const TextFieldFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class UpdateTextFieldFromExternalEvent extends DynamicTextFieldEvent {
  final DynamicFormModel component;

  const UpdateTextFieldFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
