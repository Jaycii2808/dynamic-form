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
  final String?
  focusOptionId; // transient UI hint: which option should receive focus

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
    this.focusOptionId, // null by default
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
    focusOptionId, // include focus id in equality
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
    super.focusOptionId,
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
    super.focusOptionId,
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
         focusOptionId: state.focusOptionId,
       );
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
    isEditingDescription,
    isDescriptionEnabled,
    focusOptionId,
  ];
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
    super.focusOptionId,
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
         focusOptionId: state.focusOptionId,
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
    String? focusOptionId, // allow overriding
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
      focusOptionId: focusOptionId,
    );
  }

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
    isEditingDescription,
    isDescriptionEnabled,
    focusOptionId,
  ];
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
    super.focusOptionId,
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
    focusOptionId,
    errorMessage,
  ];
}
