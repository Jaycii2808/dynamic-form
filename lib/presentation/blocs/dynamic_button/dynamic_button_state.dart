import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:flutter/material.dart';

sealed class DynamicButtonState extends Equatable {
  final DynamicFormModel? component;
  final ConfigModel config;
  final StyleModel style;
  final String buttonText;
  final ButtonAction action; // use enum
  final bool isVisible;
  final bool isDisabled;
  final bool isLoading;
  final IconData? iconData;

  const DynamicButtonState({
    this.component,
    this.config = const ConfigModel(),
    this.style = const StyleModel(),
    this.buttonText = 'Button',
    this.action = ButtonAction.custom,
    this.isVisible = true,
    this.isDisabled = false,
    this.isLoading = false,
    this.iconData,
  });

  DynamicButtonState copyWith({
    DynamicFormModel? component,
    ConfigModel? config,
    StyleModel? style,
    String? buttonText,
    ButtonAction? action,
    bool? isVisible,
    bool? isDisabled,
    bool? isLoading,
    IconData? iconData,
  }) {
    return _DynamicButtonMutable(
      component: component ?? this.component,
      config: config ?? this.config,
      style: style ?? this.style,
      buttonText: buttonText ?? this.buttonText,
      action: action ?? this.action,
      isVisible: isVisible ?? this.isVisible,
      isDisabled: isDisabled ?? this.isDisabled,
      isLoading: isLoading ?? this.isLoading,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  List<Object?> get props => [
    component,
    config,
    style,
    buttonText,
    action,
    isVisible,
    isDisabled,
    isLoading,
    iconData,
  ];
}

class DynamicButtonInitial extends DynamicButtonState {
  const DynamicButtonInitial({super.component});
}

class DynamicButtonLoading extends DynamicButtonState {
  DynamicButtonLoading.fromState({required DynamicButtonState state})
    : super(
        component: state.component,
        config: state.config,
        style: state.style,
        buttonText: state.buttonText,
        action: state.action,
        isVisible: state.isVisible,
        isDisabled: state.isDisabled,
        isLoading: true,
        iconData: state.iconData,
      );
}

class DynamicButtonSuccess extends DynamicButtonState {
  const DynamicButtonSuccess({
    super.component,
    super.config,
    super.style,
    super.buttonText,
    super.action,
    super.isVisible,
    super.isDisabled,
    super.isLoading,
    super.iconData,
  });
}

class DynamicButtonError extends DynamicButtonState {
  final String? errorMessage;
  const DynamicButtonError({super.component, this.errorMessage}) : super();
  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class _DynamicButtonMutable extends DynamicButtonState {
  const _DynamicButtonMutable({
    super.component,
    super.config,
    super.style,
    super.buttonText,
    super.action,
    super.isVisible,
    super.isDisabled,
    super.isLoading,
    super.iconData,
  });
}
