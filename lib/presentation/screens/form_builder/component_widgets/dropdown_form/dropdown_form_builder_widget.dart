import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/shared_widgets/shared_form_builder_widgets.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/shared_widgets/shared_optimized_input_widgets.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/shared_widgets/shared_option_editor_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DropdownFormBuilderWidget extends StatefulWidget {
  final DynamicFormModel component;
  final Function(DynamicFormModel)? onComponentUpdate;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final List<String>? availablePages;
  final String? currentPageId; // Add current page ID for navigation logic
  final int? currentPageIndex; // Add current page index for navigation logic

  const DropdownFormBuilderWidget({
    super.key,
    required this.component,
    this.onComponentUpdate,
    this.onDuplicate,
    this.onDelete,
    this.availablePages,
    this.currentPageId, // Add current page ID parameter
    this.currentPageIndex, // Add current page index parameter
  });

  @override
  State<DropdownFormBuilderWidget> createState() =>
      _DropdownFormBuilderWidgetState();
}

class _DropdownFormBuilderWidgetState extends State<DropdownFormBuilderWidget> {
  late TextEditingController _questionController;
  late TextEditingController _placeholderController;
  late TextEditingController _descriptionController;
  // Manage per-option focus and controllers to enable programmatic focus
  final Map<String, FocusNode> _optionFocusNodes = {};
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _placeholderController = TextEditingController();
    _descriptionController = TextEditingController();

    debugPrint(
      '🔄 [DropdownFormBuilderWidget] Initializing with current page index: ${widget.currentPageIndex}',
    );

    // Initialize the bloc
    context.read<DropdownFormBuilderWidgetBloc>().add(
      InitializeDropdownFormBuilderEvent(
        component: widget.component,
        availablePages: widget.availablePages,
      ),
    );
  }

  @override
  void didUpdateWidget(DropdownFormBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update available pages when widget is updated
    if (oldWidget.availablePages != widget.availablePages) {
      debugPrint(
        '🔄 [DropdownFormBuilderWidget] Available pages updated: ${widget.availablePages}',
      );
      context.read<DropdownFormBuilderWidgetBloc>().add(
        UpdateAvailablePagesEvent(availablePages: widget.availablePages),
      );
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _placeholderController.dispose();
    _descriptionController.dispose();
    // Dispose created option controllers and focus nodes
    for (final controller in _optionControllers.values) {
      controller.dispose();
    }
    for (final node in _optionFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateComponent() {
    debugPrint('🔍 [DropdownFormBuilderWidget] Updating component');
    debugPrint(
      '🔍 [DropdownFormBuilderWidget] Current description: ${_descriptionController.text}',
    );
    debugPrint(
      '🔍 [DropdownFormBuilderWidget] Current state description: ${context.read<DropdownFormBuilderWidgetBloc>().state.description}',
    );

    // Use current state description instead of controller text
    final currentState = context.read<DropdownFormBuilderWidgetBloc>().state;
    if (currentState is DropdownFormBuilderWidgetSuccess) {
      debugPrint(
        '🔍 [DropdownFormBuilderWidget] Using state description: ${currentState.description}',
      );
      debugPrint(
        '🔍 [DropdownFormBuilderWidget] Component options: ${currentState.options.map((o) => '${o.label}(${o.action}->${o.targetSection})').toList()}',
      );
    }

    context.read<DropdownFormBuilderWidgetBloc>().add(
      const UpdateComponentEvent(),
    );
  }

  // Return and cache FocusNode for a given option id
  FocusNode _getFocusNodeForOption(String optionId) {
    return _optionFocusNodes.putIfAbsent(optionId, () {
      debugPrint(
        '🧩 [DropdownFormBuilderWidget] Create FocusNode for $optionId',
      );
      return FocusNode();
    });
  }

  // Return and cache Controller for a given option id
  TextEditingController _getControllerForOption(String optionId, String label) {
    final controller = _optionControllers.putIfAbsent(optionId, () {
      debugPrint(
        '🧩 [DropdownFormBuilderWidget] Create Controller for $optionId',
      );
      return TextEditingController(text: label);
    });
    if (controller.text != label) {
      controller.text = label;
    }
    return controller;
  }

  // Keep controllers/focus nodes in sync with the latest options
  void _syncOptionControllers(List<Option> options) {
    final existingIds = options.map((o) => o.value).toSet();

    // Add or update controllers for current options
    for (final option in options) {
      _getControllerForOption(option.value, option.label);
      _getFocusNodeForOption(option.value);
    }

    // Clean up removed controllers and nodes
    final removedIds = _optionControllers.keys
        .where((id) => !existingIds.contains(id))
        .toList();
    for (final id in removedIds) {
      debugPrint('🧹 [DropdownFormBuilderWidget] Dispose removed option $id');
      _optionControllers.remove(id)?.dispose();
      _optionFocusNodes.remove(id)?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      DropdownFormBuilderWidgetBloc,
      DropdownFormBuilderWidgetState
    >(
      listener: (context, state) {
        _buildBlocListener(context, state);

        // Clear description controller when description is cleared
        if (state is DropdownFormBuilderWidgetSuccess &&
            state.description.isEmpty &&
            _descriptionController.text.isNotEmpty) {
          _descriptionController.clear();
        }
      },
      builder: (context, state) {
        if (state is DropdownFormBuilderWidgetLoading) {
          return SharedFormBuilderWidgets.buildLoadingWidget();
        }

        if (state is DropdownFormBuilderWidgetError) {
          return SharedFormBuilderWidgets.buildErrorWidget(
            errorMessage: state.errorMessage ?? 'Unknown error',
          );
        }

        if (state is DropdownFormBuilderWidgetSuccess) {
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside input fields
              FocusScope.of(context).unfocus();
            },
            child: SharedFormBuilderWidgets.buildMainContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(),
                  SharedFormBuilderWidgets.buildDescriptionSection(
                    descriptionController: _descriptionController,
                    currentDescription: state.description,
                    onDescriptionChanged: (value) {
                      debugPrint(
                        '🔍 [DropdownFormBuilderWidget] Description changed: $value',
                      );
                      context.read<DropdownFormBuilderWidgetBloc>().add(
                        UpdateDescriptionEvent(value),
                      );
                      debugPrint(
                        '🔍 [DropdownFormBuilderWidget] Calling _updateComponent after description change',
                      );
                      _updateComponent();
                    },
                    isEditing: state.isEditingDescription,
                    isEnabled: state.isDescriptionEnabled,
                    onEditTap: () {
                      debugPrint(
                        '🔍 [DropdownFormBuilderWidget] Edit tap - current state: isEditingDescription=${state.isEditingDescription}, isDescriptionEnabled=${state.isDescriptionEnabled}',
                      );
                      context.read<DropdownFormBuilderWidgetBloc>().add(
                        const SetEditingDescriptionEvent(true),
                      );
                    },
                    onCancelEdit: () {
                      debugPrint(
                        '🔍 [DropdownFormBuilderWidget] Cancel edit tap',
                      );
                      context.read<DropdownFormBuilderWidgetBloc>().add(
                        const CancelEditDescriptionEvent(),
                      );
                    },
                    onClearDescription: () {
                      debugPrint(
                        '🔍 [DropdownFormBuilderWidget] Clear description tap',
                      );
                      // Clear description and uncheck description state
                      context.read<DropdownFormBuilderWidgetBloc>().add(
                        const ClearDescriptionEvent(),
                      );
                      _updateComponent();
                    },
                  ),
                  _buildOptionsSection(state),
                  _buildBottomControls(state),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Bloc listener method
  void _buildBlocListener(
    BuildContext context,
    DropdownFormBuilderWidgetState state,
  ) {
    if (state is DropdownFormBuilderWidgetSuccess) {
      // Update controllers when state changes
      if (_questionController.text != state.question) {
        _questionController.text = state.question;
      }
      if (_placeholderController.text != state.placeholder) {
        _placeholderController.text = state.placeholder;
      }
      if (_descriptionController.text != state.description) {
        debugPrint(
          '🔍 [DropdownFormBuilderWidget] Updating description controller: ${state.description}',
        );
        _descriptionController.text = state.description;
      }

      // Sync option controllers/nodes with current options
      _syncOptionControllers(state.options);

      // Focus when bloc requests a specific option id
      if (state.focusOptionId != null) {
        final optionId = state.focusOptionId!;
        final target = state.options.firstWhere(
          (o) => o.value == optionId,
          orElse: () => state.options.isNotEmpty
              ? state.options.last
              : const Option(value: '', label: ''),
        );
        if (target.value.isNotEmpty) {
          final focusNode = _getFocusNodeForOption(target.value);
          final controller = _getControllerForOption(
            target.value,
            target.label,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            debugPrint(
              '🎯 [DropdownFormBuilderWidget] Request focus on option ${target.value}',
            );
            FocusScope.of(context).requestFocus(focusNode);
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
            // Tell bloc we've handled the focus request
            context.read<DropdownFormBuilderWidgetBloc>().add(
              const ClearFocusRequestEvent(),
            );
          });
        } else {
          // Clear if no valid target
          context.read<DropdownFormBuilderWidgetBloc>().add(
            const ClearFocusRequestEvent(),
          );
        }
      }

      // Call onComponentUpdate if component changed and has description
      if (widget.onComponentUpdate != null && state.component != null) {
        debugPrint(
          '🔍 [DropdownFormBuilderWidget] Calling onComponentUpdate with description: ${state.component?.config?.description}',
        );
        debugPrint(
          '🔍 [DropdownFormBuilderWidget] State description: ${state.description}',
        );
        debugPrint(
          '🔍 [DropdownFormBuilderWidget] Component config description: ${state.component?.config?.description}',
        );

        // Ensure component has the latest description from state
        final component = state.component;
        final updatedComponent = component?.copyWith(
          config: component.config?.copyWith(
            description: state.description,
          ),
        );

        debugPrint(
          '🔍 [DropdownFormBuilderWidget] Updated component description: ${updatedComponent?.config?.description}',
        );

        // Safely invoke callback
        if (updatedComponent != null) {
          debugPrint(
            '🔍 [DropdownFormBuilderWidget] onComponentUpdate invoked safely',
          );
          widget.onComponentUpdate?.call(updatedComponent);
        }
      }
    }
  }

  // Question header widget using shared widgets
  Widget _buildQuestionHeader() {
    return SharedFormBuilderWidgets.buildDropdownQuestionHeader(
      questionInput: SharedOptimizedInputWidgets.buildOptimizedQuestionInput(
        context: context,
        controller: _questionController,
        onUpdate: (value) {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            UpdateQuestionEvent(value),
          );
        },
        onUpdateComponent: _updateComponent,
      ),
      onImageTap: () => _showImageFeatureDialog(context),
      onDropdownTap: () => _showDropdownInfoDialog(context),
    );
  }

  // Options section widget
  Widget _buildOptionsSection(DropdownFormBuilderWidgetSuccess state) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SharedOptionsEditorList(
        options: state.options,
        focusOptionId: state.focusOptionId,
        onFocusHandled: () {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            const ClearFocusRequestEvent(),
          );
        },
        navigationFeatureEnabled: state.navigationFeatureEnabled,
        onReorder: (oldIndex, newIndex) {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            ReorderOptionsEvent(oldIndex: oldIndex, newIndex: newIndex),
          );
          _updateComponent();
        },
        onLabelChanged: (index, value) {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            UpdateOptionLabelEvent(index: index, label: value),
          );
          _updateComponent();
        },
        onRemove: (index) {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            RemoveOptionEvent(index),
          );
          _updateComponent();
        },
        onNavigateTap: (index) => _displayPageNavigationOptions(context, index),
        onAddOption: () {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            const AddOptionEvent(),
          );
          _updateComponent();
        },
        getNavigationLabel: (option) =>
            _getNavigationActionText(option, state.availablePages),
      ),
    );
  }

  // Bottom controls widget
  Widget _buildBottomControls(DropdownFormBuilderWidgetSuccess state) {
    return SharedFormBuilderWidgets.buildCommonBottomControls(
      onDuplicate: widget.onDuplicate,
      onDelete: widget.onDelete,
      isRequired: state.isRequired,
      onRequiredChanged: (value) {
        context.read<DropdownFormBuilderWidgetBloc>().add(
          UpdateRequiredEvent(value),
        );
        _updateComponent();
      },
      onDescriptionTap: () {
        // Start inline description editing
        context.read<DropdownFormBuilderWidgetBloc>().add(
          const SetEditingDescriptionEvent(true),
        );
      },
      onMoreOptions: () => _showMoreOptionsDialog(context),
    );
  }

  // Dropdown info dialog
  void _showDropdownInfoDialog(BuildContext context) {
    SharedFormBuilderWidgets.showInfoDialog(
      context: context,
      title: 'Dropdown Component',
      description:
          'This is a dropdown component that allows users to select from predefined options.',
      features: [
        'Multiple choice options',
        'Reorderable options',
        'Navigation based on selection',
        'Required field validation',
      ],
      icon: Icons.arrow_drop_down,
      iconColor: Colors.green,
      buttonText: 'Got it!',
      buttonColor: Colors.green,
    );
  }

  // Image feature dialog
  void _showImageFeatureDialog(BuildContext context) {
    SharedFormBuilderWidgets.showInfoDialog(
      context: context,
      title: 'Coming Soon',
      description: '🚀 This feature is under development',
      features: [
        '📷 Add images to dropdown options',
        '🎨 Customize image sizes and positions',
        '🔄 Drag and drop image upload',
        '💾 Save and reuse image templates',
      ],
      icon: Icons.image,
      iconColor: Colors.blue,
      buttonText: 'Got it!',
      buttonColor: Colors.blue,
    );
  }

  // Navigation options dialog
  void _displayPageNavigationOptions(BuildContext context, int optionIndex) {
    debugPrint(
      '🔄 [DropdownFormBuilder] Showing navigation options for option $optionIndex',
    );
    debugPrint(
      '🔄 [DropdownFormBuilder] Widget current page index: ${widget.currentPageIndex}',
    );
    debugPrint(
      '🔄 [DropdownFormBuilder] Widget current page ID: ${widget.currentPageId}',
    );

    final currentState = context.read<DropdownFormBuilderWidgetBloc>().state;
    if (currentState is! DropdownFormBuilderWidgetSuccess) return;

    debugPrint(
      '🔄 [DropdownFormBuilder] Available pages: ${currentState.availablePages}',
    );
    debugPrint(
      '🔄 [DropdownFormBuilder] Current page ID: ${widget.currentPageId}',
    );

    final List<Widget> navigationOptions = [
      _buildNavigationOption(
        context,
        'Next page',
        DropdownActionOptionsEnum.next,
        null,
        optionIndex,
      ),
    ];

    // Add available pages if provided, excluding current page and next page
    if (currentState.availablePages != null) {
      final pages = currentState.availablePages ?? const <String>[];

      // Use the provided current page index
      int currentPageIndex = widget.currentPageIndex ?? 0;

      final nextPageIndex = currentPageIndex + 1;

      debugPrint(
        '🔄 [DropdownFormBuilder] Current page index: $currentPageIndex, Next page index: $nextPageIndex',
      );
      debugPrint(
        '🔄 [DropdownFormBuilder] Total pages: ${pages.length}',
      );

      for (int i = 0; i < pages.length; i++) {
        // Skip current page and next page
        if (i == currentPageIndex || i == nextPageIndex) {
          debugPrint(
            '🔄 [DropdownFormBuilder] Skipping page at index $i (current: $currentPageIndex, next: $nextPageIndex)',
          );
          continue;
        }

        final pageName = pages[i];
        debugPrint(
          '🔄 [DropdownFormBuilder] Adding navigation option for page: $pageName (index: $i)',
        );

        navigationOptions.add(
          _buildNavigationOption(
            context,
            'Go to ${i + 1} ($pageName)',
            DropdownActionOptionsEnum.goto,
            pageName,
            optionIndex,
          ),
        );
      }
    } else {
      debugPrint(
        '🔄 [DropdownFormBuilder] No available pages provided, using fallback',
      );
      // Fallback to hardcoded pages if no available pages provided
      // Only show pages that are not current or next
      final currentPageIndex = 0; // Assume we're on page 1
      final nextPageIndex = 1;

      final fallbackPages = ['Page 1', 'Page 2', 'Page 3'];
      for (int i = 0; i < fallbackPages.length; i++) {
        if (i == currentPageIndex || i == nextPageIndex) {
          continue;
        }

        navigationOptions.add(
          _buildNavigationOption(
            context,
            'Go to ${i + 1} (${fallbackPages[i]})',
            DropdownActionOptionsEnum.goto,
            fallbackPages[i],
            optionIndex,
          ),
        );
      }
    }

    navigationOptions.add(
      _buildNavigationOption(
        context,
        'Submit page',
        DropdownActionOptionsEnum.submit,
        null,
        optionIndex,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Navigation for: ${currentState.options[optionIndex].label}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...navigationOptions,
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1F2937),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Navigation option widget
  Widget _buildNavigationOption(
    BuildContext context,
    String title,
    DropdownActionOptionsEnum action,
    String? targetSection,
    int optionIndex,
  ) {
    return GestureDetector(
      onTap: () {
        debugPrint(
          '🔄 [DropdownFormBuilder] Selected navigation for option $optionIndex: $action -> $targetSection',
        );
        debugPrint(
          '🔄 [DropdownFormBuilder] Navigation title: $title',
        );
        context.read<DropdownFormBuilderWidgetBloc>().add(
          UpdateOptionNavigationEvent(
            optionIndex: optionIndex,
            action: action,
            targetSection: targetSection,
          ),
        );
        _updateComponent();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Get navigation action text
  String _getNavigationActionText(Option option, List<String>? availablePages) {
    final action = option.action;
    final targetSection = option.targetSection;

    if (action == DropdownActionOptionsEnum.goto && targetSection != null) {
      // Show actual page name if available
      if (availablePages != null && availablePages.contains(targetSection)) {
        return 'Go to $targetSection';
      }
      // Fallback to target section name
      return 'Go to $targetSection';
    } else if (action == DropdownActionOptionsEnum.next) {
      return 'Next page';
    } else if (action == DropdownActionOptionsEnum.submit) {
      return 'Submit';
    }
    return 'Next page'; // Default
  }

  // More options dialog
  void _showMoreOptionsDialog(BuildContext context) {
    SharedFormBuilderWidgets.showMoreOptionsBottomSheet(
      context: context,
      getOptions: () {
        final currentState = context
            .read<DropdownFormBuilderWidgetBloc>()
            .state;
        if (currentState is! DropdownFormBuilderWidgetSuccess) {
          return [];
        }

        return SharedFormBuilderWidgets.getDropdownMoreOptions(
          onDescriptionTap: () {
            // Start inline description editing instead of showing dialog
            context.read<DropdownFormBuilderWidgetBloc>().add(
              const SetEditingDescriptionEvent(true),
            );
          },
          onNavigationFeatureTap: () {
            context.read<DropdownFormBuilderWidgetBloc>().add(
              const EnableNavigationFeatureEvent(),
            );
            _updateComponent();
          },
          isNavigationEnabled: currentState.navigationFeatureEnabled,
          isDescriptionEnabled: currentState.isDescriptionEnabled,
          onNavigationToggle: () {
            // Toggle navigation feature
            if (currentState.navigationFeatureEnabled) {
              // Disable navigation feature
              context.read<DropdownFormBuilderWidgetBloc>().add(
                const DisableNavigationFeatureEvent(),
              );
            } else {
              // Enable navigation feature
              context.read<DropdownFormBuilderWidgetBloc>().add(
                const EnableNavigationFeatureEvent(),
              );
            }
            _updateComponent();
          },
          onDescriptionToggle: () {
            // Toggle description editing
            if (currentState.isDescriptionEnabled) {
              // If currently enabled, disable and clear description
              context.read<DropdownFormBuilderWidgetBloc>().add(
                const ToggleDescriptionEnabledEvent(),
              );
              // Clear description by setting it to empty string
              context.read<DropdownFormBuilderWidgetBloc>().add(
                const UpdateDescriptionEvent(''),
              );
              _updateComponent();
            } else {
              // If not enabled, enable editing mode
              context.read<DropdownFormBuilderWidgetBloc>().add(
                const ToggleDescriptionEnabledEvent(),
              );
            }
          },
        );
      },
    );
  }
}
