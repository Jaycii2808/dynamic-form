import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDateTimePickerState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleConfig? styleConfig;
  final ComponentStateEnum? formState;
  final String? errorText;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final Map<String, dynamic>? computedStyle;

  const DynamicDateTimePickerState({
    this.component,
    this.inputConfig,
    this.styleConfig,
    this.formState,
    this.errorText,
    this.textController,
    this.focusNode,
    this.computedStyle,
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

class DynamicDateTimePickerInitial extends DynamicDateTimePickerState {
  const DynamicDateTimePickerInitial({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
    super.computedStyle,
  });
}

class DynamicDateTimePickerLoading extends DynamicDateTimePickerState {
  const DynamicDateTimePickerLoading({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
    super.computedStyle,
  });

  DynamicDateTimePickerLoading.fromState({
    required DynamicDateTimePickerState state,
  }) : super(
         component: state.component,
         inputConfig: state.inputConfig,
         styleConfig: state.styleConfig,
         formState: state.formState,
         errorText: state.errorText,
         textController: state.textController,
         focusNode: state.focusNode,
         computedStyle: state.computedStyle,
       );
}

class DynamicDateTimePickerSuccess extends DynamicDateTimePickerState {
  const DynamicDateTimePickerSuccess({
    super.component,
    super.inputConfig,
    super.styleConfig,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
    super.computedStyle,
  });
}

class DynamicDateTimePickerError extends DynamicDateTimePickerState {
  final String? errorMessage;

  const DynamicDateTimePickerError({
    required this.errorMessage,
    super.component,
    super.computedStyle,
  });

  @override
  List<Object?> get props => [errorMessage, component];
}
