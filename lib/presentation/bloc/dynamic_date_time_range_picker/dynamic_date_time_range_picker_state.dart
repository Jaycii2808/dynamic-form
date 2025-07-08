import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDateTimeRangePickerState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleConfig? styleConfig;
  final FormStateEnum? formState;
  final String? errorText;
  final TextEditingController? textController;
  final FocusNode? focusNode;

  const DynamicDateTimeRangePickerState({
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

class DynamicDateTimeRangePickerInitial extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerInitial({
    super.component,
  });
}

class DynamicDateTimeRangePickerLoading extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerLoading({
    super.component,
  });

  DynamicDateTimeRangePickerLoading.fromState({required DynamicDateTimeRangePickerState state})
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

class DynamicDateTimeRangePickerSuccess extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerSuccess({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
  });
}

class DynamicDateTimeRangePickerError extends DynamicDateTimeRangePickerState {
  final String? errorMessage;

  const DynamicDateTimeRangePickerError({
    required this.errorMessage,
    super.component,
  });

  @override
  List<Object?> get props => [errorMessage, component];
}