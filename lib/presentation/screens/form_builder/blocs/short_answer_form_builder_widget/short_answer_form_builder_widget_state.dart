import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/validation/short_answer_validation_model.dart';

// States
abstract class ShortAnswerFormBuilderWidgetState extends Equatable {
  final DynamicFormModel component;
  final String question;
  final String description;
  final bool isRequired;
  final bool isEditingDescription;
  final bool isDescriptionEnabled;
  final ShortAnswerValidationModel validation;
  final List<String>? availablePages;
  final bool isValidationPanelVisible;

  const ShortAnswerFormBuilderWidgetState({
    required this.component,
    required this.question,
    required this.description,
    required this.isRequired,
    required this.isEditingDescription,
    required this.isDescriptionEnabled,
    required this.validation,
    this.availablePages,
    required this.isValidationPanelVisible,
  });

  @override
  List<Object?> get props => [
    component,
    question,
    description,
    isRequired,
    isEditingDescription,
    isDescriptionEnabled,
    validation,
    availablePages,
    isValidationPanelVisible,
  ];
}

class ShortAnswerFormBuilderWidgetInitial
    extends ShortAnswerFormBuilderWidgetState {
  const ShortAnswerFormBuilderWidgetInitial({
    required super.component,
    required super.question,
    required super.description,
    required super.isRequired,
    required super.isEditingDescription,
    required super.isDescriptionEnabled,
    required super.validation,
    super.availablePages,
    required super.isValidationPanelVisible,
  });
}

class ShortAnswerFormBuilderWidgetLoading
    extends ShortAnswerFormBuilderWidgetState {
  const ShortAnswerFormBuilderWidgetLoading({
    required super.component,
    required super.question,
    required super.description,
    required super.isRequired,
    required super.isEditingDescription,
    required super.isDescriptionEnabled,
    required super.validation,
    super.availablePages,
    required super.isValidationPanelVisible,
  });

  factory ShortAnswerFormBuilderWidgetLoading.fromState({
    required ShortAnswerFormBuilderWidgetState state,
  }) {
    return ShortAnswerFormBuilderWidgetLoading(
      component: state.component,
      question: state.question,
      description: state.description,
      isRequired: state.isRequired,
      isEditingDescription: state.isEditingDescription,
      isDescriptionEnabled: state.isDescriptionEnabled,
      validation: state.validation,
      availablePages: state.availablePages,
      isValidationPanelVisible: state.isValidationPanelVisible,
    );
  }
}

class ShortAnswerFormBuilderWidgetSuccess
    extends ShortAnswerFormBuilderWidgetState {
  const ShortAnswerFormBuilderWidgetSuccess({
    required super.component,
    required super.question,
    required super.description,
    required super.isRequired,
    required super.isEditingDescription,
    required super.isDescriptionEnabled,
    required super.validation,
    super.availablePages,
    required super.isValidationPanelVisible,
  });

  factory ShortAnswerFormBuilderWidgetSuccess.fromState({
    required ShortAnswerFormBuilderWidgetState state,
  }) {
    return ShortAnswerFormBuilderWidgetSuccess(
      component: state.component,
      question: state.question,
      description: state.description,
      isRequired: state.isRequired,
      isEditingDescription: state.isEditingDescription,
      isDescriptionEnabled: state.isDescriptionEnabled,
      validation: state.validation,
      availablePages: state.availablePages,
      isValidationPanelVisible: state.isValidationPanelVisible,
    );
  }

  ShortAnswerFormBuilderWidgetSuccess copyWith({
    DynamicFormModel? component,
    String? question,
    String? description,
    bool? isRequired,
    bool? isEditingDescription,
    bool? isDescriptionEnabled,
    ShortAnswerValidationModel? validation,
    List<String>? availablePages,
    bool? isValidationPanelVisible,
  }) {
    return ShortAnswerFormBuilderWidgetSuccess(
      component: component ?? this.component,
      question: question ?? this.question,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      isEditingDescription: isEditingDescription ?? this.isEditingDescription,
      isDescriptionEnabled: isDescriptionEnabled ?? this.isDescriptionEnabled,
      validation: validation ?? this.validation,
      availablePages: availablePages ?? this.availablePages,
      isValidationPanelVisible:
          isValidationPanelVisible ?? this.isValidationPanelVisible,
    );
  }
}

class ShortAnswerFormBuilderWidgetError
    extends ShortAnswerFormBuilderWidgetState {
  final String errorMessage;

  const ShortAnswerFormBuilderWidgetError({
    required super.component,
    required super.question,
    required super.description,
    required super.isRequired,
    required super.isEditingDescription,
    required super.isDescriptionEnabled,
    required super.validation,
    super.availablePages,
    required this.errorMessage,
    required super.isValidationPanelVisible,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
