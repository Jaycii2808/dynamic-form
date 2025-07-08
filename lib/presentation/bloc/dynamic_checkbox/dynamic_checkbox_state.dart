import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicCheckboxState extends Equatable {
  final FormStateEnum? formState;
  final String? errorText;
  final DynamicFormModel? component;

  const DynamicCheckboxState({
    this.formState,
    this.errorText,
    this.component,
  });

  @override
  List<Object?> get props => [formState, errorText, component];
}

class DynamicCheckboxInitial extends DynamicCheckboxState {
  const DynamicCheckboxInitial();
}

class DynamicCheckboxLoading extends DynamicCheckboxState {
  const DynamicCheckboxLoading({
    super.component,
    super.formState,
    super.errorText,
  });
}

class DynamicCheckboxSuccess extends DynamicCheckboxState {
  final StyleConfig? styleConfig;
  final InputConfig? inputConfig;
  final bool isSelected;
  final bool isEditable;
  final FocusNode? focusNode;

  // Computed style values
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color iconColor;
  final double controlWidth;
  final double controlHeight;
  final double controlBorderRadius;
  final IconData? leadingIconData;

  const DynamicCheckboxSuccess({
    super.component,
    super.formState,
    super.errorText,
    this.styleConfig,
    this.inputConfig,
    required this.isSelected,
    required this.isEditable,
    this.focusNode,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.iconColor,
    required this.controlWidth,
    required this.controlHeight,
    required this.controlBorderRadius,
    this.leadingIconData,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    styleConfig,
    inputConfig,
    isSelected,
    isEditable,
    focusNode,
    backgroundColor,
    borderColor,
    borderWidth,
    iconColor,
    controlWidth,
    controlHeight,
    controlBorderRadius,
    leadingIconData,
  ];

  DynamicCheckboxSuccess copyWith({
    DynamicFormModel? component,
    FormStateEnum? formState,
    String? errorText,
    StyleConfig? styleConfig,
    InputConfig? inputConfig,
    bool? isSelected,
    bool? isEditable,
    FocusNode? focusNode,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    Color? iconColor,
    double? controlWidth,
    double? controlHeight,
    double? controlBorderRadius,
    IconData? leadingIconData,
  }) {
    return DynamicCheckboxSuccess(
      component: component ?? this.component,
      formState: formState ?? this.formState,
      errorText: errorText ?? this.errorText,
      styleConfig: styleConfig ?? this.styleConfig,
      inputConfig: inputConfig ?? this.inputConfig,
      isSelected: isSelected ?? this.isSelected,
      isEditable: isEditable ?? this.isEditable,
      focusNode: focusNode ?? this.focusNode,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      iconColor: iconColor ?? this.iconColor,
      controlWidth: controlWidth ?? this.controlWidth,
      controlHeight: controlHeight ?? this.controlHeight,
      controlBorderRadius: controlBorderRadius ?? this.controlBorderRadius,
      leadingIconData: leadingIconData ?? this.leadingIconData,
    );
  }
}

class DynamicCheckboxError extends DynamicCheckboxState {
  final String errorMessage;

  const DynamicCheckboxError({
    required this.errorMessage,
    super.component,
    super.formState,
    super.errorText,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
