import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_text_area/dynamic_text_area_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextArea extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic)? onComplete;
  final Function(DynamicFormModel)?
  onComponentUpdate; // Add callback for component updates
  final bool isSharedForm; // Add parameter to indicate shared form mode

  DynamicTextArea({
    super.key,
    required this.component,
    this.onComplete,
    this.onComponentUpdate, // Add this parameter
    this.isSharedForm = false, // Default to false for backward compatibility
  }) {
    debugPrint(
      '🏗️ [DynamicTextArea] Constructor called for component: ${component.id}',
    );
    debugPrint('  - Label: ${component.config?.label}');
    debugPrint('  - Placeholder: ${component.config?.placeholder}');
    debugPrint('  - Is shared form: $isSharedForm');
  }

  @override
  State<DynamicTextArea> createState() => _DynamicTextAreaState();
}

class _DynamicTextAreaState extends State<DynamicTextArea> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      '🚀 [DynamicTextArea] initState called for component: ${widget.component.id}',
    );
    debugPrint('  - Label: ${widget.component.config?.label}');
    debugPrint('  - Placeholder: ${widget.component.config?.placeholder}');
    debugPrint('  - Value: ${widget.component.config?.value}');
    context.read<DynamicTextAreaBloc>().add(const InitializeTextAreaEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormBuilderBloc, FormBuilderState>(
      listener: (context, formBuilderState) {
        if (formBuilderState is FormBuilderSuccess) {
          // Find updated component in the current page
          final updatedComponent = formBuilderState.canvasComponents
              .where((comp) => comp.id == widget.component.id)
              .firstOrNull;

          if (updatedComponent != null &&
              updatedComponent != widget.component) {
            debugPrint(
              '🔄 [DynamicTextArea] FormBuilder state changed, updating component: ${updatedComponent.id}',
            );
            debugPrint('  - Old Label: ${widget.component.config?.label}');
            debugPrint('  - New Label: ${updatedComponent.config?.label}');
            debugPrint(
              '  - Old Placeholder: ${widget.component.config?.placeholder}',
            );
            debugPrint(
              '  - New Placeholder: ${updatedComponent.config?.placeholder}',
            );
            debugPrint('  - Old Value: ${widget.component.config?.value}');
            debugPrint('  - New Value: ${updatedComponent.config?.value}');

            // Update the bloc with new component
            context.read<DynamicTextAreaBloc>().add(
              UpdateTextAreaFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicTextAreaBloc, DynamicTextAreaState>(
        listener: (context, state) {
          if (state is DynamicTextAreaSuccess) {
            final simpleValue =
                state.component?.config?.value?.toString() ?? '';
            widget.onComplete?.call(simpleValue);

            final textController = state.textController;
            if (textController != null) {
              final currentText = textController.text;
              final expectedText =
                  state.component?.config?.value?.toString() ?? '';
              if (currentText != expectedText) {
                textController.text = expectedText;
              }
            }
          } else if (state is DynamicTextAreaError) {
            final simpleValue =
                state.component?.config?.value?.toString() ?? '';
            widget.onComplete?.call(simpleValue);
            DialogUtils.showErrorDialog(context, state.errorMessage!);
          } else if (state is DynamicTextAreaInitial ||
              state is DynamicTextAreaLoading) {
            debugPrint(
              'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config!.value}',
            );
          } else {
            final simpleValue =
                state.component?.config?.value?.toString() ?? '';
            widget.onComplete?.call(simpleValue);
            DialogUtils.showErrorDialog(context, "Another Error");
          }
        },
        builder: (context, state) {
          if (state is DynamicTextAreaSuccess) {
            // Add null checks for all required properties
            if (state.styleModel == null ||
                state.inputConfig == null ||
                state.component == null ||
                state.formState == null ||
                state.textController == null ||
                state.focusNode == null) {
              debugPrint('DynamicTextArea: Some required properties are null');
              return const SizedBox.shrink();
            }

            return _buildBody(
              state.styleModel!,
              state.inputConfig!,
              state.component!,
              state.formState!,
              state.errorText,
              state.textController!,
              state.focusNode!,
              context,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(
    StyleModel styleModel,
    InputValidationModel inputConfig,
    DynamicFormModel component,
    StatesEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleModel, inputConfig, context),
          _buildTextField(
            styleModel: styleModel,
            inputConfig: inputConfig,
            component: component,
            currentState: StatesEnum.base,
            errorText: null,
            textController: textController,
            focusNode: focusNode,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    StyleModel styleModel,
    InputValidationModel inputConfig,
    BuildContext context,
  ) {
    // Use widget.component for the most up-to-date label
    final label = widget.component.config?.label ?? inputConfig.label ?? '';
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isRequired = widget.component.config?.isRequired == true;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: styleModel.labelTextSize,
                    color: styleModel.labelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          // Show edit icon in form builder mode (but not in shared form mode)
          if (widget.component.labelFormBuilder != null && !widget.isSharedForm)
            GestureDetector(
              onTap: () => _showEditLabelDialog(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color:
                      styleModel.labelColor?.withValues(alpha: 0.7) ??
                      Colors.grey.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditLabelDialog(BuildContext context) {
    final TextEditingController labelController = TextEditingController(
      text:
          widget.component.config?.label ??
          widget.component.labelFormBuilder ??
          '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Label'),
          content: TextField(
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the component config
                final updatedComponent = widget.component.copyWith(
                  config:
                      widget.component.config?.copyWith(
                        label: labelController.text,
                      ) ??
                      ConfigModel(label: labelController.text),
                  labelFormBuilder: labelController.text,
                );

                // Use callback to update component
                widget.onComponentUpdate?.call(updatedComponent);

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required StyleModel styleModel,
    required InputValidationModel inputConfig,
    required DynamicFormModel component,
    required StatesEnum currentState,
    required String? errorText,
    required TextEditingController textController,
    required FocusNode focusNode,
    required BuildContext context,
  }) {
    final StatesEnum stateKey = currentState;
    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
      component.states,
      stateKey,
    );
    final String? helperText = stateStyle?.helperText ?? styleModel.helperText;
    final Color? helperTextColor = stateStyle?.helperTextColor;

    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      onSubmitted: (value) {
        context.read<DynamicTextAreaBloc>().add(
          TextAreaFocusLostEvent(value: value),
        );
      },
      maxLines: styleModel.maxLines,
      minLines: styleModel.minLines,
      decoration: InputDecoration(
        isDense: true,
        hintText:
            widget.component.config?.placeholder ??
            inputConfig.placeholder ??
            '',
        border: _buildBorder(styleModel, currentState),
        enabledBorder: _buildBorder(styleModel, currentState),
        focusedBorder: _buildBorder(styleModel, StatesEnum.focused),
        errorBorder: _buildBorder(styleModel, StatesEnum.error),
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 12.0,
        ),

        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSize,
        color: stateStyle?.textColor ?? styleModel.textColor,
      ),
    );
  }

  OutlineInputBorder _buildBorder(
    StyleModel styleModel,
    StatesEnum state,
  ) {
    double width = styleModel.borderWidth ?? 1.0;
    Color color = styleModel.borderColor ?? Colors.grey;

    if (state == StatesEnum.focused) {
      width += 1;
      color = styleModel.focusedBorderColor ?? Colors.blue;
    } else if (state == StatesEnum.error) {
      color = styleModel.errorBorderColor ?? Colors.red;
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 4.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
