import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDateTimeRangePickerState extends Equatable {
  final DynamicFormModel? component;
  final InputValidationModel? inputConfig;
  final StyleModel? styleModel;
  final StatesEnum? formState;
  final String? errorText;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final Map<String, dynamic>? computedStyle;

  const DynamicDateTimeRangePickerState({
    this.component,
    this.inputConfig,
    this.styleModel,
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
    styleModel,
    formState,
    errorText,
  ];
}

class DynamicDateTimeRangePickerInitial
    extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerInitial({
    super.component,
    super.inputConfig,
    super.styleModel,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
    super.computedStyle,
  });
}

class DynamicDateTimeRangePickerLoading
    extends DynamicDateTimeRangePickerState {
  const DynamicDateTimeRangePickerLoading({
    super.component,
    super.inputConfig,
    super.styleModel,
    super.formState,
    super.errorText,
    super.textController,
    super.focusNode,
    super.computedStyle,
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
         computedStyle: state.computedStyle,
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
    super.computedStyle,
  });
}

class DynamicDateTimeRangePickerError extends DynamicDateTimeRangePickerState {
  final String? errorMessage;

  const DynamicDateTimeRangePickerError({
    required this.errorMessage,
    super.component,
    super.computedStyle,
  });

  @override
  List<Object?> get props => [errorMessage, component, computedStyle];
}
