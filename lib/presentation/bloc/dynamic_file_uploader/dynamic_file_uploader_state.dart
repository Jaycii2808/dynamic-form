import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicFileUploaderState extends Equatable {
  final DynamicFormModel? component;
  final ComponentStateEnum? formState;
  final String? errorText;
  final int updateTimestamp;

  const DynamicFileUploaderState({
    this.component,
    this.formState,
    this.errorText,
    int? updateTimestamp,
  }) : updateTimestamp = updateTimestamp ?? 0;

  @override
  List<Object?> get props => [
    component,
    formState,
    errorText,
    updateTimestamp,
  ];
}

class DynamicFileUploaderInitial extends DynamicFileUploaderState {
  const DynamicFileUploaderInitial();
}

class DynamicFileUploaderLoading extends DynamicFileUploaderState {
  const DynamicFileUploaderLoading({
    super.component,
    super.formState,
    super.errorText,
    super.updateTimestamp,
  });
}

class DynamicFileUploaderError extends DynamicFileUploaderState {
  final String errorMessage;

  const DynamicFileUploaderError({
    required this.errorMessage,
    super.component,
    super.formState,
    super.errorText,
    super.updateTimestamp,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    errorMessage,
  ];
}

class DynamicFileUploaderSuccess extends DynamicFileUploaderState {
  // Core state data
  final String currentState;
  final List<String> files;
  final int progress;
  final bool isProcessing;
  final bool isDragging;
  final bool isDisabled;
  final bool isMultipleFiles;
  final List<String> allowedExtensions;

  // UI configuration
  final Map<String, dynamic> computedStyle;
  final Map<String, dynamic> computedConfig;

  // UI elements
  final FocusNode focusNode;

  // Event handlers flags
  final bool canTap;
  final bool canAcceptDrop;
  final bool canBrowse;

  const DynamicFileUploaderSuccess({
    required this.currentState,
    required this.files,
    required this.progress,
    required this.isProcessing,
    required this.isDragging,
    required this.isDisabled,
    required this.isMultipleFiles,
    required this.allowedExtensions,
    required this.computedStyle,
    required this.computedConfig,
    required this.focusNode,
    required this.canTap,
    required this.canAcceptDrop,
    required this.canBrowse,
    super.component,
    super.formState,
    super.errorText,
    super.updateTimestamp,
  });

  DynamicFileUploaderSuccess copyWith({
    String? currentState,
    List<String>? files,
    int? progress,
    bool? isProcessing,
    bool? isDragging,
    bool? isDisabled,
    bool? isMultipleFiles,
    List<String>? allowedExtensions,
    Map<String, dynamic>? computedStyle,
    Map<String, dynamic>? computedConfig,
    FocusNode? focusNode,
    bool? canTap,
    bool? canAcceptDrop,
    bool? canBrowse,
    DynamicFormModel? component,
    ComponentStateEnum? formState,
    String? errorText,
    int? updateTimestamp,
  }) {
    return DynamicFileUploaderSuccess(
      currentState: currentState ?? this.currentState,
      files: files ?? this.files,
      progress: progress ?? this.progress,
      isProcessing: isProcessing ?? this.isProcessing,
      isDragging: isDragging ?? this.isDragging,
      isDisabled: isDisabled ?? this.isDisabled,
      isMultipleFiles: isMultipleFiles ?? this.isMultipleFiles,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      computedStyle: computedStyle ?? this.computedStyle,
      computedConfig: computedConfig ?? this.computedConfig,
      focusNode: focusNode ?? this.focusNode,
      canTap: canTap ?? this.canTap,
      canAcceptDrop: canAcceptDrop ?? this.canAcceptDrop,
      canBrowse: canBrowse ?? this.canBrowse,
      component: component ?? this.component,
      formState: formState ?? this.formState,
      errorText: errorText ?? this.errorText,
      updateTimestamp: updateTimestamp ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    currentState,
    files,
    progress,
    isProcessing,
    isDragging,
    isDisabled,
    isMultipleFiles,
    allowedExtensions,
    computedStyle,
    computedConfig,
    focusNode,
    canTap,
    canAcceptDrop,
    canBrowse,
  ];
}
