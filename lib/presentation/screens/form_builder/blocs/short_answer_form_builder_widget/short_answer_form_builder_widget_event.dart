import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

// Events
sealed class ShortAnswerFormBuilderWidgetEvent extends Equatable {
  const ShortAnswerFormBuilderWidgetEvent();

  @override
  List<Object?> get props => [];
}

class InitializeShortAnswerFormBuilderEvent
    extends ShortAnswerFormBuilderWidgetEvent {
  final DynamicFormModel component;
  final List<String>? availablePages;

  const InitializeShortAnswerFormBuilderEvent({
    required this.component,
    this.availablePages,
  });

  @override
  List<Object?> get props => [component, availablePages];
}

class UpdateQuestionEvent extends ShortAnswerFormBuilderWidgetEvent {
  final String question;

  const UpdateQuestionEvent(this.question);

  @override
  List<Object?> get props => [question];
}

class UpdateDescriptionEvent extends ShortAnswerFormBuilderWidgetEvent {
  final String description;

  const UpdateDescriptionEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdateRequiredEvent extends ShortAnswerFormBuilderWidgetEvent {
  final bool isRequired;

  const UpdateRequiredEvent(this.isRequired);

  @override
  List<Object?> get props => [isRequired];
}

class SetEditingDescriptionEvent extends ShortAnswerFormBuilderWidgetEvent {
  final bool isEditing;

  const SetEditingDescriptionEvent(this.isEditing);

  @override
  List<Object?> get props => [isEditing];
}

class CancelEditDescriptionEvent extends ShortAnswerFormBuilderWidgetEvent {
  const CancelEditDescriptionEvent();
}

class ToggleDescriptionEnabledEvent extends ShortAnswerFormBuilderWidgetEvent {
  const ToggleDescriptionEnabledEvent();
}

class ClearDescriptionEvent extends ShortAnswerFormBuilderWidgetEvent {
  const ClearDescriptionEvent();
}

class ToggleValidationPanelEvent extends ShortAnswerFormBuilderWidgetEvent {
  final bool visible;

  const ToggleValidationPanelEvent(this.visible);

  @override
  List<Object?> get props => [visible];
}

class UpdateValidationTypeEvent extends ShortAnswerFormBuilderWidgetEvent {
  final ShortAnswerValidationType validationType;

  const UpdateValidationTypeEvent(this.validationType);

  @override
  List<Object?> get props => [validationType];
}

class UpdateNumberActionEvent extends ShortAnswerFormBuilderWidgetEvent {
  final NumberValidationAction action;

  const UpdateNumberActionEvent(this.action);

  @override
  List<Object?> get props => [action];
}

class UpdateTextActionEvent extends ShortAnswerFormBuilderWidgetEvent {
  final TextValidationAction action;

  const UpdateTextActionEvent(this.action);

  @override
  List<Object?> get props => [action];
}

class UpdateLengthTypeEvent extends ShortAnswerFormBuilderWidgetEvent {
  final LengthValidationType lengthType;

  const UpdateLengthTypeEvent(this.lengthType);

  @override
  List<Object?> get props => [lengthType];
}

class UpdateRegexActionEvent extends ShortAnswerFormBuilderWidgetEvent {
  final RegexValidationAction action;

  const UpdateRegexActionEvent(this.action);

  @override
  List<Object?> get props => [action];
}

class UpdateValidationValueEvent extends ShortAnswerFormBuilderWidgetEvent {
  final String value;

  const UpdateValidationValueEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class UpdateValidationErrorMessageEvent
    extends ShortAnswerFormBuilderWidgetEvent {
  final String errorMessage;

  const UpdateValidationErrorMessageEvent(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
