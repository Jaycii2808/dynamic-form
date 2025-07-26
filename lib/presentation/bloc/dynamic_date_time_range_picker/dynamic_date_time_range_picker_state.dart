import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDateTimeRangePickerState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleModel? styleModel;
  final String? formState;
  final String? errorText;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final Map<String, dynamic>? combinedStyle;

  const DynamicDateTimeRangePickerState({
    this.component,
    this.inputConfig,
    this.styleModel,
    this.formState,
    this.errorText,
    this.textController,
    this.focusNode,
    this.combinedStyle,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    styleModel,
    formState,
    errorText,
  ];
}

class DynamicDateTimeRangePickerInitial
    extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerInitial({
    super.component,
    super.combinedStyle,
  });
}

class DynamicDateTimeRangePickerLoading
    extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerLoading({
    super.component,
    super.combinedStyle,
  });

  DynamicDateTimeRangePickerLoading.fromState({
    required DynamicDateTimeRangePickerState state,
  }) : super(
         component: state.component,
         inputConfig: state.inputConfig,
         styleModel: state.styleModel,
         formState: state.formState,
         errorText: state.errorText,
         textController: state.textController,
         focusNode: state.focusNode,
         combinedStyle: state.combinedStyle,
       );
}

class DynamicDateTimeRangePickerSuccess
    extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerSuccess({
    super.component,
    super.inputConfig,
    super.styleModel,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
    super.combinedStyle,
  });
}

class DynamicDateTimeRangePickerError extends DynamicDateTimeRangePickerState {
  final String? errorMessage;

  const DynamicDateTimeRangePickerError({
    required this.errorMessage,
    super.component,
    super.combinedStyle,
  });

  @override
  List<Object?> get props => [errorMessage, component];
}
