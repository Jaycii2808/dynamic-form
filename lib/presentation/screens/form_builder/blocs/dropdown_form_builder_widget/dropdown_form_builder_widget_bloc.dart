import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DropdownFormBuilderWidgetBloc
    extends
        Bloc<DropdownFormBuilderWidgetEvent, DropdownFormBuilderWidgetState> {
  DropdownFormBuilderWidgetBloc()
    : super(
        const DropdownFormBuilderWidgetInitial(),
      ) {
    on<InitializeDropdownFormBuilderEvent>(_onInitialize);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<UpdatePlaceholderEvent>(_onUpdatePlaceholder);
    on<UpdateDescriptionEvent>(
      _onUpdateDescription,
    );
    on<UpdateRequiredEvent>(_onUpdateRequired);
    on<AddOptionEvent>(_onAddOption);
    on<RemoveOptionEvent>(_onRemoveOption);
    on<UpdateOptionLabelEvent>(_onUpdateOptionLabel);
    on<ReorderOptionsEvent>(_onReorderOptions);
    on<UpdateOptionNavigationEvent>(_onUpdateOptionNavigation);
    on<EnableNavigationFeatureEvent>(_onEnableNavigationFeature);
    on<DisableNavigationFeatureEvent>(_onDisableNavigationFeature);
    on<UpdateComponentEvent>(_onUpdateComponent);
    on<SetEditingDescriptionEvent>(_onSetEditingDescription);
    on<CancelEditDescriptionEvent>(_onCancelEditDescription);
    on<ToggleDescriptionEnabledEvent>(_onToggleDescriptionEnabled);
  }

  Future<void> _onInitialize(
    InitializeDropdownFormBuilderEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Initializing with component: ${event.component.id}',
    );
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Component config description: ${event.component.config?.description}',
    );

    emit(DropdownFormBuilderWidgetLoading.fromState(state: state));

    try {
      final component = event.component;
      final question = component.config?.label ?? '';
      final placeholder = component.config?.placeholder ?? 'Select an option';
      final description =
          component.config?.description ?? ''; // Add description
      final options = List<Option>.from(component.config?.options ?? []);
      final isRequired = component.config?.isRequired ?? false;
      final availablePages = event.availablePages;

      debugPrint(
        '🔄 [DropdownFormBuilderBloc] Loaded description: $description',
      );

      // Add default options if empty
      List<Option> finalOptions = options;
      if (finalOptions.isEmpty) {
        finalOptions = [
          const Option(value: 'option1', label: 'Option 1', order: 1),
          const Option(value: 'option2', label: 'Option 2', order: 2),
          const Option(value: 'option3', label: 'Option 3', order: 3),
        ];
      }

      // Check if navigation feature is enabled by checking if any option has action
      final navigationFeatureEnabled = finalOptions.any(
        (option) => option.action != null,
      );

      // Set description enabled only if there's actual description content
      final isDescriptionEnabled = description.isNotEmpty;

      emit(
        DropdownFormBuilderWidgetSuccess(
          question: question,
          placeholder: placeholder,
          description: description, // Add description
          options: finalOptions,
          isRequired: isRequired,
          navigationFeatureEnabled: navigationFeatureEnabled,
          availablePages: availablePages,
          component: component,
          isDescriptionEnabled: isDescriptionEnabled, // Set based on content
          isEditingDescription: false, // Always start with false
        ),
      );

      debugPrint(
        '✅ [DropdownFormBuilderBloc] Initialized successfully with ${finalOptions.length} options',
      );
      debugPrint(
        '✅ [DropdownFormBuilderBloc] Initialized with description: $description',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error initializing: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage:
              'Failed to initialize dropdown form builder: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Updating question: ${event.question}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        emit(currentState.copyWith(question: event.question));
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error updating question: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update question: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdatePlaceholder(
    UpdatePlaceholderEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Updating placeholder: ${event.placeholder}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        emit(currentState.copyWith(placeholder: event.placeholder));
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error updating placeholder: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update placeholder: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Updating description: ${event.description}',
    );
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Current state description: ${state.description}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        debugPrint(
          '🔄 [DropdownFormBuilderBloc] Current state description: ${currentState.description}',
        );

        final newState = currentState.copyWith(description: event.description);
        debugPrint(
          '🔄 [DropdownFormBuilderBloc] New state description: ${newState.description}',
        );

        emit(newState);
        debugPrint(
          '✅ [DropdownFormBuilderBloc] Description updated successfully: ${event.description}',
        );
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error updating description: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update description: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateRequired(
    UpdateRequiredEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Updating required: ${event.isRequired}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        emit(currentState.copyWith(isRequired: event.isRequired));
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error updating required: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update required: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAddOption(
    AddOptionEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint('🔄 [DropdownFormBuilderBloc] Adding new option');

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final newOrder = currentState.options.length + 1;
        final newOption = Option(
          value: 'option$newOrder',
          label: 'Option $newOrder',
          order: newOrder,
          // Add default navigation action if feature is enabled
          action: currentState.navigationFeatureEnabled
              ? DropdownActionOptionsEnum.next
              : null,
          targetSection: currentState.navigationFeatureEnabled ? null : null,
        );

        final updatedOptions = List<Option>.from(currentState.options)
          ..add(newOption);

        emit(currentState.copyWith(options: updatedOptions));
        debugPrint(
          '✅ [DropdownFormBuilderBloc] Added option: ${newOption.label}',
        );
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error adding option: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to add option: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRemoveOption(
    RemoveOptionEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Removing option at index: ${event.index}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final updatedOptions = List<Option>.from(currentState.options);
        updatedOptions.removeAt(event.index);

        // Reorder remaining options
        for (int i = 0; i < updatedOptions.length; i++) {
          updatedOptions[i] = updatedOptions[i].copyWith(order: i + 1);
        }

        emit(currentState.copyWith(options: updatedOptions));
        debugPrint(
          '✅ [DropdownFormBuilderBloc] Removed option, remaining: ${updatedOptions.length}',
        );
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error removing option: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to remove option: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateOptionLabel(
    UpdateOptionLabelEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Updating option label at index ${event.index}: ${event.label}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final updatedOptions = List<Option>.from(currentState.options);
        updatedOptions[event.index] = updatedOptions[event.index].copyWith(
          label: event.label,
        );

        emit(currentState.copyWith(options: updatedOptions));
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error updating option label: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update option label: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onReorderOptions(
    ReorderOptionsEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Reordering options: ${event.oldIndex} -> ${event.newIndex}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final updatedOptions = List<Option>.from(currentState.options);

        int newIndex = event.newIndex;
        if (newIndex > event.oldIndex) {
          newIndex -= 1;
        }

        final item = updatedOptions.removeAt(event.oldIndex);
        updatedOptions.insert(newIndex, item);

        // Update order numbers
        for (int i = 0; i < updatedOptions.length; i++) {
          updatedOptions[i] = updatedOptions[i].copyWith(order: i + 1);
        }

        emit(currentState.copyWith(options: updatedOptions));
        debugPrint(
          '✅ [DropdownFormBuilderBloc] Reordered options successfully',
        );
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error reordering options: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to reorder options: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateOptionNavigation(
    UpdateOptionNavigationEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Updating option navigation: ${event.optionIndex} -> ${event.action}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final updatedOptions = List<Option>.from(currentState.options);

        if (event.optionIndex >= 0 &&
            event.optionIndex < updatedOptions.length) {
          final updatedOption = updatedOptions[event.optionIndex].copyWith(
            action: event.action,
            targetSection: event.targetSection,
          );
          updatedOptions[event.optionIndex] = updatedOption;

          emit(currentState.copyWith(options: updatedOptions));
          debugPrint(
            '✅ [DropdownFormBuilderBloc] Updated option navigation: ${updatedOption.label}',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '❌ [DropdownFormBuilderBloc] Error updating option navigation: $e',
      );
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update option navigation: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onEnableNavigationFeature(
    EnableNavigationFeatureEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint('🔄 [DropdownFormBuilderBloc] Enabling navigation feature');

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final updatedOptions = List<Option>.from(currentState.options);

        // Enable navigation feature for all options if not already enabled
        for (int i = 0; i < updatedOptions.length; i++) {
          if (updatedOptions[i].action == null) {
            updatedOptions[i] = updatedOptions[i].copyWith(
              action: DropdownActionOptionsEnum.next,
              targetSection: null,
            );
          }
        }

        emit(
          currentState.copyWith(
            options: updatedOptions,
            navigationFeatureEnabled: true,
          ),
        );
        debugPrint('✅ [DropdownFormBuilderBloc] Navigation feature enabled');
      }
    } catch (e) {
      debugPrint(
        '❌ [DropdownFormBuilderBloc] Error enabling navigation feature: $e',
      );
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to enable navigation feature: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDisableNavigationFeature(
    DisableNavigationFeatureEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint('🔄 [DropdownFormBuilderBloc] Disabling navigation feature');

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final updatedOptions = List<Option>.from(currentState.options);

        // Disable navigation feature for all options if not already disabled
        for (int i = 0; i < updatedOptions.length; i++) {
          if (updatedOptions[i].action != null) {
            updatedOptions[i] = updatedOptions[i].copyWith(
              action: null,
              targetSection: null,
            );
          }
        }

        emit(
          currentState.copyWith(
            options: updatedOptions,
            navigationFeatureEnabled: false,
          ),
        );
        debugPrint('✅ [DropdownFormBuilderBloc] Navigation feature disabled');
      }
    } catch (e) {
      debugPrint(
        '❌ [DropdownFormBuilderBloc] Error disabling navigation feature: $e',
      );
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to disable navigation feature: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateComponent(
    UpdateComponentEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint('🔄 [DropdownFormBuilderBloc] Updating component');
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Current description: ${state.description}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final component = currentState.component;

        if (component != null) {
          debugPrint(
            '🔄 [DropdownFormBuilderBloc] Component before update - description: ${component.config?.description}',
          );
          debugPrint(
            '🔄 [DropdownFormBuilderBloc] Current state description: ${currentState.description}',
          );

          // Create updated config with all current state values
          final updatedConfig =
              component.config?.copyWith(
                label: currentState.question,
                placeholder: currentState.placeholder,
                description:
                    currentState.description, // Ensure description is set
                isRequired: currentState.isRequired,
                options: currentState.options,
              ) ??
              ConfigModel(
                label: currentState.question,
                placeholder: currentState.placeholder,
                description:
                    currentState.description, // Ensure description is set
                isRequired: currentState.isRequired,
                options: currentState.options,
              );

          final updatedComponent = component.copyWith(
            config: updatedConfig,
          );

          debugPrint(
            '🔄 [DropdownFormBuilderBloc] Updated component description: ${updatedComponent.config?.description}',
          );

          // Emit new state with updated component
          final newState = currentState.copyWith(component: updatedComponent);
          emit(newState);

          debugPrint(
            '✅ [DropdownFormBuilderBloc] Component updated successfully',
          );
          debugPrint(
            '✅ [DropdownFormBuilderBloc] Final component description: ${updatedComponent.config?.description}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [DropdownFormBuilderBloc] Error updating component: $e');
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to update component: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSetEditingDescription(
    SetEditingDescriptionEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint(
      '🔄 [DropdownFormBuilderBloc] Setting editing description: ${event.isEditing}',
    );

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        emit(currentState.copyWith(isEditingDescription: event.isEditing));
        debugPrint(
          '✅ [DropdownFormBuilderBloc] Editing description set to: ${event.isEditing}',
        );
      }
    } catch (e) {
      debugPrint(
        '❌ [DropdownFormBuilderBloc] Error setting editing description: $e',
      );
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to set editing description: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onCancelEditDescription(
    CancelEditDescriptionEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint('🔄 [DropdownFormBuilderBloc] Canceling edit description');

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        emit(currentState.copyWith(isEditingDescription: false));
        debugPrint('✅ [DropdownFormBuilderBloc] Edit description canceled');
      }
    } catch (e) {
      debugPrint(
        '❌ [DropdownFormBuilderBloc] Error canceling edit description: $e',
      );
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to cancel edit description: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onToggleDescriptionEnabled(
    ToggleDescriptionEnabledEvent event,
    Emitter<DropdownFormBuilderWidgetState> emit,
  ) async {
    debugPrint('🔄 [DropdownFormBuilderBloc] Toggling description enabled');

    try {
      if (state is DropdownFormBuilderWidgetSuccess) {
        final currentState = state as DropdownFormBuilderWidgetSuccess;
        final newEnabled = !currentState.isDescriptionEnabled;

        if (newEnabled) {
          // Enable description and start editing
          emit(
            currentState.copyWith(
              isDescriptionEnabled: true,
              isEditingDescription: true,
            ),
          );
          debugPrint(
            '✅ [DropdownFormBuilderBloc] Description enabled and editing started',
          );
        } else {
          // Disable description, clear it, and stop editing
          emit(
            currentState.copyWith(
              isDescriptionEnabled: false,
              isEditingDescription: false,
              description: '',
            ),
          );
          debugPrint(
            '✅ [DropdownFormBuilderBloc] Description disabled and cleared',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '❌ [DropdownFormBuilderBloc] Error toggling description enabled: $e',
      );
      emit(
        DropdownFormBuilderWidgetError(
          errorMessage: 'Failed to toggle description enabled: ${e.toString()}',
        ),
      );
    }
  }
}
