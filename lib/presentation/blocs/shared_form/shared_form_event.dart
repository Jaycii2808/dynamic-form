import 'package:equatable/equatable.dart';

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