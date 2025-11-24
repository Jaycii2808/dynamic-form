import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';
import 'package:equatable/equatable.dart';

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
  final DropdownActionOptionsEnum? action;
  final String? targetSection;

  const DropdownOptionSelectedEvent({
    required this.value,
    this.action,
    this.targetSection,
  });

  @override
  List<Object?> get props => [value, action, targetSection];
}
