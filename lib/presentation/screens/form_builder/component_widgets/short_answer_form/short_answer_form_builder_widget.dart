import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/shared_form_builder_widgets.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/shared_widgets/shared_optimized_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
// import 'dart:async';

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
  late TextEditingController _validationSecondValueController;
  late TextEditingController _errorMessageController;

  // Debounce removed; update instantly

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
    _validationSecondValueController = TextEditingController(
      text: '',
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
    _validationSecondValueController.dispose();
    _errorMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      ShortAnswerFormBuilderWidgetBloc,
      ShortAnswerFormBuilderWidgetState
    >(
      listener: (context, state) {
        // Clear description controller when description is cleared
        if (state is ShortAnswerFormBuilderWidgetSuccess &&
            state.description.isEmpty &&
            _descriptionController.text.isNotEmpty) {
          _descriptionController.clear();
        }
      },
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

  Widget _buildSuccessState(ShortAnswerFormBuilderWidgetSuccess state) {
    // Sync main controllers to prevent stale/empty values overwriting state after rebuilds
    if (_questionController.text != (state.question)) {
      _questionController.text = state.question;
    }
    if (_descriptionController.text != (state.description)) {
      _descriptionController.text = state.description;
    }

    // Keep controllers in sync with state to avoid stale values when switching
    final v = state.validation;
    if (_validationValueController.text != (v.validationValue ?? '')) {
      _validationValueController.text = v.validationValue ?? '';
    }
    if (_validationSecondValueController.text !=
        (v.validationSecondValue ?? '')) {
      _validationSecondValueController.text = v.validationSecondValue ?? '';
    }
    if (_errorMessageController.text != (v.errorMessage ?? '')) {
      _errorMessageController.text = v.errorMessage ?? '';
    }

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
            onClearDescription: () {
              // Clear description and uncheck description state
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                const ClearDescriptionEvent(),
              );
              _updateComponent();
            },
          ),
          if (state.isValidationPanelVisible) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  _buildValidationTypeSelector(state),
                  const Divider(
                    height: 6,
                    color: Color(0xFF4B5563),
                  ),
                  _buildValidationConfiguration(state),
                  const Divider(
                    height: 6,
                    color: Color(0xFF4B5563),
                  ),
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
    return SharedOptimizedInputWidgets.buildOptimizedQuestionInput(
      context: context,
      controller: _questionController,
      onUpdate: (value) {
        context.read<ShortAnswerFormBuilderWidgetBloc>().add(
          UpdateQuestionEvent(value),
        );
      },
      onUpdateComponent: _updateComponent,
    );
  }

  // Compact helpers for inline validation UI (dark theme, single column)
  Widget _buildCompactLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildValidationTypeSelector(
    ShortAnswerFormBuilderWidgetSuccess state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        _buildCompactLabel('Validation type'),
        SharedOptimizedInputWidgets.buildOptimizedCompactDropdown<
          ShortAnswerValidationType?
        >(
          value: state.validation.validationType,
          items: [
            // Add "No validation" option
            const DropdownMenuItem<ShortAnswerValidationType?>(
              value: null,
              child: Text('No validation'),
            ),
            // Add all validation types
            ...ShortAnswerValidationType.values.map(
              (type) => DropdownMenuItem<ShortAnswerValidationType?>(
                value: type,
                child: Text(type.displayName),
              ),
            ),
          ],
          onUpdate: (newValue) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationTypeEvent(newValue),
            );
          },
          context: context,
          onUpdateComponent: _updateComponent,
        ),
      ],
    );
  }

  Widget _buildValidationConfiguration(
    ShortAnswerFormBuilderWidgetSuccess state,
  ) {
    final validationType = state.validation.validationType;
    if (validationType == null) {
      return const SizedBox.shrink(); // No validation type selected
    }

    switch (validationType) {
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
      spacing: 3,
      children: [
        _buildCompactLabel('Action'),
        SharedOptimizedInputWidgets.buildOptimizedCompactDropdown<
          NumberValidationAction?
        >(
          value: state.validation.numberAction,
          items: [
            const DropdownMenuItem<NumberValidationAction?>(
              value: null,
              child: Text('Select action'),
            ),
            ...NumberValidationAction.values.map(
              (action) => DropdownMenuItem<NumberValidationAction?>(
                value: action,
                child: Text(action.displayName),
              ),
            ),
          ],
          onUpdate: (newValue) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateNumberActionEvent(newValue),
            );
          },
          context: context,
          onUpdateComponent: _updateComponent,
        ),
        if (state.validation.numberAction == NumberValidationAction.between ||
            state.validation.numberAction == NumberValidationAction.notBetween)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              _buildCompactLabel('From'),
              SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
                context: context,
                controller: _validationValueController,
                hintText: 'Enter start number',
                keyboardType: TextInputType.number,
                onUpdate: (value) {
                  context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                    UpdateValidationValueEvent(value),
                  );
                },
                onUpdateComponent: _updateComponent,
              ),
              _buildCompactLabel('To'),
              SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
                context: context,
                controller: _validationSecondValueController,
                hintText: 'Enter end number',
                keyboardType: TextInputType.number,
                onUpdate: (value) {
                  context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                    UpdateValidationSecondValueEvent(value),
                  );
                },
                onUpdateComponent: _updateComponent,
              ),
            ],
          )
        else if (state.validation.numberAction ==
            NumberValidationAction.wholeNumber)
          const SizedBox.shrink()
        else ...[
          _buildCompactLabel('Number'),
          SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
            context: context,
            controller: _validationValueController,
            hintText: 'Enter number',
            keyboardType: TextInputType.number,
            onUpdate: (value) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateValidationValueEvent(value),
              );
            },
            onUpdateComponent: _updateComponent,
          ),
        ],
      ],
    );
  }

  Widget _buildTextValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        _buildCompactLabel('Action'),
        SharedOptimizedInputWidgets.buildOptimizedCompactDropdown<
          TextValidationAction?
        >(
          value: state.validation.textAction,
          items: [
            const DropdownMenuItem<TextValidationAction?>(
              value: null,
              child: Text('Select action'),
            ),
            ...TextValidationAction.values.map(
              (action) => DropdownMenuItem<TextValidationAction?>(
                value: action,
                child: Text(action.displayName),
              ),
            ),
          ],
          onUpdate: (newValue) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateTextActionEvent(newValue),
            );
          },
          context: context,
          onUpdateComponent: _updateComponent,
        ),
        if (state.validation.textAction == TextValidationAction.contains ||
            state.validation.textAction ==
                TextValidationAction.doesNotContain) ...[
          _buildCompactLabel('Text'),
          SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
            context: context,
            controller: _validationValueController,
            hintText: 'Enter text',
            onUpdate: (value) {
              context.read<ShortAnswerFormBuilderWidgetBloc>().add(
                UpdateValidationValueEvent(value),
              );
            },
            onUpdateComponent: _updateComponent,
          ),
        ] else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildLengthValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        _buildCompactLabel('Length type'),
        SharedOptimizedInputWidgets.buildOptimizedCompactDropdown<
          LengthValidationType?
        >(
          value: state.validation.lengthType,
          items: [
            const DropdownMenuItem<LengthValidationType?>(
              value: null,
              child: Text('Select length type'),
            ),
            ...LengthValidationType.values.map(
              (type) => DropdownMenuItem<LengthValidationType?>(
                value: type,
                child: Text(type.displayName),
              ),
            ),
          ],
          onUpdate: (newValue) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateLengthTypeEvent(newValue),
            );
          },
          context: context,
          onUpdateComponent: _updateComponent,
        ),
        _buildCompactLabel('Character count'),
        SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
          context: context,
          controller: _validationValueController,
          hintText: 'Enter number',
          keyboardType: TextInputType.number,
          onUpdate: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(value),
            );
          },
          onUpdateComponent: _updateComponent,
        ),
      ],
    );
  }

  Widget _buildRegexValidation(ShortAnswerFormBuilderWidgetSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        _buildCompactLabel('Action'),
        SharedOptimizedInputWidgets.buildOptimizedCompactDropdown<
          RegexValidationAction?
        >(
          value: state.validation.regexAction,
          items: [
            const DropdownMenuItem<RegexValidationAction?>(
              value: null,
              child: Text('Select action'),
            ),
            ...RegexValidationAction.values.map(
              (action) => DropdownMenuItem<RegexValidationAction?>(
                value: action,
                child: Text(action.displayName),
              ),
            ),
          ],
          onUpdate: (newValue) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateRegexActionEvent(newValue),
            );
          },
          context: context,
          onUpdateComponent: _updateComponent,
        ),
        _buildCompactLabel('Regex pattern'),
        SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
          context: context,
          controller: _validationValueController,
          hintText: 'Enter regex pattern',
          onUpdate: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationValueEvent(value),
            );
          },
          onUpdateComponent: _updateComponent,
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
        SharedOptimizedInputWidgets.buildOptimizedCompactTextField(
          context: context,
          controller: _errorMessageController,
          hintText: 'Enter custom error message',
          onUpdate: (value) {
            context.read<ShortAnswerFormBuilderWidgetBloc>().add(
              UpdateValidationErrorMessageEvent(value),
            );
          },
          onUpdateComponent: _updateComponent,
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
    context.read<ShortAnswerFormBuilderWidgetBloc>().add(
      CommitComponentUpdateEvent(widget.onComponentUpdate),
    );
  }

  void _showImageDialog() {
    // TODO: Implement image dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image dialog not implemented yet')),
    );
  }

  void _showShortAnswerInfo() {
    SharedFormBuilderWidgets.showInfoDialog(
      context: context,
      title: 'Short Answer Component',
      description:
          'Short Answer forms allow users to provide brief text responses with customizable validation rules.',
      features: [
        'Text input with validation',
        'Customizable validation rules',
        'Number, text, length, and regex validation',
        'Required field validation',
        'Custom error messages',
        'Description support',
      ],
      icon: Icons.short_text,
      iconColor: Colors.orange,
      buttonText: 'Got it!',
      buttonColor: Colors.orange,
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
