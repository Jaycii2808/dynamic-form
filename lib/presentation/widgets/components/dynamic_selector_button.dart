import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSelectorButton extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic)? onComplete;
  final Function(DynamicFormModel)?
  onComponentUpdate; // Add callback for component updates
  final bool isSharedForm; // Add parameter to indicate shared form mode

  DynamicSelectorButton({
    super.key,
    required this.component,
    this.onComplete,
    this.onComponentUpdate, // Add this parameter
    this.isSharedForm = false, // Default to false for backward compatibility
  }) {
    debugPrint(
      '🏗️ [DynamicSelectorButton] Constructor called for component: ${component.id}',
    );
    debugPrint('  - Label: ${component.config?.label}');
    debugPrint('  - Is shared form: $isSharedForm');
  }

  @override
  State<DynamicSelectorButton> createState() => _DynamicSelectorButtonState();
}

class _DynamicSelectorButtonState extends State<DynamicSelectorButton> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      '🚀 [DynamicSelectorButton] initState called for component: ${widget.component.id}',
    );
    debugPrint('  - Label: ${widget.component.config?.label}');
    debugPrint('  - Value: ${widget.component.config?.value}');
    context.read<DynamicSelectorButtonBloc>().add(
      const InitializeSelectorButtonEvent(),
    );
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
              '🔄 [DynamicSelectorButton] FormBuilder state changed, updating component: ${updatedComponent.id}',
            );
            debugPrint('  - Old Label: ${widget.component.config?.label}');
            debugPrint('  - New Label: ${updatedComponent.config?.label}');
            debugPrint('  - Old Value: ${widget.component.config?.value}');
            debugPrint('  - New Value: ${updatedComponent.config?.value}');

            // Update the bloc with new component
            context.read<DynamicSelectorButtonBloc>().add(
              UpdateSelectorButtonFromExternalEvent(
                component: updatedComponent,
              ),
            );
          }
        }
      },
      child: BlocConsumer<DynamicSelectorButtonBloc, DynamicSelectorButtonState>(
        listener: (context, state) {
          if (state is DynamicSelectorButtonSuccess) {
            // Pass simple value instead of valueMap
            final simpleValue = state.component?.config?.value ?? false;
            widget.onComplete?.call(simpleValue);
          } else if (state is DynamicSelectorButtonError) {
            DialogUtils.showErrorDialog(context, state.errorMessage!);
          } else if (state is DynamicSelectorButtonLoading ||
              state is DynamicSelectorButtonInitial) {
            debugPrint(
              'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
            );
          } else {
            // Pass simple value instead of valueMap
            final simpleValue = state.component?.config?.value ?? false;
            widget.onComplete?.call(simpleValue);
            DialogUtils.showErrorDialog(context, "Another Error");
          }
        },
        builder: (context, state) {
          if (state is DynamicSelectorButtonLoading ||
              state is DynamicSelectorButtonInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicSelectorButtonSuccess) {
            return _buildBody(
              context,
              state.styleModel!,
              state.inputConfig!,
              state.component!,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StyleModel styleModel,
    InputValidationModel inputConfig,
    DynamicFormModel component,
  ) {
    // Use widget.component for the most up-to-date values
    final config = widget.component.config;
    final hasLabel = config?.label != null && config!.label!.isNotEmpty;
    final selected = config?.selected == true || config?.value == true;
    final isDisabled = inputConfig.disabled;

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                context.read<DynamicSelectorButtonBloc>().add(
                  SelectorButtonToggledEvent(isSelected: !selected),
                );
              },
        child: Row(
          children: [
            Container(
              width: (styleModel.iconSize ?? 20.0) * 0.8,
              height: (styleModel.iconSize ?? 20.0) * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: styleModel.backgroundColor ?? Colors.transparent,
                border: Border.all(
                  color: styleModel.borderColor ?? Colors.grey,
                  width: (styleModel.borderWidth ?? 2.0) * 0.8,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: (styleModel.iconSize ?? 20.0) * 0.5,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (hasLabel)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                config.label ?? '',
                                style: TextStyle(
                                  fontSize:
                                      (styleModel.labelTextSize ?? 16) * 0.8,
                                  color: styleModel.labelColor ?? Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (widget.component.config?.isRequired == true)
                              const Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Show edit icon in form builder mode (but not in shared form mode)
                      if (widget.component.labelFormBuilder != null &&
                          !widget.isSharedForm)
                        GestureDetector(
                          onTap: () => _showEditLabelDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: (styleModel.labelColor ?? Colors.white)
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
}
