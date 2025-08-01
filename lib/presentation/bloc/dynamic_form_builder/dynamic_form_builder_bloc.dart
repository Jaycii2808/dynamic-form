import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormBuilderBloc extends Bloc<FormBuilderEvent, FormBuilderState> {
  final RemoteConfigService _remoteConfigService;

  FormBuilderBloc({
    required RemoteConfigService remoteConfigService,
  }) : _remoteConfigService = remoteConfigService,
       super(const FormBuilderInitial()) {
    on<LoadComponentsEvent>(_onLoadComponents);
    on<LoadButtonComponentsEvent>(_onLoadButtonComponents);
    on<AddComponentEvent>(_onAddComponent);
    on<MoveComponentEvent>(_onMoveComponent);
    on<RemoveComponentEvent>(_onRemoveComponent);
    on<StartDragEvent>(_onStartDrag);
    on<EndDragEvent>(_onEndDrag);
    on<ToggleComponentsPanelEvent>(_onToggleComponentsPanel);
    on<ToggleButtonComponentsPanelEvent>(_onToggleButtonComponentsPanel);
    on<ClearCanvasEvent>(_onClearCanvas);
    on<UpdateComponentValueEvent>(_onUpdateComponentValue);
    on<HandleComponentActionEvent>(_onHandleComponentAction);
  }

  Future<void> _onLoadComponents(
    LoadComponentsEvent event,
    Emitter<FormBuilderState> emit,
  ) async {
    emit(FormBuilderLoading.fromState(state: state));
    try {
      // Get all configs dynamically from enum values
      final components = _remoteConfigService.getAllConfigs();

      if (components.isEmpty) {
        throw Exception('No valid components found in Remote Config');
      }

      emit(
        FormBuilderSuccess.fromState(state: state).copyWith(
          availableComponents: components,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to load components: $e';
      debugPrint('Stack trace: $stackTrace');
      emit(
        FormBuilderError(
          errorMessage: errorMessage,
          components: state.components,
          canvasComponents: state.canvasComponents,
          availableComponents: state.availableComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
        ),
      );
    }
  }

  Future<void> _onLoadButtonComponents(
    LoadButtonComponentsEvent event,
    Emitter<FormBuilderState> emit,
  ) async {
    emit(FormBuilderLoading.fromState(state: state));
    try {
      // Get all button configs dynamically from enum values
      final buttonComponents = _remoteConfigService.getAllButtonConfigs();

      if (buttonComponents.isEmpty) {
        throw Exception('No valid button components found in Remote Config');
      }

      emit(
        FormBuilderSuccess.fromState(state: state).copyWith(
          availableButtonComponents: buttonComponents,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to load button components: $e';
      debugPrint('Stack trace: $stackTrace');
      emit(
        FormBuilderError(
          errorMessage: errorMessage,
          components: state.components,
          canvasComponents: state.canvasComponents,
          availableComponents: state.availableComponents,
          availableButtonComponents: state.availableButtonComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
          showButtonComponentsPanel: state.showButtonComponentsPanel,
        ),
      );
    }
  }

  Future<void> _onAddComponent(
    AddComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) async {
    try {
      // Create a new component with unique ID
      final newComponent = event.component.copyWith(
        id: '${event.component.type}_${DateTime.now().millisecondsSinceEpoch}',
      );

      final updatedCanvasComponents = List<DynamicFormModel>.from(
        state.canvasComponents,
      )..add(newComponent);

      emit(
        FormBuilderSuccess.fromState(state: state).copyWith(
          canvasComponents: updatedCanvasComponents,
        ),
      );

      debugPrint('Component added: ${newComponent.type}');
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to add component: $e';
      debugPrint('Stack trace: $stackTrace');
      emit(
        FormBuilderError(
          errorMessage: errorMessage,
          components: state.components,
          canvasComponents: state.canvasComponents,
          availableComponents: state.availableComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
        ),
      );
    }
  }

  Future<void> _onMoveComponent(
    MoveComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) async {
    try {
      final updatedCanvasComponents = List<DynamicFormModel>.from(
        state.canvasComponents,
      );

      if (event.oldIndex >= 0 &&
          event.oldIndex < updatedCanvasComponents.length &&
          event.newIndex >= 0 &&
          event.newIndex < updatedCanvasComponents.length) {
        final component = updatedCanvasComponents.removeAt(event.oldIndex);
        updatedCanvasComponents.insert(event.newIndex, component);

        emit(
          FormBuilderSuccess.fromState(state: state).copyWith(
            canvasComponents: updatedCanvasComponents,
          ),
        );

        debugPrint(
          'Component moved from index ${event.oldIndex} to ${event.newIndex}',
        );
      }
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to move component: $e';
      debugPrint('Stack trace: $stackTrace');
      emit(
        FormBuilderError(
          errorMessage: errorMessage,
          components: state.components,
          canvasComponents: state.canvasComponents,
          availableComponents: state.availableComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
        ),
      );
    }
  }

  Future<void> _onRemoveComponent(
    RemoveComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) async {
    try {
      final updatedCanvasComponents = List<DynamicFormModel>.from(
        state.canvasComponents,
      );

      if (event.index >= 0 && event.index < updatedCanvasComponents.length) {
        final removedComponent = updatedCanvasComponents.removeAt(event.index);

        emit(
          FormBuilderSuccess.fromState(state: state).copyWith(
            canvasComponents: updatedCanvasComponents,
          ),
        );

        debugPrint('Component removed: ${removedComponent.type}');
      }
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to remove component: $e';
      debugPrint('Stack trace: $stackTrace');
      emit(
        FormBuilderError(
          errorMessage: errorMessage,
          components: state.components,
          canvasComponents: state.canvasComponents,
          availableComponents: state.availableComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
        ),
      );
    }
  }

  void _onStartDrag(
    StartDragEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('Started dragging component: ${event.component.type}');
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        isDragging: true,
      ),
    );
  }

  void _onEndDrag(
    EndDragEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('Ended dragging component: ${event.component.type}');
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        isDragging: false,
      ),
    );
  }

  void _onToggleComponentsPanel(
    ToggleComponentsPanelEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        showComponentsPanel: !state.showComponentsPanel,
      ),
    );
    debugPrint('Components panel toggled: ${!state.showComponentsPanel}');
  }

  void _onToggleButtonComponentsPanel(
    ToggleButtonComponentsPanelEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        showButtonComponentsPanel: !state.showButtonComponentsPanel,
      ),
    );
    debugPrint(
      'Button components panel toggled: ${!state.showButtonComponentsPanel}',
    );
  }

  void _onClearCanvas(
    ClearCanvasEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        canvasComponents: [],
      ),
    );
    debugPrint('Canvas cleared');
  }

  void _onUpdateComponentValue(
    UpdateComponentValueEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      'Component ${event.componentId} value changed to: ${event.value}',
    );
  }

  /// Handle component actions (move up, move down, delete)
  void _onHandleComponentAction(
    HandleComponentActionEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '🔧 [FormBuilderBloc] Handling component action: ${event.action} at index: ${event.index}',
    );

    switch (event.action) {
      case ComponentActionEnum.moveUp:
        if (event.index > 0) {
          add(
            MoveComponentEvent(
              oldIndex: event.index,
              newIndex: event.index - 1,
            ),
          );
        }
        break;
      case ComponentActionEnum.moveDown:
        final currentState = state;
        if (currentState is FormBuilderSuccess &&
            event.index < currentState.canvasComponents.length - 1) {
          add(
            MoveComponentEvent(
              oldIndex: event.index,
              newIndex: event.index + 1,
            ),
          );
        }
        break;
      case ComponentActionEnum.delete:
        add(RemoveComponentEvent(event.index));
        break;
    }
  }
}
