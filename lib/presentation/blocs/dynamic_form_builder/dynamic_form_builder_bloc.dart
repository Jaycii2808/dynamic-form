import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormBuilderBloc extends Bloc<FormBuilderEvent, FormBuilderState> {
  final RemoteConfigService _remoteConfigService;

  FormBuilderBloc({
    required RemoteConfigService remoteConfigService,
  }) : _remoteConfigService = remoteConfigService,
       super(
         const FormBuilderInitial(
           pages: [
             FormBuilderPageModel(
               pageId: 'page_1',
               title: 'Form Page',
               order: 1,
               showPreviousButton: false,
               showNextButton: false,
               showSubmitButton: true,
               components: [],
             ),
           ],
           currentPageId: 'page_1',
           formTitle: 'Untitled Form',
         ),
       ) {
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
    on<UpdateFormTitleEvent>(_onUpdateFormTitle);
    on<UpdatePageTitleEvent>(_onUpdatePageTitle);
    on<SwitchPageEvent>(_onSwitchPage);
    on<AddPageEvent>(_onAddPage);
    on<RemovePageEvent>(_onRemovePage);
    on<CopyPageEvent>(_onCopyPage);
    on<SubmitFormEvent>(_onSubmitForm);
    on<AddPageWithTitleEvent>(_onAddPageWithTitle);
    on<UpdateFirstPageTitleEvent>(_onUpdateFirstPageTitle);
    // New event handlers for insert logic
    on<InsertComponentEvent>(_onInsertComponent);
    on<StartHoverEvent>(_onStartHover);
    on<EndHoverEvent>(_onEndHover);
    on<ShowInsertIndicatorEvent>(_onShowInsertIndicator);
    on<HideInsertIndicatorEvent>(_onHideInsertIndicator);
    // New event handlers for editing component config
    on<EditComponentConfigEvent>(_onEditComponentConfig);
    on<EditComponentLabelEvent>(_onEditComponentLabel);
    on<EditComponentPlaceholderEvent>(_onEditComponentPlaceholder);
    // Force rebuild UI event
    on<ForceRebuildUIEvent>(_onForceRebuildUI);
    // Load existing form event
    on<LoadExistingFormEvent>(_onLoadExistingForm);
    // Force save all components event
    on<ForceSaveAllComponentsEvent>(_onForceSaveAllComponents);
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
          pages: state.pages,
          currentPageId: state.currentPageId,
          availableComponents: state.availableComponents,
          availableButtonComponents: state.availableButtonComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
          showButtonComponentsPanel: state.showButtonComponentsPanel,
          formTitle: state.formTitle,
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
          pages: state.pages,
          currentPageId: state.currentPageId,
          availableComponents: state.availableComponents,
          availableButtonComponents: state.availableButtonComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
          showButtonComponentsPanel: state.showButtonComponentsPanel,
          formTitle: state.formTitle,
        ),
      );
    }
  }

  void _onAddComponent(
    AddComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '➕ [FormBuilderBloc] Adding component: ${event.component.type} to page: ${state.currentPageId}',
    );

    // Add component to the current page
    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = List<DynamicFormModel>.from(page.components)
          ..add(event.component);
        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        // Remove rebuildTimestamp to prevent infinite rebuilds
      ),
    );

    debugPrint(
      '✅ [FormBuilderBloc] Component added to page ${state.currentPageId}. Total components: ${updatedPages.firstWhere((p) => p.pageId == state.currentPageId).components.length}',
    );
  }

  void _onMoveComponent(
    MoveComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '🔄 [FormBuilderBloc] Moving component from index ${event.oldIndex} to ${event.newIndex} on page: ${state.currentPageId}',
    );

    // Move component within the current page
    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = List<DynamicFormModel>.from(page.components);
        if (event.oldIndex >= 0 &&
            event.oldIndex < updatedComponents.length &&
            event.newIndex >= 0 &&
            event.newIndex < updatedComponents.length) {
          final component = updatedComponents.removeAt(event.oldIndex);
          updatedComponents.insert(event.newIndex, component);
        }
        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
      ),
    );

    debugPrint(
      '✅ [FormBuilderBloc] Component moved on page ${state.currentPageId}',
    );
  }

  void _onRemoveComponent(
    RemoveComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '➖ [FormBuilderBloc] Removing component at index: ${event.index} from page: ${state.currentPageId}',
    );

    // Remove component from the current page
    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = List<DynamicFormModel>.from(page.components);
        if (event.index >= 0 && event.index < updatedComponents.length) {
          updatedComponents.removeAt(event.index);
        }
        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
      ),
    );

    debugPrint(
      '✅ [FormBuilderBloc] Component removed from page ${state.currentPageId}. Remaining components: ${updatedPages.firstWhere((p) => p.pageId == state.currentPageId).components.length}',
    );
  }

  void _onStartDrag(
    StartDragEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('Started dragging component: ${event.component.type}');
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        isDragging: true,
        showComponentsPanel: false, // Hide components panel during drag
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
    // Clear only the current page components
    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        return page.copyWith(components: []);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
      ),
    );
    debugPrint('Canvas cleared for page ${state.currentPageId}');
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
      case ComponentActionEnum.editConfig:
        // This is handled in the UI layer, not here
        break;
    }
  }

  /// Update form title
  void _onUpdateFormTitle(
    UpdateFormTitleEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('📝 [FormBuilderBloc] Updating form title to: ${event.title}');
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        formTitle: event.title,
      ),
    );
  }

  /// Update page title
  void _onUpdatePageTitle(
    UpdatePageTitleEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '📝 [FormBuilderBloc] Updating page title for pageId: ${event.pageId} to: ${event.title}',
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == event.pageId) {
        return page.copyWith(title: event.title);
      }
      return page;
    }).toList();

    final availablePages = updatedPages.map((page) => page.title).toList();
    debugPrint(
      '🔄 [FormBuilderBloc] Available pages after updating page title: $availablePages',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        rebuildTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Force rebuild
      ),
    );
  }

  /// Switch to a different page
  void _onSwitchPage(
    SwitchPageEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('🔄 [FormBuilderBloc] Switching to page: ${event.pageId}');
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        currentPageId: event.pageId,
      ),
    );
  }

  /// Add a new page
  void _onAddPage(
    AddPageEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('➕ [FormBuilderBloc] Adding new page');

    final newPageId = 'page_${DateTime.now().millisecondsSinceEpoch}';
    final newPage = FormBuilderPageModel(
      pageId: newPageId,
      title: 'New Page',
      order: state.pages.length + 1,
      showPreviousButton: true,
      showNextButton: true,
      showSubmitButton: false,
      components: const [],
    );

    final updatedPages = List<FormBuilderPageModel>.from(state.pages)
      ..add(newPage);

    final availablePages = updatedPages.map((page) => page.title).toList();
    debugPrint(
      '🔄 [FormBuilderBloc] Available pages after adding new page: $availablePages',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        currentPageId: newPageId,
        rebuildTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Force rebuild
      ),
    );
  }

  /// Add a new page with a specific title
  void _onAddPageWithTitle(
    AddPageWithTitleEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '➕ [FormBuilderBloc] Adding new page with title: ${event.title}',
    );

    final newPageId = 'page_${DateTime.now().millisecondsSinceEpoch}';
    final newPage = FormBuilderPageModel(
      pageId: newPageId,
      title: event.title,
      order: state.pages.length + 1,
      showPreviousButton: true,
      showNextButton: true,
      showSubmitButton: false,
      components: const [],
    );

    final updatedPages = List<FormBuilderPageModel>.from(state.pages)
      ..add(newPage);

    final availablePages = updatedPages.map((page) => page.title).toList();
    debugPrint(
      '🔄 [FormBuilderBloc] Available pages after adding new page: $availablePages',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        currentPageId: newPageId,
        rebuildTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Force rebuild
      ),
    );
  }

  /// Remove a page
  void _onRemovePage(
    RemovePageEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('➖ [FormBuilderBloc] Removing page: ${event.pageId}');

    final updatedPages = state.pages
        .where((page) => page.pageId != event.pageId)
        .toList();

    // If we're removing the current page, switch to the first available page
    String newCurrentPageId = state.currentPageId;
    if (event.pageId == state.currentPageId && updatedPages.isNotEmpty) {
      newCurrentPageId = updatedPages.first.pageId;
    } else if (updatedPages.isEmpty) {
      // If no pages left, create a default page
      final defaultPage = const FormBuilderPageModel(
        pageId: 'page_1',
        title: 'Form Page',
        order: 1,
        showPreviousButton: false,
        showNextButton: false,
        showSubmitButton: true,
        components: [],
      );
      updatedPages.add(defaultPage);
      newCurrentPageId = 'page_1';
    }

    final availablePages = updatedPages.map((page) => page.title).toList();
    debugPrint(
      '🔄 [FormBuilderBloc] Available pages after removing page: $availablePages',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        currentPageId: newCurrentPageId,
        rebuildTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Force rebuild
      ),
    );
  }

  /// Copy a page
  void _onCopyPage(
    CopyPageEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('📋 [FormBuilderBloc] Copying page: ${event.pageId}');

    final pageToCopy = state.pages.firstWhere(
      (page) => page.pageId == event.pageId,
    );

    // Deep copy components with new IDs
    final copiedComponents = pageToCopy.components.map((component) {
      final newComponentId =
          '${component.id}_${DateTime.now().millisecondsSinceEpoch}';
      return component.copyWith(id: newComponentId);
    }).toList();

    final newPageId = 'page_${DateTime.now().millisecondsSinceEpoch}';
    final newPage = pageToCopy.copyWith(
      pageId: newPageId,
      title: '${pageToCopy.title} Copy',
      order: state.pages.length + 1,
      components: copiedComponents,
    );

    final updatedPages = List<FormBuilderPageModel>.from(state.pages)
      ..add(newPage);

    final availablePages = updatedPages.map((page) => page.title).toList();
    debugPrint(
      '🔄 [FormBuilderBloc] Available pages after copying page: $availablePages',
    );
    debugPrint(
      '📋 [FormBuilderBloc] Copied ${copiedComponents.length} components to new page',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        currentPageId: newPageId,
        rebuildTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Force rebuild
      ),
    );
  }

  /// Submit form and navigate to preview
  void _onSubmitForm(
    SubmitFormEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('🚀 [FormBuilderBloc] Submitting form for preview');
    // The navigation will be handled in the UI layer
    // This method can be used for any additional logic before navigation
  }

  /// Update the title of the first page
  void _onUpdateFirstPageTitle(
    UpdateFirstPageTitleEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '📝 [FormBuilderBloc] Updating first page title to: ${event.title}',
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == 'page_1') {
        return page.copyWith(title: event.title);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
      ),
    );
  }

  /// Insert component at specific index
  void _onInsertComponent(
    InsertComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '📎 [FormBuilderBloc] Inserting component at index: ${event.insertIndex}',
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = List<DynamicFormModel>.from(page.components);
        updatedComponents.insert(event.insertIndex, event.component);
        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        insertIndicatorIndex: null,
        isHovering: false,
        hoveredComponent: null,
        hoverTargetIndex: null,
      ),
    );
  }

  /// Start hover timer for insert logic
  void _onStartHover(
    StartHoverEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '🔄 [FormBuilderBloc] Starting hover for index: ${event.targetIndex}',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        isHovering: true,
        hoveredComponent: event.draggedComponent,
        hoverTargetIndex: event.targetIndex,
      ),
    );

    // Start timer to show insert indicator after 0.5 seconds
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.isHovering && state.hoverTargetIndex == event.targetIndex) {
        add(ShowInsertIndicatorEvent(event.targetIndex));
      }
    });
  }

  /// End hover state
  void _onEndHover(
    EndHoverEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('🛑 [FormBuilderBloc] Ending hover');

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        isHovering: false,
        hoveredComponent: null,
        hoverTargetIndex: null,
      ),
    );
  }

  /// Show insert indicator
  void _onShowInsertIndicator(
    ShowInsertIndicatorEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '📍 [FormBuilderBloc] Showing insert indicator at index: ${event.insertIndex}',
    );

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        insertIndicatorIndex: event.insertIndex,
      ),
    );
  }

  /// Hide insert indicator
  void _onHideInsertIndicator(
    HideInsertIndicatorEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('🚫 [FormBuilderBloc] Hiding insert indicator');

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        insertIndicatorIndex: null,
      ),
    );
  }

  /// Edit component configuration
  void _onEditComponentConfig(
    EditComponentConfigEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '⚙️ [FormBuilderBloc] Editing component config: ${event.componentId}',
    );
    debugPrint(
      '⚙️ [FormBuilderBloc] Description: ${event.description}',
    );
    debugPrint(
      '⚙️ [FormBuilderBloc] Options: ${event.options?.map((o) => '${o.label}(${o.action}->${o.targetSection})').toList()}',
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = page.components.map((component) {
          if (component.id == event.componentId) {
            debugPrint(
              '⚙️ [FormBuilderBloc] Component before update - description: ${component.config?.description}',
            );
            debugPrint(
              '⚙️ [FormBuilderBloc] Component before update - options: ${component.config?.options?.map((o) => '${o.label}(${o.action}->${o.targetSection})').toList()}',
            );

            final updatedConfig =
                component.config?.copyWith(
                  label: event.label,
                  placeholder: event.placeholder,
                  description: event.description, // Add description
                  value: event.value,
                  isRequired: event.isRequired,
                  errorText: event.errorText,
                  options: event.options, // Add options support
                  validate: event.validate ?? component.config?.validate,
                ) ??
                ConfigModel(
                  label: event.label,
                  placeholder: event.placeholder,
                  description: event.description, // Add description
                  value: event.value,
                  isRequired: event.isRequired,
                  errorText: event.errorText,
                  options: event.options, // Add options support
                  validate: event.validate,
                );

            debugPrint(
              '⚙️ [FormBuilderBloc] Component after update - description: ${updatedConfig.description}',
            );
            debugPrint(
              '⚙️ [FormBuilderBloc] Component after update - options: ${updatedConfig.options?.map((o) => '${o.label}(${o.action}->${o.targetSection})').toList()}',
            );

            return component.copyWith(
              config: updatedConfig,
              validation: event.validation ?? component.validation,
            );
          }
          return component;
        }).toList();

        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
        rebuildTimestamp:
            DateTime.now().millisecondsSinceEpoch, // Force rebuild
      ),
    );
  }

  /// Edit component label
  void _onEditComponentLabel(
    EditComponentLabelEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '🏷️ [FormBuilderBloc] Editing component label: ${event.componentId}',
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = page.components.map((component) {
          if (component.id == event.componentId) {
            final updatedConfig =
                component.config?.copyWith(
                  label: event.label,
                ) ??
                ConfigModel(label: event.label);

            return component.copyWith(
              config: updatedConfig,
              labelFormBuilder: event.label,
            );
          }
          return component;
        }).toList();

        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
      ),
    );

    // Force rebuild UI after updating component
    add(const ForceRebuildUIEvent());
  }

  /// Edit component placeholder
  void _onEditComponentPlaceholder(
    EditComponentPlaceholderEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '📝 [FormBuilderBloc] Editing component placeholder: ${event.componentId}',
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = page.components.map((component) {
          if (component.id == event.componentId) {
            final updatedConfig =
                component.config?.copyWith(
                  placeholder: event.placeholder,
                ) ??
                ConfigModel(placeholder: event.placeholder);

            return component.copyWith(config: updatedConfig);
          }
          return component;
        }).toList();

        return page.copyWith(components: updatedComponents);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: updatedPages,
      ),
    );

    // Force rebuild UI after updating component
    add(const ForceRebuildUIEvent());
  }

  /// Force rebuild UI
  void _onForceRebuildUI(
    ForceRebuildUIEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('🔄 [FormBuilderBloc] Forcing UI rebuild');

    // Force rebuild by emitting a new state with a timestamp
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        // Add a rebuild timestamp to force UI update
        rebuildTimestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Load existing form
  void _onLoadExistingForm(
    LoadExistingFormEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint(
      '💾 [FormBuilderBloc] Loading existing form: ${event.form.name}',
    );
    try {
      // Load the existing form data directly
      final existingForm = event.form;

      debugPrint(
        '💾 [FormBuilderBloc] Form has ${existingForm.pages.length} pages',
      );
      debugPrint('💾 [FormBuilderBloc] Form title: ${existingForm.name}');

      // Clear any existing state and load fresh form data
      emit(
        FormBuilderSuccess(
          components: const [], // Clear components
          pages: existingForm.pages,
          currentPageId: existingForm.pages.isNotEmpty
              ? existingForm.pages.first.pageId
              : 'page_1',
          availableComponents: _remoteConfigService.getAllConfigs(),
          availableButtonComponents: _remoteConfigService.getAllButtonConfigs(),
          isDragging: false,
          showComponentsPanel: true,
          showButtonComponentsPanel: false,
          formTitle: existingForm.name,
          insertIndicatorIndex: null,
          isHovering: false,
          hoveredComponent: null,
          hoverTargetIndex: null,
          rebuildTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      debugPrint('✅ [FormBuilderBloc] Existing form loaded successfully');
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to load existing form: $e';
      debugPrint('❌ [FormBuilderBloc] Error loading existing form: $e');
      debugPrint('❌ [FormBuilderBloc] Stack trace: $stackTrace');
      emit(
        FormBuilderError(
          errorMessage: errorMessage,
          components: state.components,
          pages: state.pages,
          currentPageId: state.currentPageId,
          availableComponents: state.availableComponents,
          availableButtonComponents: state.availableButtonComponents,
          isDragging: state.isDragging,
          showComponentsPanel: state.showComponentsPanel,
          showButtonComponentsPanel: state.showButtonComponentsPanel,
          formTitle: state.formTitle,
        ),
      );
    }
  }

  /// Force save all components
  void _onForceSaveAllComponents(
    ForceSaveAllComponentsEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    debugPrint('💾 [FormBuilderBloc] Forcing save of all components');
    // This event is typically handled by the UI layer to persist changes
    // For now, we just force a rebuild to ensure all changes are reflected
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        rebuildTimestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
