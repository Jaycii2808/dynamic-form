import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/shared_form_builder_widgets.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'dart:async'; // Added for Timer

class ShortAnswerFormBuilderWidget extends StatefulWidget {
  final DynamicFormModel component;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final Function(DynamicFormModel) onComponentUpdate;
  final List<String>? availablePages;
  final int? currentPageIndex;

  const ShortAnswerFormBuilderWidget({
    super.key,
    required this.component,
    this.onDuplicate,
    this.onDelete,
    required this.onComponentUpdate,
    this.availablePages,
    this.currentPageIndex,
  });

  @override
  State<ShortAnswerFormBuilderWidget> createState() =>
      _ShortAnswerFormBuilderWidgetState();
}

class _ShortAnswerFormBuilderWidgetState
    extends State<ShortAnswerFormBuilderWidget> {
  late TextEditingController _questionController;
  late TextEditingController _descriptionController;
  late TextEditingController _validationValueController;
  late TextEditingController _errorMessageController;

  // Add debounce mechanism
  Timer? _updateTimer;
  String _lastUpdateHash = '';

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.component.config?.label ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.component.config?.description ?? '',
    );
    _validationValueController = TextEditingController(
      text: '', // Initialize with empty string to prevent null issues
    );
    _errorMessageController = TextEditingController(
      text: '', // Initialize with empty string to prevent null issues
    );

    // Initialize BLoC
    context.read<ShortAnswerFormBuilderWidgetBloc>().add(
      InitializeShortAnswerFormBuilderEvent(
        component: widget.component,
        availablePages: widget.availablePages,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    _validationValueController.dispose();
    _errorMessageController.dispose();
    _updateTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      ShortAnswerFormBuilderWidgetBloc,
      ShortAnswerFormBuilderWidgetState
    >(
      listener: _buildBlocListener,
      builder: (context, state) {
        if (state is ShortAnswerFormBuilderWidgetSuccess) {
          return _buildSuccessState(state);
        } else if (state is ShortAnswerFormBuilderWidgetLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ShortAnswerFormBuilderWidgetError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _buildBlocListener(
    BuildContext context,
    ShortAnswerFormBuilderWidgetState state,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      // Update validation controllers safely
      final validationValue = state.validation.validationValue ?? '';
      final errorMessage = state.validation.errorMessage ?? '';

      if (_validationValueController.text != validationValue) {
        _validationValueController.text = validationValue;
      }
      if (_errorMessageController.text != errorMessage) {
        _errorMessageController.text = errorMessage;
      }
    }
  }

  Widget _buildSuccessState(ShortAnswerFormBuilderWidgetSuccess state) {
    return SharedFormBuilderWidgets.buildMainContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          _buildQuestionHeader(),
          SharedFormBuilderWidgets.buildDescriptionSection(
            descriptionController: _descriptionController,
            currentDescription: state.description,
            onDescriptionChanged: (value) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateDescriptionEvent(value),
              );
              _updateComponent(); // This will be debounced
            },
            isEditing: state.isEditingDescription,
            isEnabled: state.isDescriptionEnabled,
            onEditTap: () {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                const SetEditingDescriptionEvent(true),
              );
            },
            onCancelEdit: () {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                const CancelEditDescriptionEvent(),
              );
            },
          ),
          if (state.isValidationPanelVisible) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  _buildValidationTypeSelector(state),
                  const Divider(height: 8, color: Color(0xFF4B5563)),
                  _buildValidationConfiguration(state),
                  const Divider(height: 8, color: Color(0xFF4B5563)),
                  _buildErrorMessageInput(state),
                ],
              ),
            ),
          ],
          _buildBottomControls(state),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return SharedFormBuilderWidgets.buildFormTypeQuestionHeader(
      questionInput: _buildOptimizedQuestionInput(),
      formTypeIcon: Icons.short_text,
      formTypeLabel: 'Short Answer',
      formTypeIconColor: Colors.orange,
      formTypeIconBackgroundColor: Colors.orange.withValues(alpha: 0.2),
      onImageTap: () => _showImageDialog(),
      onFormTypeTap: () => _showShortAnswerInfo(),
    );
  }

  Widget _buildOptimizedQuestionInput() {
    return TextField(
      controller: _questionController,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.3,
      ),
      decoration: const InputDecoration(
        hintText: 'Question',
        hintStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          fontStyle: FontStyle.italic,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (value) {
        context.read<ShortAnswerFormBuilderWidgetBloc>().add(
          UpdateQuestionEvent(value),
        );
        _updateComponent();
      },
      onEditingComplete: () {
        context.read<ShortAnswerFormBuilderWidgetBloc>().add(
          UpdateQuestionEvent(_questionController.text),
        );
        _updateComponent();
      },
    );
  }

  // Compact helpers for inline validation UI (dark theme, single column)
  Widget _buildCompactLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCompactDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF4B5563)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF374151),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: items,
          isExpanded: true,
          iconSize: 14,
        ),
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildValidationTypeSelector(
    ShortAnswerFormBuilderWidgetSuccess state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        _buildCompactLabel('Validation type'),
        _buildCompactDropdown<ShortAnswerValidationType>(
          value: state.validation.validationType,
          items: ShortAnswerValidationType.values
              .map(
                (type) => DropdownMenuItem<ShortAnswerValidationType>(
                  value: type,
                  child: Text(type.displayName),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateValidationTypeEvent(newValue),
              );
              _updateComponent();
            }
          },
        ),
      ],
    );
  }

  Widget _buildValidationConfiguration(
    ShortAnswerFormBuilderWidgetSuccess state,
  ) {
    switch (state.validation.validationType) {
      case ShortAnswerValidationType.number:
        return _buildNumberValidation(state);
      case ShortAnswerValidationType.text:
        return _buildTextValidation(state);
      case ShortAnswerValidationType.length:
        return _buildLengthValidation(state);
      case ShortAnswerValidationType.regularExpression:
        return _buildRegexValidation(state);
    }
  }

  Widget _buildNumberValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _buildCompactLabel('Action'),
        _buildCompactDropdown<NumberValidationAction>(
          value:
              state.validation.numberAction ??
              NumberValidationAction.greaterThan,
          items: NumberValidationAction.values
              .map(
                (action) => DropdownMenuItem<NumberValidationAction>(
                  value: action,
                  child: Text(action.displayName),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateNumberActionEvent(newValue),
              );
              _updateComponent();
            }
          },
        ),
        _buildCompactLabel('Number'),
        _buildCompactTextField(
          controller: _validationValueController,
          hintText: 'Enter number',
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(value),
            );
            _updateComponent();
          },
          onEditingComplete: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(_validationValueController.text),
            );
            _updateComponent();
          },
        ),
      ],
    );
  }

  Widget _buildTextValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _buildCompactLabel('Action'),
        _buildCompactDropdown<TextValidationAction>(
          value: state.validation.textAction ?? TextValidationAction.contains,
          items: TextValidationAction.values
              .map(
                (action) => DropdownMenuItem<TextValidationAction>(
                  value: action,
                  child: Text(action.displayName),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateTextActionEvent(newValue),
              );
              _updateComponent();
            }
          },
        ),
        _buildCompactLabel('Text'),
        _buildCompactTextField(
          controller: _validationValueController,
          hintText: 'Enter text',
          onSubmitted: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(value),
            );
            _updateComponent();
          },
          onEditingComplete: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(_validationValueController.text),
            );
            _updateComponent();
          },
        ),
      ],
    );
  }

  Widget _buildLengthValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _buildCompactLabel('Length type'),
        _buildCompactDropdown<LengthValidationType>(
          value:
              state.validation.lengthType ??
              LengthValidationType.minimumCharacterCount,
          items: LengthValidationType.values
              .map(
                (type) => DropdownMenuItem<LengthValidationType>(
                  value: type,
                  child: Text(type.displayName),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateLengthTypeEvent(newValue),
              );
              _updateComponent();
            }
          },
        ),
        _buildCompactLabel('Character count'),
        _buildCompactTextField(
          controller: _validationValueController,
          hintText: 'Enter number',
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(value),
            );
            _updateComponent();
          },
          onEditingComplete: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(_validationValueController.text),
            );
            _updateComponent();
          },
        ),
      ],
    );
  }

  Widget _buildRegexValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _buildCompactLabel('Action'),
        _buildCompactDropdown<RegexValidationAction>(
          value: state.validation.regexAction ?? RegexValidationAction.matches,
          items: RegexValidationAction.values
              .map(
                (action) => DropdownMenuItem<RegexValidationAction>(
                  value: action,
                  child: Text(action.displayName),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateRegexActionEvent(newValue),
              );
              _updateComponent();
            }
          },
        ),
        _buildCompactLabel('Regex pattern'),
        _buildCompactTextField(
          controller: _validationValueController,
          hintText: 'Enter regex pattern',
          onSubmitted: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(value),
            );
            _updateComponent();
          },
          onEditingComplete: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(_validationValueController.text),
            );
            _updateComponent();
          },
        ),
      ],
    );
  }

  Widget _buildErrorMessageInput(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        _buildCompactLabel('Custom error message'),
        _buildCompactTextField(
          controller: _errorMessageController,
          hintText: 'Enter custom error message',
          onSubmitted: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationErrorMessageEvent(value),
            );
            _updateComponent();
          },
          onEditingComplete: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationErrorMessageEvent(_errorMessageController.text),
            );
            _updateComponent();
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls(ShortAnswerFormBuilderWidgetSuccess state) {
    return SharedFormBuilderWidgets.buildCommonBottomControls(
      onDuplicate: widget.onDuplicate,
      onDelete: widget.onDelete,
      isRequired: state.isRequired,
      onRequiredChanged: (value) {
        context.read<ShortAnswerFormBuilderWidgetBloc>().add(
          UpdateRequiredEvent(value),
        );
        _updateComponent();
      },
      onDescriptionTap: () {
        if (!state.isDescriptionEnabled) {
          context.read<ShortAnswerFormBuilderWidgetBloc>().add(
            const ToggleDescriptionEnabledEvent(),
          );
        } else {
          context.read<ShortAnswerFormBuilderWidgetBloc>().add(
            const SetEditingDescriptionEvent(true),
          );
        }
      },
      onMoreOptions: () => _showMoreOptionsDialog(context),
    );
  }

  void _updateComponent() {
    // Cancel previous timer
    _updateTimer?.cancel();

    // Create a debounced update
    _updateTimer = Timer(const Duration(milliseconds: 300), () {
      final currentState = context
          .read<ShortAnswerFormBuilderWidgetBloc>()
          .state;
      if (currentState is ShortAnswerFormBuilderWidgetSuccess) {
        // Normalize validation so export JSON always contains action/value
        var normalizedValidation = currentState.validation;
        if (normalizedValidation.validationType ==
            ShortAnswerValidationType.number) {
          final hasValue =
              (normalizedValidation.validationValue != null &&
              normalizedValidation.validationValue!.toString().isNotEmpty);
          if (normalizedValidation.numberAction == null && hasValue) {
            normalizedValidation = normalizedValidation.copyWith(
              numberAction: NumberValidationAction.lessThan,
            );
          }
        }

        final updatedComponent = widget.component.copyWith(
          config: widget.component.config?.copyWith(
            label: currentState.question,
            description: currentState.description,
            isRequired: currentState.isRequired,
            validate: normalizedValidation.toJson(),
          ),
        );

        // Create a hash to check if component actually changed
        final newHash =
            '${currentState.question}_${currentState.description}_${currentState.isRequired}_${normalizedValidation.toJson()}';

        // Only update if component actually changed
        if (newHash != _lastUpdateHash) {
          _lastUpdateHash = newHash;
          debugPrint(
            '🔄 [ShortAnswerFormBuilderWidget] Updating component with debounce',
          );
          widget.onComponentUpdate(updatedComponent);
        } else {
          debugPrint(
            '⏭️ [ShortAnswerFormBuilderWidget] Skipping update - no changes detected',
          );
        }
      }
    });
  }

  void _showImageDialog() {
    // TODO: Implement image dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image dialog not implemented yet')),
    );
  }

  void _showShortAnswerInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Short Answer Form'),
        content: const Text(
          'Short Answer forms allow users to provide brief text responses with customizable validation rules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptionsDialog(BuildContext context) {
    final currentState = context.read<ShortAnswerFormBuilderWidgetBloc>().state;
    if (currentState is! ShortAnswerFormBuilderWidgetSuccess) return;

    SharedFormBuilderWidgets.showMoreOptionsBottomSheet(
      context: context,
      getOptions: () {
        final state =
            context.read<ShortAnswerFormBuilderWidgetBloc>().state
                as ShortAnswerFormBuilderWidgetSuccess;

        return SharedFormBuilderWidgets.getShortAnswerMoreOptions(
          onDescriptionTap: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              const SetEditingDescriptionEvent(true),
            );
          },
          onValidationTap: () {
            // show inline panel
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              const ToggleValidationPanelEvent(true),
            );
          },
          isValidationEnabled: state.isValidationPanelVisible,
          isDescriptionEnabled: state.isDescriptionEnabled,
          onValidationToggle: () {
            final newVisible = !state.isValidationPanelVisible;
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              ToggleValidationPanelEvent(newVisible),
            );
          },
          onDescriptionToggle: () {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              const ToggleDescriptionEnabledEvent(),
            );
          },
        );
      },
    );
  }
}
