import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';

abstract class SharedFormEvent extends Equatable {
  const SharedFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadSharedFormEvent extends SharedFormEvent {
  final String formId;

  const LoadSharedFormEvent(this.formId);

  @override
  List<Object?> get props => [formId];
}

class FieldChangedEvent extends SharedFormEvent {
  final String componentId;
  final dynamic value;

  const FieldChangedEvent(this.componentId, this.value);

  @override
  List<Object?> get props => [componentId, value];
}

class ButtonActionEvent extends SharedFormEvent {
  final String action;
  final dynamic data;

  const ButtonActionEvent(this.action, this.data);

  @override
  List<Object?> get props => [action, data];
}

class SubmitFormEvent extends SharedFormEvent {
  const SubmitFormEvent();

  @override
  List<Object?> get props => [];
}

class NextPageEvent extends SharedFormEvent {
  const NextPageEvent();

  @override
  List<Object?> get props => [];
}

class PreviousPageEvent extends SharedFormEvent {
  const PreviousPageEvent();

  @override
  List<Object?> get props => [];
}

class InitializeEmailServiceEvent extends SharedFormEvent {
  const InitializeEmailServiceEvent();

  @override
  List<Object?> get props => [];
}

class ValidationErrorEvent extends SharedFormEvent {
  final String errorMessage;
  final List<String> missingFields;

  const ValidationErrorEvent({
    required this.errorMessage,
    required this.missingFields,
  });

  @override
  List<Object?> get props => [errorMessage, missingFields];
}

class ReturnToPreviousStateEvent extends SharedFormEvent {
  const ReturnToPreviousStateEvent();

  @override
  List<Object?> get props => [];
}

class NavigationActionEvent extends SharedFormEvent {
  final DropdownActionOptionsEnum action;
  final String? targetSection;

  const NavigationActionEvent({
    required this.action,
    this.targetSection,
  });

  @override
  List<Object?> get props => [action, targetSection];
}
