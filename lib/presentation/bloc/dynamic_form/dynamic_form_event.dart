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
class UpdateFormField extends DynamicFormEvent {
  final String componentId;
  final dynamic value;

  const UpdateFormField({required this.componentId, required this.value});
  //props
  @override
  List<Object?> get props => [componentId, value];

}

class RefreshDynamicFormEvent extends DynamicFormEvent {
  final String configKey;

  const RefreshDynamicFormEvent({required this.configKey});

  @override
  List<Object?> get props => [configKey];
}