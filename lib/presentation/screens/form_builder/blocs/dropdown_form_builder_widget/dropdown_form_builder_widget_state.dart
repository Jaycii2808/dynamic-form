import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';

abstract class DropdownFormBuilderWidgetState extends Equatable {
  final String question;
  final String placeholder;
  final String description;
  final List<Option> options;
  final bool isRequired;
  final bool navigationFeatureEnabled;
  final List<String>? availablePages;
  final DynamicFormModel? component;
  final bool isEditingDescription; // Add editing state
  final bool isDescriptionEnabled; // Add enabled state

  const DropdownFormBuilderWidgetState({
    this.question = '',
    this.placeholder = '',
    this.description = '',
    this.options = const [],
    this.isRequired = false,
    this.navigationFeatureEnabled = false,
    this.availablePages,
    this.component,
    this.isEditingDescription = false, // Add editing state
    this.isDescriptionEnabled = false, // Add enabled state - default to false
  });

  @override
  List<Object?> get props => [
    question,
    placeholder,
    description,
    options,
    isRequired,
    navigationFeatureEnabled,
    availablePages,
    component,
    isEditingDescription, // Add to props
    isDescriptionEnabled, // Add to props
  ];
}

class DropdownFormBuilderWidgetInitial extends DropdownFormBuilderWidgetState {
  const DropdownFormBuilderWidgetInitial({
    super.question,
    super.placeholder,
    super.description,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
    super.isEditingDescription, // Add parameter
    super.isDescriptionEnabled, // Add parameter
  });
}

class DropdownFormBuilderWidgetLoading extends DropdownFormBuilderWidgetState {
  const DropdownFormBuilderWidgetLoading({
    super.question,
    super.placeholder,
    super.description,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
    super.isEditingDescription, // Add parameter
    super.isDescriptionEnabled, // Add parameter
  });

  //fromState
  DropdownFormBuilderWidgetLoading.fromState({
    required DropdownFormBuilderWidgetState state,
  }) : super(
         question: state.question,
         placeholder: state.placeholder,
         description: state.description,
         options: state.options,
         isRequired: state.isRequired,
         navigationFeatureEnabled: state.navigationFeatureEnabled,
         availablePages: state.availablePages,
         component: state.component,
         isEditingDescription: state.isEditingDescription, // Add from state
         isDescriptionEnabled: state.isDescriptionEnabled, // Add from state
       );
}

class DropdownFormBuilderWidgetSuccess extends DropdownFormBuilderWidgetState {
  const DropdownFormBuilderWidgetSuccess({
    super.question,
    super.placeholder,
    super.description,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
    super.isEditingDescription, // Add parameter
    super.isDescriptionEnabled, // Add parameter
  });

  //fromState
  DropdownFormBuilderWidgetSuccess.fromState({
    required DropdownFormBuilderWidgetState state,
  }) : super(
         question: state.question,
         placeholder: state.placeholder,
         description: state.description,
         options: state.options,
         isRequired: state.isRequired,
         navigationFeatureEnabled: state.navigationFeatureEnabled,
         availablePages: state.availablePages,
         component: state.component,
         isEditingDescription: state.isEditingDescription, // Add from state
         isDescriptionEnabled: state.isDescriptionEnabled, // Add from state
       );

  DropdownFormBuilderWidgetSuccess copyWith({
    String? question,
    String? placeholder,
    String? description,
    List<Option>? options,
    bool? isRequired,
    bool? navigationFeatureEnabled,
    List<String>? availablePages,
    DynamicFormModel? component,
    bool? isEditingDescription, // Add parameter
    bool? isDescriptionEnabled, // Add parameter
  }) {
    return DropdownFormBuilderWidgetSuccess(
      question: question ?? this.question,
      placeholder: placeholder ?? this.placeholder,
      description: description ?? this.description,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      navigationFeatureEnabled:
          navigationFeatureEnabled ?? this.navigationFeatureEnabled,
      availablePages: availablePages ?? this.availablePages,
      component: component ?? this.component,
      isEditingDescription:
          isEditingDescription ?? this.isEditingDescription, // Add to copyWith
      isDescriptionEnabled:
          isDescriptionEnabled ?? this.isDescriptionEnabled, // Add to copyWith
    );
  }
}

class DropdownFormBuilderWidgetError extends DropdownFormBuilderWidgetState {
  final String? errorMessage;

  const DropdownFormBuilderWidgetError({
    super.question,
    super.placeholder,
    super.description,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
    super.isEditingDescription, // Add parameter
    super.isDescriptionEnabled, // Add parameter
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
    question,
    placeholder,
    description,
    options,
    isRequired,
    navigationFeatureEnabled,
    availablePages,
    component,
    isEditingDescription, // Add to props
    isDescriptionEnabled, // Add to props
    errorMessage,
  ];
}
