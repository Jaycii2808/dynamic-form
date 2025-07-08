import 'package:equatable/equatable.dart';

abstract class MultiPageFormEvent extends Equatable {
  const MultiPageFormEvent();
  @override
  List<Object?> get props => [];
}

class LoadMultiPageForm extends MultiPageFormEvent {
  final String configKey;
  const LoadMultiPageForm(this.configKey);
  @override
  List<Object?> get props => [configKey];
}

class UpdateComponentValue extends MultiPageFormEvent {
  final String componentId;
  final dynamic value;
  const UpdateComponentValue(this.componentId, this.value);
  @override
  List<Object?> get props => [componentId, value];
}

class NavigateToPage extends MultiPageFormEvent {
  final bool isNext;
  const NavigateToPage({required this.isNext});
  @override
  List<Object?> get props => [isNext];
}

class SubmitMultiPageForm extends MultiPageFormEvent {

  const SubmitMultiPageForm();
}