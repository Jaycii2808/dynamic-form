import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';

/// Base class for all dynamic button states
abstract class DynamicButtonState extends Equatable {
  const DynamicButtonState();

  @override
  List<Object?> get props => [];
}

/// Initial state when button is first created
class DynamicButtonInitial extends DynamicButtonState {}

/// Loading state during initialization
class DynamicButtonLoading extends DynamicButtonState {}

/// Success state with all computed values
class DynamicButtonSuccess extends DynamicButtonState {
  final DynamicFormModel component;
  final String buttonText;
  final ButtonAction action;
  final bool isVisible;
  final bool isDisabled;
  final IconData? iconData;
  final bool isLoading;

  const DynamicButtonSuccess({
    required this.component,
    required this.buttonText,
    required this.action,
    required this.isVisible,
    required this.isDisabled,
    this.iconData,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    component,
    buttonText,
    action,
    isVisible,
    isDisabled,
    iconData,
    isLoading,
  ];

  DynamicButtonSuccess copyWith({
    DynamicFormModel? component,
    String? buttonText,
    ButtonAction? action,
    bool? isVisible,
    bool? isDisabled,
    IconData? iconData,
    bool? isLoading,
  }) {
    return DynamicButtonSuccess(
      component: component ?? this.component,
      buttonText: buttonText ?? this.buttonText,
      action: action ?? this.action,
      isVisible: isVisible ?? this.isVisible,
      isDisabled: isDisabled ?? this.isDisabled,
      iconData: iconData ?? this.iconData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Error state when something goes wrong
class DynamicButtonError extends DynamicButtonState {
  final String errorMessage;
  final DynamicFormModel? component;

  const DynamicButtonError({
    required this.errorMessage,
    this.component,
  });

  @override
  List<Object?> get props => [errorMessage, component];
}
