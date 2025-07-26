import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicTextFieldTagsState extends Equatable {
  final DynamicFormModel? component;
  final InputConfig? inputConfig;
  final StyleModel? styleModel;
  final String? formState;
  final String? errorText;
  final List<String> selectedTags;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final bool isEditing;
  final List<String> availableTags;
  final StatesModel? states;

  const DynamicTextFieldTagsState({
    this.component,
    this.inputConfig,
    this.styleModel,
    this.formState,
    this.errorText,
    this.selectedTags = const [],
    this.textController,
    this.focusNode,
    this.isEditing = false,
    this.availableTags = const [],
    this.states,
  });

  @override
  List<Object?> get props => [
    component,
    inputConfig,
    styleModel,
    formState,
    errorText,
    selectedTags,
    textController,
    focusNode,
    isEditing,
    availableTags,
    states,
  ];
}

class DynamicTextFieldTagsInitial extends DynamicTextFieldTagsState {
  const DynamicTextFieldTagsInitial({
    super.component,
    super.isEditing,
    super.availableTags,
    super.states,
  });
}

class DynamicTextFieldTagsLoading extends DynamicTextFieldTagsState {
  DynamicTextFieldTagsLoading.fromState({
    required DynamicTextFieldTagsState state,
  }) : super(
         component: state.component,
         inputConfig: state.inputConfig,
         styleModel: state.styleModel,
         formState: state.formState,
         errorText: state.errorText,
         selectedTags: state.selectedTags,
         textController: state.textController,
         focusNode: state.focusNode,
         isEditing: state.isEditing,
         availableTags: state.availableTags,
         states: state.states,
       );
}

class DynamicTextFieldTagsSuccess extends DynamicTextFieldTagsState {
  const DynamicTextFieldTagsSuccess({
    super.component,
    super.inputConfig,
    super.styleModel,
    super.formState,
    super.errorText,
    super.selectedTags,
    super.textController,
    super.focusNode,
    super.isEditing,
    super.availableTags,
    super.states,
  });
}

class DynamicTextFieldTagsError extends DynamicTextFieldTagsState {
  final String? errorMessage;

  const DynamicTextFieldTagsError({
    required this.errorMessage,
    super.component,
    super.isEditing,
    super.availableTags,
  });

  @override
  List<Object?> get props => [
    errorMessage,
    component,
    isEditing,
    availableTags,
  ];
}
