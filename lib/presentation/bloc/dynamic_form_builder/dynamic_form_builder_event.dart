import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:equatable/equatable.dart';

abstract class FormBuilderEvent extends Equatable {
  const FormBuilderEvent();

  @override
  List<Object?> get props => [];
}

class LoadComponentsEvent extends FormBuilderEvent {
  const LoadComponentsEvent();
}

class AddComponentEvent extends FormBuilderEvent {
  final DynamicFormModel component;

  const AddComponentEvent(this.component);

  @override
  List<Object?> get props => [component];
}

class MoveComponentEvent extends FormBuilderEvent {
  final int oldIndex;
  final int newIndex;

  const MoveComponentEvent({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class RemoveComponentEvent extends FormBuilderEvent {
  final int index;

  const RemoveComponentEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class StartDragEvent extends FormBuilderEvent {
  final DynamicFormModel component;

  const StartDragEvent(this.component);

  @override
  List<Object?> get props => [component];
}

class EndDragEvent extends FormBuilderEvent {
  final DynamicFormModel component;

  const EndDragEvent(this.component);

  @override
  List<Object?> get props => [component];
}

class ToggleComponentsPanelEvent extends FormBuilderEvent {
  const ToggleComponentsPanelEvent();
}

class ClearCanvasEvent extends FormBuilderEvent {
  const ClearCanvasEvent();
}

class UpdateComponentValueEvent extends FormBuilderEvent {
  final String componentId;
  final dynamic value;

  const UpdateComponentValueEvent({
    required this.componentId,
    required this.value,
  });

  @override
  List<Object?> get props => [componentId, value];
}

class HandleComponentActionEvent extends FormBuilderEvent {
  final ComponentActionEnum action;
  final int index;

  const HandleComponentActionEvent({
    required this.action,
    required this.index,
  });

  @override
  List<Object?> get props => [action, index];
}
