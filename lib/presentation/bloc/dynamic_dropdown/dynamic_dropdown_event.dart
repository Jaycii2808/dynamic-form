import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDropdownEvent extends Equatable {
  const DynamicDropdownEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDropdownEvent extends DynamicDropdownEvent {
  const InitializeDropdownEvent();
}

class DropdownValueChangedEvent extends DynamicDropdownEvent {
  final String value;

  const DropdownValueChangedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class ToggleDropdownEvent extends DynamicDropdownEvent {
  final bool isOpen;

  const ToggleDropdownEvent({required this.isOpen});

  @override
  List<Object?> get props => [isOpen];
}

class OpenDropdownEvent extends DynamicDropdownEvent {
  final Rect position;
  final BuildContext context; // Need context to insert overlay

  const OpenDropdownEvent({required this.position, required this.context});

  @override
  List<Object?> get props => [position, context];
}

class CloseDropdownEvent extends DynamicDropdownEvent {
  const CloseDropdownEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends DynamicDropdownEvent {
  final String query;

  const SearchQueryChangedEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class UpdateDropdownFromExternalEvent extends DynamicDropdownEvent {
  final DynamicFormModel component;

  const UpdateDropdownFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}
