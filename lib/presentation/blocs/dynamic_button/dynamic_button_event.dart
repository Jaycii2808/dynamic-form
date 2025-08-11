import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';

sealed class DynamicButtonEvent extends Equatable {
  const DynamicButtonEvent();
  @override
  List<Object?> get props => [];
}

class SetButtonComponentEvent extends DynamicButtonEvent {
  final DynamicFormModel component;
  const SetButtonComponentEvent(this.component);
  @override
  List<Object?> get props => [component];
}

class RecomputeButtonUiEvent extends DynamicButtonEvent {
  final Map<String, dynamic> externalValues;
  const RecomputeButtonUiEvent(this.externalValues);
  @override
  List<Object?> get props => [externalValues];
}

class ButtonPressedEvent extends DynamicButtonEvent {
  const ButtonPressedEvent();
}
