import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';

abstract class DynamicDropdownEvent extends Equatable {
  const DynamicDropdownEvent();

  @override
  List<Object?> get props => [];
}

class DropdownValueChangedEvent extends DynamicDropdownEvent {
  final String? value;

  const DropdownValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DropdownFocusLostEvent extends DynamicDropdownEvent {
  final String? value;

  const DropdownFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DropdownValidationEvent extends DynamicDropdownEvent {
  final String? value;

  const DropdownValidationEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DropdownOptionSelectedEvent extends DynamicDropdownEvent {
  final String value;
  final String? action;
  final String? targetSection;

  const DropdownOptionSelectedEvent({
    required this.value,
    this.action,
    this.targetSection,
  });

  @override
  List<Object?> get props => [value, action, targetSection];
}
