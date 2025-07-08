import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicTextAreaState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleConfig? styleConfig;
  final FormStateEnum? formState;
  final String? errorText;

  final TextEditingController? textController;
  final FocusNode? focusNode;

  const DynamicTextAreaState({
    this.component,
    this.inputConfig,
    this.styleConfig,
    this.formState,
    this.errorText,
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
  ];
}

class DynamicTextAreaInitial extends DynamicTextAreaState {
  const DynamicTextAreaInitial({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
  });
}

class DynamicTextAreaLoading extends DynamicTextAreaState {
  const DynamicTextAreaLoading({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
  });

  DynamicTextAreaLoading.fromState({required DynamicTextAreaState state})
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

class DynamicTextAreaSuccess extends DynamicTextAreaState {
  const DynamicTextAreaSuccess({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
  });

  DynamicTextAreaSuccess copyWith({
    DynamicFormModel? component,
    InputConfig? inputConfig,
    StyleConfig? styleConfig,
    FormStateEnum? formState,
    String? errorText,
  }) {
    return DynamicTextAreaSuccess(
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

class DynamicTextAreaError extends DynamicTextAreaState {
  final String? errorMessage;

  const DynamicTextAreaError({
    required this.errorMessage,
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
  });
}
