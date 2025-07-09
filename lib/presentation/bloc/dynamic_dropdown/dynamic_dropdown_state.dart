import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDropdownState extends Equatable {
  final DynamicFormModel? component;
  final StyleConfig? styleConfig;
  final InputConfig? inputConfig;
  final FormStateEnum? formState;
  final String? errorText;

  const DynamicDropdownState({
    this.component,
    this.styleConfig,
    this.inputConfig,
    this.formState,
    this.errorText,
  });

  @override
  List<Object?> get props => [
    component,
    styleConfig,
    inputConfig,
    formState,
    errorText,
  ];
}

class DynamicDropdownInitial extends DynamicDropdownState {
  const DynamicDropdownInitial();
}

class DynamicDropdownLoading extends DynamicDropdownState {
  const DynamicDropdownLoading({
    super.component,
    super.formState,
    super.errorText,
  });
}

class DynamicDropdownSuccess extends DynamicDropdownState {
  // Focus nodes
  final FocusNode? focusNode;
  final FocusNode? searchFocusNode;

  // Current values
  final String? currentValue;
  final String currentState;
  final bool isDisabled;
  final bool isSearchable;
  final String placeholder;
  final String? triggerIcon;
  final String? triggerAvatar;

  // Computed values
  final Map<String, dynamic> computedStyle;
  final String? displayLabel;
  final Widget? triggerContent;

  // Items and search
  final List<dynamic> items;
  final List<dynamic> filteredItems;
  final String searchQuery;

  // Dropdown state
  final bool isDropdownOpen;
  final Rect? dropdownPosition;
  final OverlayEntry? overlayEntry;
  final TextEditingController? searchController;

  // Force update on selection (even for same value)
  final int selectionTimestamp;

  const DynamicDropdownSuccess({
    super.component,
    super.styleConfig,
    super.inputConfig,
    super.formState,
    super.errorText,
    this.focusNode,
    this.searchFocusNode,
    this.currentValue,
    this.currentState = 'base',
    this.isDisabled = false,
    this.isSearchable = false,
    this.placeholder = 'Select an option',
    this.triggerIcon,
    this.triggerAvatar,
    this.computedStyle = const {},
    this.displayLabel,
    this.triggerContent,
    this.items = const [],
    this.filteredItems = const [],
    this.searchQuery = '',
    this.isDropdownOpen = false,
    this.dropdownPosition,
    this.overlayEntry,
    this.searchController,
    this.selectionTimestamp = 0,
  });

  DynamicDropdownSuccess copyWith({
    DynamicFormModel? component,
    StyleConfig? styleConfig,
    InputConfig? inputConfig,
    FormStateEnum? formState,
    String? errorText,
    FocusNode? focusNode,
    FocusNode? searchFocusNode,
    String? currentValue,
    String? currentState,
    bool? isDisabled,
    bool? isSearchable,
    String? placeholder,
    String? triggerIcon,
    String? triggerAvatar,
    Map<String, dynamic>? computedStyle,
    String? displayLabel,
    Widget? triggerContent,
    List<dynamic>? items,
    List<dynamic>? filteredItems,
    String? searchQuery,
    bool? isDropdownOpen,
    Rect? dropdownPosition,
    OverlayEntry? overlayEntry,
    TextEditingController? searchController,
    int? selectionTimestamp,
  }) {
    return DynamicDropdownSuccess(
      component: component ?? this.component,
      styleConfig: styleConfig ?? this.styleConfig,
      inputConfig: inputConfig ?? this.inputConfig,
      formState: formState ?? this.formState,
      errorText: errorText ?? this.errorText,
      focusNode: focusNode ?? this.focusNode,
      searchFocusNode: searchFocusNode ?? this.searchFocusNode,
      currentValue: currentValue ?? this.currentValue,
      currentState: currentState ?? this.currentState,
      isDisabled: isDisabled ?? this.isDisabled,
      isSearchable: isSearchable ?? this.isSearchable,
      placeholder: placeholder ?? this.placeholder,
      triggerIcon: triggerIcon ?? this.triggerIcon,
      triggerAvatar: triggerAvatar ?? this.triggerAvatar,
      computedStyle: computedStyle ?? this.computedStyle,
      displayLabel: displayLabel ?? this.displayLabel,
      triggerContent: triggerContent ?? this.triggerContent,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      isDropdownOpen: isDropdownOpen ?? this.isDropdownOpen,
      dropdownPosition: dropdownPosition ?? this.dropdownPosition,
      overlayEntry: overlayEntry ?? this.overlayEntry,
      searchController: searchController ?? this.searchController,
      selectionTimestamp: selectionTimestamp ?? this.selectionTimestamp,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    focusNode,
    searchFocusNode,
    currentValue,
    currentState,
    isDisabled,
    isSearchable,
    placeholder,
    triggerIcon,
    triggerAvatar,
    computedStyle,
    displayLabel,
    triggerContent,
    items,
    filteredItems,
    searchQuery,
    isDropdownOpen,
    dropdownPosition,
    overlayEntry,
    searchController,
    selectionTimestamp,
  ];
}

class DynamicDropdownError extends DynamicDropdownState {
  final String errorMessage;

  const DynamicDropdownError({
    required this.errorMessage,
    super.component,
    super.formState,
    super.errorText,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
