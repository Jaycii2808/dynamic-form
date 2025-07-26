import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicSelectState extends Equatable {
  final String? formState;
  final String? errorText;
  final DynamicFormModel? component;

  const DynamicSelectState({
    this.formState,
    this.errorText,
    this.component,
  });

  @override
  List<Object?> get props => [formState, errorText, component];
}

class DynamicSelectInitial extends DynamicSelectState {
  const DynamicSelectInitial();
}

class DynamicSelectLoading extends DynamicSelectState {
  const DynamicSelectLoading({
    super.formState,
    super.errorText,
    super.component,
  });
}

class DynamicSelectSuccess extends DynamicSelectState {
  final StyleModel? styleModel;
  final InputConfig? inputConfig;
  final bool isDropdownOpen;
  final List<dynamic> options;
  final dynamic selectedValue;
  final bool isMultiple;
  final bool isSearchable;
  final bool isDisabled;
  final GlobalKey? selectKey;
  final FocusNode? focusNode;

  // Overlay management
  final Rect? dropdownPosition;
  final OverlayEntry? overlayEntry;

  // Force update on selection (even for same value)
  final int selectionTimestamp;

  const DynamicSelectSuccess({
    super.formState,
    super.errorText,
    super.component,
    this.styleModel,
    this.inputConfig,
    this.isDropdownOpen = false,
    this.options = const [],
    this.selectedValue,
    this.isMultiple = false,
    this.isSearchable = false,
    this.isDisabled = false,
    this.selectKey,
    this.focusNode,
    this.dropdownPosition,
    this.overlayEntry,
    this.selectionTimestamp = 0,
  });

  DynamicSelectSuccess copyWith({
    String? formState,
    String? errorText,
    DynamicFormModel? component,
    StyleModel? styleModel,
    InputConfig? inputConfig,
    bool? isDropdownOpen,
    List<dynamic>? options,
    dynamic selectedValue,
    bool? isMultiple,
    bool? isSearchable,
    bool? isDisabled,
    GlobalKey? selectKey,
    FocusNode? focusNode,
    Rect? dropdownPosition,
    OverlayEntry? overlayEntry,
    int? selectionTimestamp,
  }) {
    return DynamicSelectSuccess(
      formState: formState ?? this.formState,
      errorText: errorText ?? this.errorText,
      component: component ?? this.component,
      styleModel: styleModel ?? this.styleModel,
      inputConfig: inputConfig ?? this.inputConfig,
      isDropdownOpen: isDropdownOpen ?? this.isDropdownOpen,
      options: options ?? this.options,
      selectedValue: selectedValue ?? this.selectedValue,
      isMultiple: isMultiple ?? this.isMultiple,
      isSearchable: isSearchable ?? this.isSearchable,
      isDisabled: isDisabled ?? this.isDisabled,
      selectKey: selectKey ?? this.selectKey,
      focusNode: focusNode ?? this.focusNode,
      dropdownPosition: dropdownPosition ?? this.dropdownPosition,
      overlayEntry: overlayEntry ?? this.overlayEntry,
      selectionTimestamp: selectionTimestamp ?? this.selectionTimestamp,
    );
  }

  @override
  List<Object?> get props => [
    formState,
    errorText,
    component,
    styleModel,
    inputConfig,
    isDropdownOpen,
    options,
    selectedValue,
    isMultiple,
    isSearchable,
    isDisabled,
    selectKey,
    focusNode,
    dropdownPosition,
    overlayEntry,
    selectionTimestamp,
  ];
}

class DynamicSelectError extends DynamicSelectState {
  final String errorMessage;

  const DynamicSelectError({
    required this.errorMessage,
    super.formState,
    super.errorText,
    super.component,
  });

  @override
  List<Object?> get props => [errorMessage, formState, errorText, component];
}
