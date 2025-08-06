import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';
import 'package:equatable/equatable.dart';

abstract class DropdownFormBuilderWidgetEvent extends Equatable {
  const DropdownFormBuilderWidgetEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDropdownFormBuilderEvent
    extends DropdownFormBuilderWidgetEvent {
  final DynamicFormModel component;
  final List<String>? availablePages;

  const InitializeDropdownFormBuilderEvent({
    required this.component,
    this.availablePages,
  });

  @override
  List<Object?> get props => [component, availablePages];
}

class UpdateQuestionEvent extends DropdownFormBuilderWidgetEvent {
  final String question;

  const UpdateQuestionEvent(this.question);

  @override
  List<Object?> get props => [question];
}

class UpdatePlaceholderEvent extends DropdownFormBuilderWidgetEvent {
  final String placeholder;

  const UpdatePlaceholderEvent(this.placeholder);

  @override
  List<Object?> get props => [placeholder];
}

class UpdateRequiredEvent extends DropdownFormBuilderWidgetEvent {
  final bool isRequired;

  const UpdateRequiredEvent(this.isRequired);

  @override
  List<Object?> get props => [isRequired];
}

class AddOptionEvent extends DropdownFormBuilderWidgetEvent {
  const AddOptionEvent();
}

class RemoveOptionEvent extends DropdownFormBuilderWidgetEvent {
  final int index;

  const RemoveOptionEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateOptionLabelEvent extends DropdownFormBuilderWidgetEvent {
  final int index;
  final String label;

  const UpdateOptionLabelEvent({
    required this.index,
    required this.label,
  });

  @override
  List<Object?> get props => [index, label];
}

class ReorderOptionsEvent extends DropdownFormBuilderWidgetEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderOptionsEvent({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class UpdateOptionNavigationEvent extends DropdownFormBuilderWidgetEvent {
  final int optionIndex;
  final DropdownActionOptionsEnum action;
  final String? targetSection;

  const UpdateOptionNavigationEvent({
    required this.optionIndex,
    required this.action,
    this.targetSection,
  });

  @override
  List<Object?> get props => [optionIndex, action, targetSection];
}

class EnableNavigationFeatureEvent extends DropdownFormBuilderWidgetEvent {
  const EnableNavigationFeatureEvent();
}

class UpdateComponentEvent extends DropdownFormBuilderWidgetEvent {
  const UpdateComponentEvent();
}
