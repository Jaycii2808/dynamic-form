import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicRadioEvent extends Equatable {
  const DynamicRadioEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRadioEvent extends DynamicRadioEvent {
  const InitializeRadioEvent();
}

class RadioValueChangedEvent extends DynamicRadioEvent {
  final bool value;

  const RadioValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class UpdateRadioFromExternalEvent extends DynamicRadioEvent {
  final DynamicFormModel component;

  const UpdateRadioFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
