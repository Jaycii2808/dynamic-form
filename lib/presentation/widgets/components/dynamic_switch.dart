import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_switch/dynamic_switch_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_switch/dynamic_switch_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_switch/dynamic_switch_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSwitch extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;
  final Function(DynamicFormModel)?
  onComponentUpdate; // Add callback for component updates

  DynamicSwitch({
    super.key,
    required this.component,
    required this.onComplete,
    this.onComponentUpdate, // Add this parameter
  }) {
    debugPrint(
      '🏗️ [DynamicSwitch] Constructor called for component: ${component.id}',
    );
    debugPrint('  - Label: ${component.config?.label}');
    debugPrint('  - Value: ${component.config?.value}');
  }

  @override
  State<DynamicSwitch> createState() => _DynamicSwitchState();
}

class _DynamicSwitchState extends State<DynamicSwitch> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      '🚀 [DynamicSwitch] initState called for component: ${widget.component.id}',
    );
    debugPrint('  - Label: ${widget.component.config?.label}');
    debugPrint('  - Value: ${widget.component.config?.value}');
    context.read<DynamicSwitchBloc>().add(const InitializeSwitchEvent());
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
              '🔄 [DynamicSwitch] FormBuilder state changed, updating component: ${updatedComponent.id}',
            );
            debugPrint('  - Old Label: ${widget.component.config?.label}');
            debugPrint('  - New Label: ${updatedComponent.config?.label}');
            debugPrint('  - Old Value: ${widget.component.config?.value}');
            debugPrint('  - New Value: ${updatedComponent.config?.value}');

            // Update the bloc with new component
            context.read<DynamicSwitchBloc>().add(
              UpdateSwitchFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicSwitchBloc, DynamicSwitchState>(
        listener: (context, state) {
          if (state is DynamicSwitchSuccess) {
            // Pass simple value instead of valueMap
            final simpleValue = state.component?.config?.value ?? false;
            widget.onComplete(simpleValue);
          } else if (state is DynamicSwitchError) {
            DialogUtils.showErrorDialog(context, state.errorMessage!);
          } else if (state is DynamicSwitchLoading ||
              state is DynamicSwitchInitial) {
            debugPrint(
              'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
            );
          } else {
            // Pass simple value instead of valueMap
            final simpleValue = state.component?.config?.value ?? false;
            widget.onComplete(simpleValue);
            DialogUtils.showErrorDialog(context, "Another Error");
          }
        },
        builder: (context, state) {
          if (state is DynamicSwitchLoading || state is DynamicSwitchInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicSwitchSuccess) {
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
    final isSelected = config?.selected == true || config?.value == true;
    final isDisabled = inputConfig.disabled;

    final activeColor = styleModel.activeColor ?? Colors.blue;
    final inactiveThumbColor = styleModel.inactiveColor ?? Colors.grey;
    final inactiveTrackColor =
        styleModel.inactiveTrackColor ?? Colors.grey[300]!;

    return Container(
      key: ValueKey(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                    // Show edit icon in form builder mode
                    if (widget.component.labelFormBuilder != null)
                      GestureDetector(
                        onTap: () => _showEditLabelDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: (styleModel.labelColor ?? Colors.white)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isSelected,
              onChanged: isDisabled
                  ? null
                  : (bool value) {
                      context.read<DynamicSwitchBloc>().add(
                        SwitchToggledEvent(value: value),
                      );
                    },
              activeColor: activeColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
}
