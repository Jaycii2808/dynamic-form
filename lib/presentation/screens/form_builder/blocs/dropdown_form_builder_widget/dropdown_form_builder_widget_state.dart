import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';

abstract class DropdownFormBuilderWidgetState extends Equatable {
  final String question;
  final String placeholder;
  final List<Option> options;
  final bool isRequired;
  final bool navigationFeatureEnabled;
  final List<String>? availablePages;
  final DynamicFormModel? component;

  const DropdownFormBuilderWidgetState({
    this.question = '',
    this.placeholder = '',
    this.options = const [],
    this.isRequired = false,
    this.navigationFeatureEnabled = false,
    this.availablePages,
    this.component,
  });

  @override
  List<Object?> get props => [
    question,
    placeholder,
    options,
    isRequired,
    navigationFeatureEnabled,
    availablePages,
    component,
  ];
}

class DropdownFormBuilderWidgetInitial extends DropdownFormBuilderWidgetState {
  const DropdownFormBuilderWidgetInitial({
    super.question,
    super.placeholder,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
  });
}

class DropdownFormBuilderWidgetLoading extends DropdownFormBuilderWidgetState {
  const DropdownFormBuilderWidgetLoading({
    super.question,
    super.placeholder,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
  });

  //fromState
  DropdownFormBuilderWidgetLoading.fromState({
    required DropdownFormBuilderWidgetState state,
  }) : super(
         question: state.question,
         placeholder: state.placeholder,
         options: state.options,
         isRequired: state.isRequired,
         navigationFeatureEnabled: state.navigationFeatureEnabled,
         availablePages: state.availablePages,
         component: state.component,
       );
}

class DropdownFormBuilderWidgetSuccess extends DropdownFormBuilderWidgetState {
  const DropdownFormBuilderWidgetSuccess({
    super.question,
    super.placeholder,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
  });

  //fromState
  DropdownFormBuilderWidgetSuccess.fromState({
    required DropdownFormBuilderWidgetState state,
  }) : super(
         question: state.question,
         placeholder: state.placeholder,
         options: state.options,
         isRequired: state.isRequired,
         navigationFeatureEnabled: state.navigationFeatureEnabled,
         availablePages: state.availablePages,
         component: state.component,
       );

  DropdownFormBuilderWidgetSuccess copyWith({
    String? question,
    String? placeholder,
    List<Option>? options,
    bool? isRequired,
    bool? navigationFeatureEnabled,
    List<String>? availablePages,
    DynamicFormModel? component,
  }) {
    return DropdownFormBuilderWidgetSuccess(
      question: question ?? this.question,
      placeholder: placeholder ?? this.placeholder,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      navigationFeatureEnabled:
          navigationFeatureEnabled ?? this.navigationFeatureEnabled,
      availablePages: availablePages ?? this.availablePages,
      component: component ?? this.component,
    );
  }
}

class DropdownFormBuilderWidgetError extends DropdownFormBuilderWidgetState {
  final String? errorMessage;

  const DropdownFormBuilderWidgetError({
    super.question,
    super.placeholder,
    super.options,
    super.isRequired,
    super.navigationFeatureEnabled,
    super.availablePages,
    super.component,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
    question,
    placeholder,
    options,
    isRequired,
    navigationFeatureEnabled,
    availablePages,
    component,
    errorMessage,
  ];
}
