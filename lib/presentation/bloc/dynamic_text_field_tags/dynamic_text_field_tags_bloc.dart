import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_state.dart';

class DynamicTextFieldTagsBloc
    extends Bloc<DynamicTextFieldTagsEvent, DynamicTextFieldTagsState> {
  final DynamicFormModel initialComponent;
  final TextEditingController _textController;
  final FocusNode _focusNode;

  DynamicTextFieldTagsBloc({required this.initialComponent})
    : _textController = TextEditingController(),
      _focusNode = FocusNode(),
      super(DynamicTextFieldTagsInitial(component: DynamicFormModel.empty())) {
    _focusNode.addListener(_onFocusChange);

    on<InitializeTextFieldTagsEvent>(_onInitialize);
    on<TagAddedEvent>(_onTagAdded);
    on<TagRemovedEvent>(_onTagRemoved);
    on<TagsFinalizedEvent>(_onTagsFinalized);
    on<StartEditingTagsEvent>(_onStartEditing);
    on<DoneEditingTagsEvent>(_onDoneEditing);

    add(const InitializeTextFieldTagsEvent());
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      add(const TagsFinalizedEvent());
    }
  }

  @override
  Future<void> close() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    return super.close();
  }

  List<String> _getInitialTags(Map<String, dynamic> config) {
    final value = config[ValueKeyEnum.value.key];
    if (value is List) {
      return value.cast<String>();
    }
    final initialTags = config['initial_tags'] ?? config['initialTags'];
    if (initialTags is List) {
      return initialTags.cast<String>();
    }
    return [];
  }

  List<String> _getAvailableTags(Map<String, dynamic> config) {
    final tags = config['initial_tags'] ?? config['initialTags'];
    return (tags is List) ? tags.cast<String>() : [];
  }

  Future<void> _onInitialize(
    InitializeTextFieldTagsEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    emit(DynamicTextFieldTagsLoading.fromState(state: state));
    try {
      final initialTags = _getInitialTags(initialComponent.config);
      final availableTags = _getAvailableTags(initialComponent.config);
      emit(
        DynamicTextFieldTagsSuccess(
          component: initialComponent,
          inputConfig: InputConfig.fromJson(initialComponent.config),
          styleConfig: StyleConfig.fromJson(initialComponent.style),
          formState:
              FormStateEnum.fromString(
                initialComponent.config['currentState'],
              ) ??
              FormStateEnum.base,
          selectedTags: initialTags,
          textController: _textController,
          focusNode: _focusNode,
          isEditing: false,
          availableTags: availableTags,
        ),
      );
    } catch (e) {
      emit(
        DynamicTextFieldTagsError(
          errorMessage: 'Failed to initialize TextFieldTags: $e',
          component: initialComponent,
          isEditing: false,
          availableTags: [],
        ),
      );
    }
  }

  Future<void> _onStartEditing(
    StartEditingTagsEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    try {
      if (state is! DynamicTextFieldTagsSuccess) {
        throw Exception('Invalid state for editing');
      }
      final currentState = state as DynamicTextFieldTagsSuccess;
      emit(
        DynamicTextFieldTagsSuccess(
          component: currentState.component,
          inputConfig: currentState.inputConfig,
          styleConfig: currentState.styleConfig,
          formState: currentState.formState,
          errorText: currentState.errorText,
          selectedTags: currentState.selectedTags,
          textController: currentState.textController,
          focusNode: currentState.focusNode,
          isEditing: true,
          availableTags: currentState.availableTags,
        ),
      );
    } catch (e) {
      emit(
        DynamicTextFieldTagsError(
          errorMessage: 'Failed to start editing: $e',
          component: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).component
              : initialComponent,
          isEditing: false,
          availableTags: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).availableTags
              : [],
        ),
      );
    }
  }

  Future<void> _onDoneEditing(
    DoneEditingTagsEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    try {
      if (state is! DynamicTextFieldTagsSuccess) {
        throw Exception('Invalid state for done editing');
      }
      final currentState = state as DynamicTextFieldTagsSuccess;
      emit(
        DynamicTextFieldTagsSuccess(
          component: currentState.component,
          inputConfig: currentState.inputConfig,
          styleConfig: currentState.styleConfig,
          formState: currentState.formState,
          errorText: currentState.errorText,
          selectedTags: currentState.selectedTags,
          textController: currentState.textController,
          focusNode: currentState.focusNode,
          isEditing: false,
          availableTags: currentState.availableTags,
        ),
      );
    } catch (e) {
      emit(
        DynamicTextFieldTagsError(
          errorMessage: 'Failed to finish editing: $e',
          component: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).component
              : initialComponent,
          isEditing: false,
          availableTags: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).availableTags
              : [],
        ),
      );
    }
  }

  Future<void> _onTagAdded(
    TagAddedEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    try {
      if (state is! DynamicTextFieldTagsSuccess) {
        throw Exception('Invalid state for adding tag');
      }
      final currentState = state as DynamicTextFieldTagsSuccess;

      final currentTags = List<String>.from(currentState.selectedTags);
      if (currentTags.contains(event.tag)) {
        throw Exception('Tag already exists');
      }
      currentTags.add(event.tag);
      _updateState(currentTags, currentState, emit);
    } catch (e) {
      emit(
        DynamicTextFieldTagsError(
          errorMessage: 'Failed to add tag: $e',
          component: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).component
              : initialComponent,
          isEditing: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).isEditing
              : false,
          availableTags: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).availableTags
              : [],
        ),
      );
    }
  }

  Future<void> _onTagRemoved(
    TagRemovedEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    try {
      if (state is! DynamicTextFieldTagsSuccess) {
        throw Exception('Invalid state for removing tag');
      }
      final currentState = state as DynamicTextFieldTagsSuccess;

      final currentTags = List<String>.from(currentState.selectedTags);
      if (!currentTags.contains(event.tag)) {
        throw Exception('Tag does not exist');
      }
      currentTags.remove(event.tag);
      _updateState(currentTags, currentState, emit);
    } catch (e) {
      emit(
        DynamicTextFieldTagsError(
          errorMessage: 'Failed to remove tag: $e',
          component: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).component
              : initialComponent,
          isEditing: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).isEditing
              : false,
          availableTags: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).availableTags
              : [],
        ),
      );
    }
  }

  Future<void> _onTagsFinalized(
    TagsFinalizedEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    try {
      if (state is! DynamicTextFieldTagsSuccess) {
        throw Exception('Invalid state for finalizing tags');
      }
      _updateState(
        (state as DynamicTextFieldTagsSuccess).selectedTags,
        state as DynamicTextFieldTagsSuccess,
        emit,
        isFinalizing: true,
      );
    } catch (e) {
      emit(
        DynamicTextFieldTagsError(
          errorMessage: 'Failed to finalize tags: $e',
          component: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).component
              : initialComponent,
          isEditing: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).isEditing
              : false,
          availableTags: state is DynamicTextFieldTagsSuccess
              ? (state as DynamicTextFieldTagsSuccess).availableTags
              : [],
        ),
      );
    }
  }

  void _updateState(
    List<String> newTags,
    DynamicTextFieldTagsSuccess currentState,
    Emitter<DynamicTextFieldTagsState> emit, {
    bool isFinalizing = false,
  }) {
    final newState = newTags.isNotEmpty
        ? FormStateEnum.success
        : FormStateEnum.base;

    final updatedConfig = Map<String, dynamic>.from(
      currentState.component!.config,
    );
    updatedConfig[ValueKeyEnum.value.key] = newTags;
    updatedConfig[ValueKeyEnum.currentState.key] = newState.value;
    updatedConfig[ValueKeyEnum.errorText.key] = null;

    final updatedComponent = ComponentUtils.updateComponentConfig(
      currentState.component!,
      updatedConfig,
    );
    _textController.clear();
    final availableTags = _getAvailableTags(updatedComponent.config);
    emit(
      DynamicTextFieldTagsSuccess(
        component: updatedComponent,
        inputConfig: InputConfig.fromJson(updatedComponent.config),
        styleConfig: StyleConfig.fromJson(updatedComponent.style),
        formState: newState,
        selectedTags: newTags,
        textController: _textController,
        focusNode: _focusNode,
        isEditing: currentState.isEditing,
        availableTags: availableTags,
      ),
    );
  }
}
