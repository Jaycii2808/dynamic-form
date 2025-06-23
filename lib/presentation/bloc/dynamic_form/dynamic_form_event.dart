import 'package:equatable/equatable.dart';

abstract class DynamicFormEvent extends Equatable {
  const DynamicFormEvent();
  @override
  List<Object?> get props => [];
}

class LoadDynamicFormPageEvent extends DynamicFormEvent {
  final String configKey;

  const LoadDynamicFormPageEvent({required this.configKey});

  @override
  List<Object?> get props => [configKey];
}

class RefreshDynamicFormPageEvent extends DynamicFormEvent {
  final String configKey;

  const RefreshDynamicFormPageEvent({required this.configKey});

  @override
  List<Object?> get props => [configKey];
}
