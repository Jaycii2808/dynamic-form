import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicSliderState extends Equatable {
  final FormStateEnum? formState;
  final String? errorText;
  final DynamicFormModel? component;

  const DynamicSliderState({
    this.formState,
    this.errorText,
    this.component,
  });

  @override
  List<Object?> get props => [formState, errorText, component];
}

class DynamicSliderInitial extends DynamicSliderState {
  const DynamicSliderInitial();
}

class DynamicSliderLoading extends DynamicSliderState {
  const DynamicSliderLoading({
    super.formState,
    super.errorText,
    super.component,
  });
}

class DynamicSliderSuccess extends DynamicSliderState {
  final StyleConfig? styleConfig;
  final InputConfig? inputConfig;

  // Slider values
  final double? sliderValue;
  final RangeValues? sliderRangeValues;

  // Slider configuration
  final bool isRange;
  final double min;
  final double max;
  final int? divisions;
  final String prefix;
  final String? hint;
  final String? iconName;
  final String? thumbIconName;
  final bool isDisabled;

  // Computed data
  final Map<String, dynamic> computedStyle;
  final IconData? thumbIcon;
  final SliderThemeData? sliderTheme;

  // Focus management
  final FocusNode? focusNode;

  // Interaction state
  final bool isUserSliding;

  // Force update on value changes
  final int valueTimestamp;

  const DynamicSliderSuccess({
    super.formState,
    super.errorText,
    super.component,
    this.styleConfig,
    this.inputConfig,
    this.sliderValue,
    this.sliderRangeValues,
    this.isRange = false,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.prefix = '',
    this.hint,
    this.iconName,
    this.thumbIconName,
    this.isDisabled = false,
    this.computedStyle = const {},
    this.thumbIcon,
    this.sliderTheme,
    this.focusNode,
    this.isUserSliding = false,
    this.valueTimestamp = 0,
  });

  DynamicSliderSuccess copyWith({
    FormStateEnum? formState,
    String? errorText,
    DynamicFormModel? component,
    StyleConfig? styleConfig,
    InputConfig? inputConfig,
    double? sliderValue,
    RangeValues? sliderRangeValues,
    bool? isRange,
    double? min,
    double? max,
    int? divisions,
    String? prefix,
    String? hint,
    String? iconName,
    String? thumbIconName,
    bool? isDisabled,
    Map<String, dynamic>? computedStyle,
    IconData? thumbIcon,
    SliderThemeData? sliderTheme,
    FocusNode? focusNode,
    bool? isUserSliding,
    int? valueTimestamp,
  }) {
    return DynamicSliderSuccess(
      formState: formState ?? this.formState,
      errorText: errorText ?? this.errorText,
      component: component ?? this.component,
      styleConfig: styleConfig ?? this.styleConfig,
      inputConfig: inputConfig ?? this.inputConfig,
      sliderValue: sliderValue ?? this.sliderValue,
      sliderRangeValues: sliderRangeValues ?? this.sliderRangeValues,
      isRange: isRange ?? this.isRange,
      min: min ?? this.min,
      max: max ?? this.max,
      divisions: divisions ?? this.divisions,
      prefix: prefix ?? this.prefix,
      hint: hint ?? this.hint,
      iconName: iconName ?? this.iconName,
      thumbIconName: thumbIconName ?? this.thumbIconName,
      isDisabled: isDisabled ?? this.isDisabled,
      computedStyle: computedStyle ?? this.computedStyle,
      thumbIcon: thumbIcon ?? this.thumbIcon,
      sliderTheme: sliderTheme ?? this.sliderTheme,
      focusNode: focusNode ?? this.focusNode,
      isUserSliding: isUserSliding ?? this.isUserSliding,
      valueTimestamp: valueTimestamp ?? this.valueTimestamp,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    styleConfig,
    inputConfig,
    sliderValue,
    sliderRangeValues,
    isRange,
    min,
    max,
    divisions,
    prefix,
    hint,
    iconName,
    thumbIconName,
    isDisabled,
    computedStyle,
    thumbIcon,
    sliderTheme,
    focusNode,
    isUserSliding,
    valueTimestamp,
  ];
}

class DynamicSliderError extends DynamicSliderState {
  final String errorMessage;

  const DynamicSliderError({
    required this.errorMessage,
    super.formState,
    super.errorText,
    super.component,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
