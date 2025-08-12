import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/core/services/remote_config_service.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormBuilderBloc extends Bloc<FormBuilderEvent, FormBuilderState> {
  final RemoteConfigService _remoteConfigService;
  final UserFormsService _userFormsService;

  FormBuilderBloc({
    required RemoteConfigService remoteConfigService,
    required UserFormsService userFormsService,
  }) : _remoteConfigService = remoteConfigService,
       _userFormsService = userFormsService,
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
    on<InsertComponentEvent>(_onInsertComponent);
    on<StartHoverEvent>(_onStartHover);
    on<EndHoverEvent>(_onEndHover);
    on<ShowInsertIndicatorEvent>(_onShowInsertIndicator);
    on<HideInsertIndicatorEvent>(_onHideInsertIndicator);
    on<EditComponentConfigEvent>(_onEditComponentConfig);
    on<EditComponentLabelEvent>(_onEditComponentLabel);
    on<EditComponentPlaceholderEvent>(_onEditComponentPlaceholder);
    on<ForceRebuildUIEvent>(_onForceRebuildUI);
    on<LoadExistingFormEvent>(_onLoadExistingForm);
    on<LoadExistingFormByIdEvent>(_onLoadExistingFormById);
    on<ForceSaveAllComponentsEvent>(_onForceSaveAllComponents);
    on<HighlightComponentEvent>(_onHighlightComponent);
    on<StartCanvasComponentDragEvent>(_onStartCanvasComponentDrag);
    on<EndCanvasComponentDragEvent>(_onEndCanvasComponentDrag);
    on<DropCanvasComponentEvent>(_onDropCanvasComponent);
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
    } catch (e) {
      String errorMessage = 'Failed to load components: $e';
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
    } catch (e) {
      String errorMessage = 'Failed to load button components: $e';
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
    // Logging removed; use Bloc Observer

    // Always assign a fresh unique id when adding from palette to avoid duplicates
    final String uniqueId =
        '${event.component.id}_${DateTime.now().millisecondsSinceEpoch}';
    final DynamicFormModel componentWithUniqueId = event.component.copyWith(
      id: uniqueId,
    );
    final DynamicFormModel componentWithDefaults = _applyDefaultLabelIfNeeded(
      componentWithUniqueId,
    );

    // Add component to the current page
    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = List<DynamicFormModel>.from(page.components)
          ..add(componentWithDefaults);
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

    // Logging removed; use Bloc Observer
  }

  void _onMoveComponent(
    MoveComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
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
  }

  void _onRemoveComponent(
    RemoveComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
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
  }

  void _onStartDrag(
    StartDragEvent event,
    Emitter<FormBuilderState> emit,
  ) {
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
  }

  void _onUpdateComponentValue(
    UpdateComponentValueEvent event,
    Emitter<FormBuilderState> emit,
  ) {}

  /// Handle component actions (move up, move down, delete)
  void _onHandleComponentAction(
    HandleComponentActionEvent event,
    Emitter<FormBuilderState> emit,
  ) {
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
    final updatedPages = state.pages.map((page) {
      if (page.pageId == event.pageId) {
        return page.copyWith(title: event.title);
      }
      return page;
    }).toList();

    // final availablePages = updatedPages.map((page) => page.title).toList();

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
    // Logging removed; use Bloc Observer

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

    //final availablePages = updatedPages.map((page) => page.title).toList();
    // Logging removed; use Bloc Observer

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

  /// Insert component at specific index
  void _onInsertComponent(
    InsertComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    // Logging removed; use Bloc Observer

    // Always assign a fresh unique id when inserting from palette to avoid duplicates
    final String uniqueId =
        '${event.component.id}_${DateTime.now().millisecondsSinceEpoch}';
    final DynamicFormModel componentWithUniqueId = event.component.copyWith(
      id: uniqueId,
    );
    final DynamicFormModel componentWithDefaults = _applyDefaultLabelIfNeeded(
      componentWithUniqueId,
    );

    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = List<DynamicFormModel>.from(page.components);
        updatedComponents.insert(event.insertIndex, componentWithDefaults);
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
    // Logging removed; use Bloc Observer

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
    final updatedPages = state.pages.map((page) {
      if (page.pageId == state.currentPageId) {
        final updatedComponents = page.components.map((component) {
          if (component.id == event.componentId) {
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
    try {
      // Load the existing form data directly
      final existingForm = event.form;

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
    } catch (e) {
      String errorMessage = 'Failed to load existing form: $e';
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

  Future<void> _onLoadExistingFormById(
    LoadExistingFormByIdEvent event,
    Emitter<FormBuilderState> emit,
  ) async {
    emit(FormBuilderLoading.fromState(state: state));
    try {
      final data = await _userFormsService.getUserFormById(
        formId: event.formId,
        userId: event.userId,
      );

      if (data == null || data['formData'] == null) {
        throw Exception('Form not found');
      }

      final formBuilderModel = FormBuilderModel.fromJson(
        Map<String, dynamic>.from(data['formData'] as Map),
      );

      // Load the form using existing LoadExistingFormEvent logic
      add(LoadExistingFormEvent(formBuilderModel));
    } catch (e) {
      emit(
        FormBuilderError(
          errorMessage: 'Failed to load form by ID: $e',
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
    // This event is typically handled by the UI layer to persist changes
    // For now, we just force a rebuild to ensure all changes are reflected
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        rebuildTimestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void _onHighlightComponent(
    HighlightComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        highlightedComponentId: event.componentId,
        rebuildTimestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Start dragging an existing component on the canvas
  void _onStartCanvasComponentDrag(
    StartCanvasComponentDragEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        draggingFromPageId: event.pageId,
        draggingFromIndex: event.index,
        draggingComponent: event.component,
        isDragging: true,
      ),
    );
  }

  /// End dragging existing component (cleanup if no drop)
  void _onEndCanvasComponentDrag(
    EndCanvasComponentDragEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        draggingFromPageId: null,
        draggingFromIndex: null,
        draggingComponent: null,
        isDragging: false,
      ),
    );
  }

  /// Drop existing component to target page/index
  void _onDropCanvasComponent(
    DropCanvasComponentEvent event,
    Emitter<FormBuilderState> emit,
  ) {
    final current = state;
    if (current.draggingFromPageId == null ||
        current.draggingFromIndex == null) {
      return;
    }

    final String sourcePageId = current.draggingFromPageId!;
    final int sourceIndex = current.draggingFromIndex!;
    final String targetPageId = event.targetPageId;
    int insertIndex = event.insertIndex;

    // Build pages copy with removal then insertion
    final updatedPages = current.pages.map((page) {
      if (page.pageId == sourcePageId) {
        final comps = List<DynamicFormModel>.from(page.components);
        if (sourceIndex >= 0 && sourceIndex < comps.length) {
          // final removed = comps.removeAt(sourceIndex);
          // When moving within same page and dropping after original pos, adjust index
          if (sourcePageId == targetPageId && insertIndex > sourceIndex) {
            insertIndex = insertIndex - 1;
          }
          // Store back removed in bloc local var to use on target page insertion
          return page.copyWith(components: comps);
        }
      }
      return page;
    }).toList();

    // Extract the removed component from original state (safe by id)
    final DynamicFormModel? movingComponent = (() {
      // final srcPage = state.pages.firstWhere(
      //   (p) => p.pageId == sourcePageId,
      //   orElse: () => current.pages.first,
      // );
      // When we removed above we cannot access removed; instead, pull from draggingComponent
      return current.draggingComponent;
    })();

    if (movingComponent == null) {
      return;
    }

    // Insert into target page
    final finalPages = updatedPages.map((page) {
      if (page.pageId == targetPageId) {
        final comps = List<DynamicFormModel>.from(page.components);
        final safeIndex = insertIndex.clamp(0, comps.length);
        comps.insert(safeIndex, movingComponent);
        return page.copyWith(components: comps);
      }
      return page;
    }).toList();

    emit(
      FormBuilderSuccess.fromState(state: state).copyWith(
        pages: finalPages,
        currentPageId: targetPageId,
        draggingFromPageId: null,
        draggingFromIndex: null,
        draggingComponent: null,
        isDragging: false,
        insertIndicatorIndex: null,
        isHovering: false,
        hoveredComponent: null,
        hoverTargetIndex: null,
      ),
    );
  }

  // Apply default label for specific component types when missing
  DynamicFormModel _applyDefaultLabelIfNeeded(DynamicFormModel component) {
    if (component.type == FormTypeEnum.dropdownFormType) {
      final String? currentLabel = component.config?.label;
      final bool isEmpty = currentLabel == null || currentLabel.trim().isEmpty;
      if (isEmpty) {
        final updatedConfig =
            component.config?.copyWith(
              label: '',
            ) ??
            const ConfigModel(label: '');
        return component.copyWith(config: updatedConfig);
      }
    }
    return component;
  }
}
