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

class ToggleButtonComponentsPanelEvent extends FormBuilderEvent {
  const ToggleButtonComponentsPanelEvent();
}

class LoadButtonComponentsEvent extends FormBuilderEvent {
  const LoadButtonComponentsEvent();
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

class UpdateFormTitleEvent extends FormBuilderEvent {
  final String title;

  const UpdateFormTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdatePageTitleEvent extends FormBuilderEvent {
  final String pageId;
  final String title;

  const UpdatePageTitleEvent({
    required this.pageId,
    required this.title,
  });

  @override
  List<Object?> get props => [pageId, title];
}

class SwitchPageEvent extends FormBuilderEvent {
  final String pageId;

  const SwitchPageEvent(this.pageId);

  @override
  List<Object?> get props => [pageId];
}

class AddPageEvent extends FormBuilderEvent {
  const AddPageEvent();
}

class AddPageWithTitleEvent extends FormBuilderEvent {
  final String title;

  const AddPageWithTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdateFirstPageTitleEvent extends FormBuilderEvent {
  final String title;

  const UpdateFirstPageTitleEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class RemovePageEvent extends FormBuilderEvent {
  final String pageId;

  const RemovePageEvent(this.pageId);

  @override
  List<Object?> get props => [pageId];
}

class SubmitFormEvent extends FormBuilderEvent {
  const SubmitFormEvent();
}
