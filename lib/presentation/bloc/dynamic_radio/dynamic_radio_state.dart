import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicRadioState extends Equatable {
  final DynamicFormModel? component;
  final FormStateEnum? formState;
  final String? errorText;

  const DynamicRadioState({
    this.component,
    this.formState,
    this.errorText,
  });

  @override
  List<Object?> get props => [component, formState, errorText];
}

class DynamicRadioInitial extends DynamicRadioState {
  const DynamicRadioInitial();
}

class DynamicRadioLoading extends DynamicRadioState {
  const DynamicRadioLoading({
    super.component,
    super.formState,
    super.errorText,
  });
}

class DynamicRadioSuccess extends DynamicRadioState {
  final StyleConfig? styleConfig;
  final InputConfig? inputConfig;
  final FocusNode? focusNode;

  const DynamicRadioSuccess({
    super.component,
    super.formState,
    super.errorText,
    this.styleConfig,
    this.inputConfig,
    this.focusNode,
  });

  @override
  List<Object?> get props => [
    component,
    formState,
    errorText,
    styleConfig,
    inputConfig,
    focusNode,
  ];
}

class DynamicRadioError extends DynamicRadioState {
  final String errorMessage;

  const DynamicRadioError({
    required this.errorMessage,
    super.component,
    super.formState,
    super.errorText,
  });

  @override
  List<Object?> get props => [errorMessage, component, formState, errorText];
}
