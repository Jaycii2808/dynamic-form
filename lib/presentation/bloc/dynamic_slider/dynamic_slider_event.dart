import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicSliderEvent extends Equatable {
  const DynamicSliderEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSliderEvent extends DynamicSliderEvent {
  const InitializeSliderEvent();
}

class SliderValueChangedEvent extends DynamicSliderEvent {
  final dynamic value; // Can be double or RangeValues

  const SliderValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class SliderChangeStartEvent extends DynamicSliderEvent {
  final dynamic value; // Can be double or RangeValues

  const SliderChangeStartEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class SliderChangeEndEvent extends DynamicSliderEvent {
  final dynamic value; // Can be double or RangeValues

  const SliderChangeEndEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class UpdateSliderFromExternalEvent extends DynamicSliderEvent {
  final DynamicFormModel component;

  const UpdateSliderFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}

class ComputeSliderThemeEvent extends DynamicSliderEvent {
  final BuildContext context;

  const ComputeSliderThemeEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
