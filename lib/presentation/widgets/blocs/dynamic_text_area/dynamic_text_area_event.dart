import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicTextAreaEvent extends Equatable {
  const DynamicTextAreaEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTextAreaEvent extends DynamicTextAreaEvent {
  const InitializeTextAreaEvent();
}

class TextAreaFocusLostEvent extends DynamicTextAreaEvent {
  final String value;

  const TextAreaFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class UpdateTextAreaFromExternalEvent extends DynamicTextAreaEvent {
  final DynamicFormModel component;

  const UpdateTextAreaFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
