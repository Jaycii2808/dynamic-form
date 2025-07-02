// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';

class DynamicSwitch extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSwitch({super.key, required this.component});

  @override
  State<DynamicSwitch> createState() => _DynamicSwitchState();
}

class _DynamicSwitchState extends State<DynamicSwitch> {
  @override
  void dispose() {
    super.dispose();
  }

  void _handle_switch_change(bool new_value, DynamicFormModel component) {
    final current_value = component.config['selected'] ?? false;

    // Only update if value actually changed
    if (current_value != new_value) {
      debugPrint(
        '🔄 [${component.id}] Switch changing: $current_value → $new_value',
      );

      // Use centralized field update data creation with boolean value
      final updateData = ValidationUtils.createFieldUpdateData(
        value: new_value,
        selected: new_value,
      );

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(componentId: component.id, value: updateData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        // Get the latest component from BLoC state
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Get dynamic state
        final current_state = component.config['current_state'] ?? 'base';
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

        final config = component.config;
        final has_label = config['label'] != null && config['label'].isNotEmpty;
        final has_checked_icon =
            config['checked_icon'] != null && config['checked_icon'].isNotEmpty;
        final selected = config['selected'] ?? config['value'] ?? false;
        final is_disabled = config['disabled'] == true;

        debugPrint(
          '🔍 [${component.id}] selected from config: $selected, current_state: $current_state',
        );

        // Apply variant styles
        if (component.variants != null) {
          if (has_label && component.variants!.containsKey('with_label')) {
            final variant_style =
                component.variants!['with_label']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) {
              debugPrint(
                '🎨 [${component.id}] Applying with_label variant: $variant_style',
              );
              style.addAll(variant_style);
            }
          }
          if (!has_label && component.variants!.containsKey('without_label')) {
            final variant_style =
                component.variants!['without_label']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          // Backward compatibility with camelCase variants
          if (has_label && component.variants!.containsKey('withLabel')) {
            final variant_style =
                component.variants!['withLabel']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (!has_label && component.variants!.containsKey('withoutLabel')) {
            final variant_style =
                component.variants!['withoutLabel']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
        }

        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) {
            debugPrint(
              '🎨 [${component.id}] Applying $current_state state: $state_style',
            );
            style.addAll(state_style);
          }
        }

        // Switch colors with snake_case and camelCase support
        final active_color = StyleUtils.parseColor(
          style['active_color'] ?? style['activeColor'] ?? '#6979F8',
        );
        final inactive_thumb_color = StyleUtils.parseColor(
          style['inactive_color'] ?? style['inactiveColor'] ?? '#CCCCCC',
        );
        final inactive_track_color = StyleUtils.parseColor(
          style['inactive_track_color'] ??
              style['inactiveTrackColor'] ??
              '#E5E5E5',
        );

        return _build_body(
          style,
          selected,
          config,
          context,
          active_color,
          inactive_thumb_color,
          inactive_track_color,
          has_label,
          has_checked_icon,
          is_disabled,
          component,
        );
      },
    );
  }

  Container _build_body(
    Map<String, dynamic> style,
    selected,
    Map<String, dynamic> config,
    BuildContext context,
    Color active_color,
    Color inactive_thumb_color,
    Color inactive_track_color,
    bool has_label,
    bool has_checked_icon,
    bool is_disabled,
    DynamicFormModel component,
  ) {
    return Container(
      key: ValueKey(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: selected,
            onChanged: is_disabled
                ? null
                : (bool value) {
                    _handle_switch_change(value, component);
                  },
            activeColor: active_color,
            inactiveThumbColor: inactive_thumb_color,
            inactiveTrackColor: inactive_track_color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (has_label)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                config['label'],
                style: TextStyle(
                  fontSize:
                      (style['label_text_size'] ?? style['textSize'])
                          ?.toDouble() ??
                      16,
                  color: StyleUtils.parseColor(
                    style['label_color'] ?? style['color'] ?? '#6979F8',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
