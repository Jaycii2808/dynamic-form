import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicSelectEvent extends Equatable {
  const DynamicSelectEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSelectEvent extends DynamicSelectEvent {
  const InitializeSelectEvent();
}

class SelectValueChangedEvent extends DynamicSelectEvent {
  final dynamic value;

  const SelectValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class MultipleOptionToggleEvent extends DynamicSelectEvent {
  final String optionValue;
  final bool isSelected;

  const MultipleOptionToggleEvent({
    required this.optionValue,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [optionValue, isSelected];
}

class ToggleDropdownEvent extends DynamicSelectEvent {
  const ToggleDropdownEvent();
}

class OpenDropdownEvent extends DynamicSelectEvent {
  final Rect position;
  final BuildContext context;

  const OpenDropdownEvent({
    required this.position,
    required this.context,
  });

  @override
  List<Object?> get props => [position, context];
}

class CloseDropdownEvent extends DynamicSelectEvent {
  const CloseDropdownEvent();
}

class UpdateSelectFromExternalEvent extends DynamicSelectEvent {
  final DynamicFormModel component;

  const UpdateSelectFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
