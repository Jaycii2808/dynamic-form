import 'dart:async';

import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final value = config['value'];
    debugPrint('DEBUG: _getInitialTags value = $value');
    if (value is List) {
      // Filter out nulls and non-strings, and print debug info if any nulls found
      final filtered = <String>[];
      for (int i = 0; i < value.length; i++) {
        final item = value[i];
        if (item is String) {
          filtered.add(item);
        }
      }
      if (filtered.length != value.length) {
        debugPrint('Warning: value list contains non-strings or nulls: $value');
      }
      return filtered;
    }
    if (value is String && value.isNotEmpty) {
      // If value is a comma-separated string, split it
      debugPrint('DEBUG: _getInitialTags value is a non-empty String: $value');
      final splitValues = value.split(',');
      final trimmedValues = <String>[];

      for (int i = 0; i < splitValues.length; i++) {
        final trimmed = splitValues[i].trim();
        if (trimmed.isNotEmpty) {
          trimmedValues.add(trimmed);
        }
      }

      return trimmedValues;
    }
    final initialTags = config['initial_tags'] ?? config['initialTags'];
    debugPrint(
      'DEBUG: _getInitialTags initialTags = $initialTags',
    );
    if (initialTags is List) {
      final filtered = <String>[];
      for (int i = 0; i < initialTags.length; i++) {
        final item = initialTags[i];
        if (item is String) {
          filtered.add(item);
        }
      }
      if (filtered.length != initialTags.length) {
        debugPrint(
          'Warning: initial_tags contains non-strings or nulls: $initialTags',
        );
      }
      return filtered;
    }
    return [];
  }

  List<String> _getAvailableTags(Map<String, dynamic> config) {
    if (config['initial_tags'] ?? config['initialTags'] case final List tags) {
      final filtered = <String>[];
      for (int i = 0; i < tags.length; i++) {
        final item = tags[i];
        if (item is String) {
          filtered.add(item);
        }
      }
      if (filtered.length != tags.length) {
        debugPrint(
          'Warning: availableTags contains non-strings or nulls: $tags',
        );
      }
      return filtered;
    }
    return [];
  }

  Future<void> _onInitialize(
    InitializeTextFieldTagsEvent event,
    Emitter<DynamicTextFieldTagsState> emit,
  ) async {
    emit(DynamicTextFieldTagsLoading.fromState(state: state));
    try {
      // Get config as Map safely
      final configMap = initialComponent.config?.toJson() ?? {};
      debugPrint(
        'DEBUG: _onInitialize called with config: $configMap',
      );

      final initialTags = _getInitialTags(configMap);
      final availableTags = _getAvailableTags(configMap);
      debugPrint(
        'DEBUG: _onInitialize initialTags: $initialTags, availableTags: $availableTags',
      );

      debugPrint(
        'DEBUG: _onInitialize about to parse InputConfig.fromJson with config: $configMap',
      );

      configMap.forEach((k, v) {
        debugPrint(
          'DEBUG: config key: $k, value: $v',
        );
      });

      InputValidationModel inputConfig;
      try {
        inputConfig = InputValidationModel.fromJson(configMap);
        debugPrint('DEBUG: InputConfig.fromJson succeeded');
      } catch (e, stack) {
        debugPrint('DEBUG: InputConfig.fromJson error: $e');
        debugPrint(stack.toString());
        rethrow;
      }

      debugPrint(
        'DEBUG: About to parse formState: ${configMap['current_state'] ?? configMap['currentState']}',
      );

      final StatesEnum formState =
          configMap['current_state'] ??
          configMap['currentState'] ??
          StatesEnum.base;
      debugPrint('DEBUG: Parsed formState: $formState');

      emit(
        DynamicTextFieldTagsSuccess(
          component: initialComponent,
          inputConfig: inputConfig,
          styleModel: initialComponent.style, // Direct access
          formState: formState,
          selectedTags: initialTags,
          textController: _textController,
          focusNode: _focusNode,
          isEditing: false,
          availableTags: availableTags,
          states: initialComponent.states,
        ),
      );
    } catch (e, stack) {
      debugPrint('DEBUG: _onInitialize error: $e\n$stack');
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
          styleModel: currentState.styleModel,
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
          styleModel: currentState.styleModel,
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
    final newState = newTags.isNotEmpty ? StatesEnum.success : StatesEnum.base;

    final updatedConfig = currentState.component!.config?.toJson() ?? {};
    updatedConfig['value'] = newTags;
    updatedConfig['current_state'] = newState;
    updatedConfig['error_text'] = null;

    final updatedComponent = DynamicFormModel(
      id: currentState.component!.id,
      type: currentState.component!.type,
      config: ConfigModel.fromJson(updatedConfig),
      style: currentState.component!.style,
      variants: currentState.component!.variants,
      states: currentState.component!.states,
      validation: currentState.component!.validation,
      inputTypes: currentState.component!.inputTypes,
      order: currentState.component!.order,
    );

    _textController.clear();
    final availableTags = _getAvailableTags(
      updatedComponent.config?.toJson() ?? {},
    );

    emit(
      DynamicTextFieldTagsSuccess(
        component: updatedComponent,
        inputConfig: InputValidationModel.fromJson(
          updatedComponent.config?.toJson() ?? {},
        ),
        styleModel: updatedComponent.style, // Direct access
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
