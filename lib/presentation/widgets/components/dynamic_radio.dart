// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_radio/dynamic_radio_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_radio/dynamic_radio_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_radio/dynamic_radio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicRadio extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicRadio({super.key, required this.component});

  @override
  State<DynamicRadio> createState() => _DynamicRadioState();
}

class _DynamicRadioState extends State<DynamicRadio> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DynamicRadioBloc(initialComponent: widget.component),
      child: DynamicRadioWidget(component: widget.component),
    );
  }
}

class DynamicRadioWidget extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicRadioWidget({
    super.key,
    required this.component,
  });

  @override
  State<DynamicRadioWidget> createState() => _DynamicRadioWidgetState();
}

class _DynamicRadioWidgetState extends State<DynamicRadioWidget> {
  @override
  void initState() {
    super.initState();
    context.read<DynamicRadioBloc>().add(const InitializeRadioEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update radio bloc
        if (formState.page?.components != null) {
          final updatedComponent = formState.page!.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          // Check if component state changed from external source
          if (updatedComponent.config['current_state'] != null &&
              updatedComponent.config['current_state'] !=
                  widget.component.config['current_state']) {
            debugPrint(
              '🔄 [Radio] External state change detected: ${updatedComponent.config['current_state']}',
            );

            // Update the radio bloc with new component state
            context.read<DynamicRadioBloc>().add(
              UpdateRadioFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicRadioBloc, DynamicRadioState>(
        listenWhen: (previous, current) {
          return previous is DynamicRadioLoading &&
              current is DynamicRadioSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state, error, or form state changes
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              previous.component?.config['current_state'] !=
                  current.component?.config['current_state'] ||
              previous.component?.config['value'] !=
                  current.component?.config['value'];
        },
        listener: (context, state) {
          if (state is DynamicRadioSuccess) {
            final valueMap = {
              ValueKeyEnum.value.key:
                  state.component!.config[ValueKeyEnum.value.key],
              'current_state': state.component!.config['current_state'],
              'error_text': state.errorText,
            };

            // Update the main form bloc with new value
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: valueMap,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [Radio] Building with state: ${state.runtimeType}, formState: ${state.formState}, errorText: ${state.errorText}',
          );

          if (state is DynamicRadioLoading || state is DynamicRadioInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicRadioError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicRadioSuccess) {
            debugPrint(
              '🎯 [Radio] Success state - formState: ${state.formState}, currentState: ${state.component?.config['current_state']}',
            );
            return _buildRadioBody(
              state.styleConfig!,
              state.inputConfig!,
              state.component!,
              state.formState!,
              state.errorText,
              state.focusNode!,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRadioBody(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
    String? errorText,
    FocusNode focusNode,
  ) {
    // Get current value - pure data access, no logic
    final isSelected = component.config['value'] == true;
    final isEditable = inputConfig.editable && !inputConfig.disabled;

    return Container(
      key: Key(component.id),
      margin: styleConfig.margin,
      padding: styleConfig.padding,
      child: Focus(
        focusNode: focusNode,
        child: GestureDetector(
          onTap: () => _handleRadioTap(isEditable),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRadioControl(component, currentState, isSelected),
              const SizedBox(width: 12),
              ..._buildLabelAndIcon(component, inputConfig),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioControl(
    DynamicFormModel component,
    FormStateEnum currentState,
    bool isSelected,
  ) {
    // Get state-specific style
    final style = _getStateStyle(component, currentState);

    final controlWidth = (style['width'] as num?)?.toDouble() ?? 28.0;
    final controlHeight = (style['height'] as num?)?.toDouble() ?? 28.0;
    final backgroundColor = StyleUtils.parseColor(style['background_color']);
    final borderColor = StyleUtils.parseColor(style['border_color']);
    final borderWidth = (style['border_width'] as num?)?.toDouble() ?? 1.0;
    final iconColor = StyleUtils.parseColor(style['icon_color']);
    final controlBorderRadius = controlWidth / 2; // Always circular for radio

    return Container(
      width: controlWidth,
      height: controlHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(controlBorderRadius),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: controlWidth * 0.5,
                height: controlHeight * 0.5,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  List<Widget> _buildLabelAndIcon(
    DynamicFormModel component,
    InputConfig inputConfig,
  ) {
    List<Widget> widgets = [];

    // Add icon if available
    final iconName = component.config['icon'];
    if (iconName != null) {
      final iconData = IconTypeEnum.fromString(iconName).toIconData();
      if (iconData != null) {
        widgets.addAll([
          Icon(
            iconData,
            size: 20,
            color: StyleUtils.parseColor(component.style['icon_color']),
          ),
          const SizedBox(width: 8),
        ]);
      }
    }

    // Add label if available
    if (inputConfig.label != null && inputConfig.label!.isNotEmpty) {
      widgets.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                inputConfig.label!,
                style: TextStyle(
                  fontSize:
                      component.style['label_text_size']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(component.style['label_color']),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              ..._buildHintText(component),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Map<String, dynamic> _getStateStyle(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

    // Determine state key based on validation state and selection
    String stateKey = 'base';
    if (component.config['current_state'] != null) {
      stateKey = component.config['current_state'];
    } else if (component.config['value'] == true) {
      stateKey = 'selected';
    }

    // Apply state-specific styles from remote config
    if (component.states != null && component.states!.containsKey(stateKey)) {
      final stateStyle =
          component.states![stateKey]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) {
        style.addAll(stateStyle);
      }
    }

    return style;
  }

  List<Widget> _buildHintText(DynamicFormModel component) {
    final hint = component.config['hint'];
    if (hint != null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: StyleUtils.parseColor(component.style['hint_color']),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ];
    }
    return [];
  }

  void _handleRadioTap(bool isEditable) {
    if (!isEditable) return;

    debugPrint('[Radio][tap] Tapping radio button');

    // For radio buttons, always set to true when tapped
    context.read<DynamicRadioBloc>().add(
      const RadioValueChangedEvent(value: true),
    );
  }
}
