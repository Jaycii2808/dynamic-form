import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class DynamicSwitchEvent extends Equatable {
  const DynamicSwitchEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSwitchEvent extends DynamicSwitchEvent {
  const InitializeSwitchEvent();
}

class SwitchToggledEvent extends DynamicSwitchEvent {
  final bool value;

  const SwitchToggledEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class UpdateSwitchFromExternalEvent extends DynamicSwitchEvent {
  final DynamicFormModel component;

  const UpdateSwitchFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
