import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/shared_form_builder_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DropdownFormBuilderWidget extends StatefulWidget {
  final DynamicFormModel component;
  final Function(DynamicFormModel)? onComponentUpdate;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final List<String>? availablePages;

  const DropdownFormBuilderWidget({
    super.key,
    required this.component,
    this.onComponentUpdate,
    this.onDuplicate,
    this.onDelete,
    this.availablePages,
  });

  @override
  State<DropdownFormBuilderWidget> createState() =>
      _DropdownFormBuilderWidgetState();
}

class _DropdownFormBuilderWidgetState extends State<DropdownFormBuilderWidget> {
  late TextEditingController _questionController;
  late TextEditingController _placeholderController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _placeholderController = TextEditingController();
    _descriptionController = TextEditingController();

    // Initialize the bloc
    context.read<DropdownFormBuilderWidgetBloc>().add(
      InitializeDropdownFormBuilderEvent(
        component: widget.component,
        availablePages: widget.availablePages,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _placeholderController.dispose();
    _descriptionController.dispose();
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
    }

    context.read<DropdownFormBuilderWidgetBloc>().add(
      const UpdateComponentEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      DropdownFormBuilderWidgetBloc,
      DropdownFormBuilderWidgetState
    >(
      listener: _buildBlocListener,
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
          return SharedFormBuilderWidgets.buildMainContainer(
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
                    context.read<DropdownFormBuilderWidgetBloc>().add(
                      const SetEditingDescriptionEvent(true),
                    );
                  },
                  onCancelEdit: () {
                    context.read<DropdownFormBuilderWidgetBloc>().add(
                      const CancelEditDescriptionEvent(),
                    );
                  },
                ),
                _buildOptionsSection(state),
                _buildBottomControls(state),
              ],
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
        final updatedComponent = state.component!.copyWith(
          config: state.component!.config?.copyWith(
            description: state.description,
          ),
        );

        debugPrint(
          '🔍 [DropdownFormBuilderWidget] Updated component description: ${updatedComponent.config?.description}',
        );

        widget.onComponentUpdate!(updatedComponent);
      }
    }
  }

  // Question header widget using shared widgets
  Widget _buildQuestionHeader() {
    return SharedFormBuilderWidgets.buildDropdownQuestionHeader(
      questionInput: SharedFormBuilderWidgets.buildQuestionInput(
        controller: _questionController,
        onChanged: (value) {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            UpdateQuestionEvent(value),
          );
          _updateComponent();
        },
      ),
      onImageTap: () => _showImageFeatureDialog(context),
      onDropdownTap: () => _showDropdownInfoDialog(context),
    );
  }

  // Options section widget
  Widget _buildOptionsSection(DropdownFormBuilderWidgetSuccess state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionsList(state),
          _buildAddOptionButton(),
        ],
      ),
    );
  }

  // Options list widget
  Widget _buildOptionsList(DropdownFormBuilderWidgetSuccess state) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.options.length,
      onReorder: (oldIndex, newIndex) {
        context.read<DropdownFormBuilderWidgetBloc>().add(
          ReorderOptionsEvent(
            oldIndex: oldIndex,
            newIndex: newIndex,
          ),
        );
        _updateComponent();
      },
      itemBuilder: (context, index) {
        final option = state.options[index];
        return _buildOptionItem(option, index, state);
      },
    );
  }

  // Individual option item widget
  Widget _buildOptionItem(
    Option option,
    int index,
    DropdownFormBuilderWidgetSuccess state,
  ) {
    return Container(
      key: ValueKey(option.value),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionRow(option, index),
          if (state.navigationFeatureEnabled)
            _buildNavigationAction(option, index, state),
        ],
      ),
    );
  }

  // Option row widget
  Widget _buildOptionRow(Option option, int index) {
    return Row(
      children: [
        _buildDragHandle(),
        _buildOptionNumber(index),
        _buildOptionInput(option, index),
        _buildRemoveButton(index),
      ],
    );
  }

  // Drag handle widget
  Widget _buildDragHandle() {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 8),
      child: const Icon(
        Icons.drag_handle,
        color: Color(0xFF9CA3AF),
        size: 20,
      ),
    );
  }

  // Option number widget
  Widget _buildOptionNumber(int index) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 8),
      child: Text(
        '${index + 1}.',
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Option input widget
  Widget _buildOptionInput(Option option, int index) {
    return Expanded(
      child: TextField(
        controller: TextEditingController(text: option.label),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          hintText: 'Option',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          context.read<DropdownFormBuilderWidgetBloc>().add(
            UpdateOptionLabelEvent(
              index: index,
              label: value,
            ),
          );
          _updateComponent();
        },
      ),
    );
  }

  // Remove button widget
  Widget _buildRemoveButton(int index) {
    return GestureDetector(
      onTap: () {
        context.read<DropdownFormBuilderWidgetBloc>().add(
          RemoveOptionEvent(index),
        );
        _updateComponent();
      },
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(left: 8),
        child: const Icon(
          Icons.close,
          color: Color(0xFF9CA3AF),
          size: 20,
        ),
      ),
    );
  }

  // Navigation action widget
  Widget _buildNavigationAction(
    Option option,
    int index,
    DropdownFormBuilderWidgetSuccess state,
  ) {
    return GestureDetector(
      onTap: () => _displayPageNavigationOptions(context, index),
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.navigation, color: Colors.blue, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _getNavigationActionText(option, state.availablePages),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, color: Colors.blue, size: 12),
          ],
        ),
      ),
    );
  }

  // Add option button widget
  Widget _buildAddOptionButton() {
    return GestureDetector(
      onTap: () {
        context.read<DropdownFormBuilderWidgetBloc>().add(
          const AddOptionEvent(),
        );
        _updateComponent();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              'Add option',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Row(
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Dropdown Component',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This is a dropdown component that allows users to select from predefined options.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Features:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Multiple choice options',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '• Reorderable options',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '• Navigation based on selection',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '• Required field validation',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Image feature dialog
  void _showImageFeatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Row(
            children: [
              Icon(Icons.image, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Coming Soon',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🚀 This feature is under development',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You will be able to:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('📷 Add images to dropdown options'),
              _buildFeatureItem('🎨 Customize image sizes and positions'),
              _buildFeatureItem('🔄 Drag and drop image upload'),
              _buildFeatureItem('💾 Save and reuse image templates'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Feature item widget
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation options dialog
  void _displayPageNavigationOptions(BuildContext context, int optionIndex) {
    debugPrint(
      '🔄 [DropdownFormBuilder] Showing navigation options for option $optionIndex',
    );

    final currentState = context.read<DropdownFormBuilderWidgetBloc>().state;
    if (currentState is! DropdownFormBuilderWidgetSuccess) return;

    final List<Widget> navigationOptions = [
      _buildNavigationOption(
        context,
        'Continue to next section',
        DropdownActionOptionsEnum.next,
        null,
        optionIndex,
      ),
    ];

    // Add available pages if provided
    if (currentState.availablePages != null) {
      int index = 0;
      for (final pageName in currentState.availablePages!) {
        navigationOptions.add(
          _buildNavigationOption(
            context,
            'Go to $pageName',
            DropdownActionOptionsEnum.goto,
            'page_${index + 1}',
            optionIndex,
          ),
        );
        index++;
      }
    } else {
      // Fallback to hardcoded pages if no available pages provided
      navigationOptions.addAll([
        _buildNavigationOption(
          context,
          'Go to page 1',
          DropdownActionOptionsEnum.goto,
          'page_1',
          optionIndex,
        ),
        _buildNavigationOption(
          context,
          'Go to page 2',
          DropdownActionOptionsEnum.goto,
          'page_2',
          optionIndex,
        ),
      ]);
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
      // Try to show actual page name if available
      if (targetSection.startsWith('page_') && availablePages != null) {
        try {
          final pageNumber = int.parse(targetSection.substring(5));
          if (pageNumber > 0 && pageNumber <= availablePages.length) {
            return 'Go to ${availablePages[pageNumber - 1]}';
          }
        } catch (e) {
          debugPrint('❌ [DropdownFormBuilder] Error parsing page number: $e');
        }
      }
      return 'Go to $targetSection';
    } else if (action == DropdownActionOptionsEnum.next) {
      return 'Continue';
    } else if (action == DropdownActionOptionsEnum.submit) {
      return 'Submit';
    }
    return 'Continue'; // Default
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
