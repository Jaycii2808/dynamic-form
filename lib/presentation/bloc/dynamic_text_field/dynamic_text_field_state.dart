import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicTextFieldState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleConfig? styleConfig;
  final FormStateEnum? formState;
  final String? errorText;
  final String? errorMessage;

  final TextEditingController? textController;
  final FocusNode? focusNode;

  const DynamicTextFieldState({
    this.component,
    this.inputConfig,
    this.styleConfig,
    this.formState,
    this.errorText,
    this.errorMessage,
    this.textController,
    this.focusNode,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    styleConfig,
    formState,
    errorText,
    errorMessage,
  ];
}

class DynamicTextFieldInitial extends DynamicTextFieldState {
  const DynamicTextFieldInitial({required DynamicFormModel component})
    : super(component: component);
}

class DynamicTextFieldLoading extends DynamicTextFieldState {
  const DynamicTextFieldLoading({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
  });

  DynamicTextFieldLoading.fromState({required DynamicTextFieldState state})
    : super(
        component: state.component,
        inputConfig: state.inputConfig,
        styleConfig: state.styleConfig,
        formState: state.formState,
        errorText: state.errorText,
        textController: state.textController,
        focusNode: state.focusNode,
      );
}

class DynamicTextFieldSuccess extends DynamicTextFieldState {
  const DynamicTextFieldSuccess({
    required DynamicFormModel super.component,
    required InputConfig super.inputConfig,
    required StyleConfig super.styleConfig,
    required FormStateEnum super.formState,
    required TextEditingController super.textController,
    required FocusNode super.focusNode,
    super.errorText,
  });

  DynamicTextFieldSuccess copyWith({
    DynamicFormModel? component,
    InputConfig? inputConfig,
    StyleConfig? styleConfig,
    FormStateEnum? formState,
    String? errorText,
  }) {
    return DynamicTextFieldSuccess(
      component: component ?? this.component!,
      inputConfig: inputConfig ?? this.inputConfig!,
      styleConfig: styleConfig ?? this.styleConfig!,
      formState: formState ?? this.formState!,
      errorText: errorText ?? this.errorText,
      textController: textController!,
      focusNode: focusNode!,
    );
  }
}

class DynamicTextFieldError extends DynamicTextFieldState {
  const DynamicTextFieldError({
    required String super.errorMessage,
    super.component,
  });
}
