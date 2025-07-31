import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_data_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDateTimePickerState extends Equatable {
  final DynamicFormModel? component;
  final InputValidationModel? inputConfig;
  final StyleModel? styleModel;
  final StatesEnum? formState;
  final String? errorText;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final StyleDataModel? computedStyle;

  const DynamicDateTimePickerState({
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
    textController,
    focusNode,
    computedStyle,
  ];
}

class DynamicDateTimePickerInitial extends DynamicDateTimePickerState {
  const DynamicDateTimePickerInitial({
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

class DynamicDateTimePickerLoading extends DynamicDateTimePickerState {
  const DynamicDateTimePickerLoading({
    super.component,
    super.inputConfig,
    super.styleModel,
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
         styleModel: state.styleModel,
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
    super.styleModel,
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
  List<Object?> get props => [errorMessage, component, computedStyle];
}
