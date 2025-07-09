import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicCheckboxEvent extends Equatable {
  const DynamicCheckboxEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCheckboxEvent extends DynamicCheckboxEvent {
  const InitializeCheckboxEvent();
}

class CheckboxValueChangedEvent extends DynamicCheckboxEvent {
  final bool value;

  const CheckboxValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class UpdateCheckboxFromExternalEvent extends DynamicCheckboxEvent {
  final DynamicFormModel component;

  const UpdateCheckboxFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
