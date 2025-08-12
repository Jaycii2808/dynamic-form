import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart'; // Add import for Option
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';
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

class EditComponentConfigEvent extends FormBuilderEvent {
  final String componentId;
  final String? label;
  final String? placeholder;
  final String? description; // Add description field
  final dynamic value; // Change from String? to dynamic
  final bool? isRequired;
  final String? errorText;
  final List<Option>? options; // Add options for dropdown
  final BaseValidation?
  validation; // Add validation for components like short answer
  final dynamic validate; // Raw validate JSON to store in config

  const EditComponentConfigEvent({
    required this.componentId,
    this.label,
    this.placeholder,
    this.description, // Add description parameter
    this.value,
    this.isRequired,
    this.errorText,
    this.options, // Add options parameter
    this.validation, // Add validation parameter
    this.validate, // Add raw validate JSON parameter
  });

  @override
  List<Object?> get props => [
    componentId,
    label,
    placeholder,
    description, // Add description to props
    value,
    isRequired,
    errorText,
    options, // Add options to props
    validation, // Add validation to props
    validate, // Add raw validate to props
  ];
}

class EditComponentLabelEvent extends FormBuilderEvent {
  final String componentId;
  final String label;

  const EditComponentLabelEvent({
    required this.componentId,
    required this.label,
  });

  @override
  List<Object?> get props => [componentId, label];
}

class EditComponentPlaceholderEvent extends FormBuilderEvent {
  final String componentId;
  final String placeholder;

  const EditComponentPlaceholderEvent({
    required this.componentId,
    required this.placeholder,
  });

  @override
  List<Object?> get props => [componentId, placeholder];
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

class CopyPageEvent extends FormBuilderEvent {
  final String pageId;

  const CopyPageEvent(this.pageId);

  @override
  List<Object?> get props => [pageId];
}

class SubmitFormEvent extends FormBuilderEvent {
  const SubmitFormEvent();
}

class InsertComponentEvent extends FormBuilderEvent {
  final DynamicFormModel component;
  final int insertIndex;

  const InsertComponentEvent({
    required this.component,
    required this.insertIndex,
  });

  @override
  List<Object?> get props => [component, insertIndex];
}

class StartHoverEvent extends FormBuilderEvent {
  final int targetIndex;
  final DynamicFormModel draggedComponent;

  const StartHoverEvent({
    required this.targetIndex,
    required this.draggedComponent,
  });

  @override
  List<Object?> get props => [targetIndex, draggedComponent];
}

class EndHoverEvent extends FormBuilderEvent {
  const EndHoverEvent();
}

class ShowInsertIndicatorEvent extends FormBuilderEvent {
  final int insertIndex;

  const ShowInsertIndicatorEvent(this.insertIndex);

  @override
  List<Object?> get props => [insertIndex];
}

class HideInsertIndicatorEvent extends FormBuilderEvent {
  const HideInsertIndicatorEvent();
}

class ForceRebuildUIEvent extends FormBuilderEvent {
  const ForceRebuildUIEvent();
}

class LoadExistingFormEvent extends FormBuilderEvent {
  final FormBuilderModel form;

  const LoadExistingFormEvent(this.form);

  @override
  List<Object?> get props => [form];
}

class ForceSaveAllComponentsEvent extends FormBuilderEvent {
  const ForceSaveAllComponentsEvent();
}

/// Ask UI to highlight and scroll to a specific component by id
class HighlightComponentEvent extends FormBuilderEvent {
  final String componentId;
  const HighlightComponentEvent(this.componentId);

  @override
  List<Object?> get props => [componentId];
}
