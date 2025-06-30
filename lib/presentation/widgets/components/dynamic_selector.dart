// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DynamicSelector extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSelector({super.key, required this.component});

  @override
  State<DynamicSelector> createState() => _DynamicSelectorState();
}

class _DynamicSelectorState extends State<DynamicSelector> {
  @override
  void dispose() {
    super.dispose();
  }

  void _handle_selection_change(bool new_selected, DynamicFormModel component) {
    final current_selected = component.config['selected'] ?? false;

    // Only update if value actually changed
    if (current_selected != new_selected) {
      String new_state = 'base';
      if (new_selected) {
        new_state = 'success';
      }

      debugPrint(
        '🔄 [${component.id}] Selection changing: $current_selected → $new_selected',
      );

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: component.id,
          value: {
            'value': new_selected,
            'selected': new_selected,
            'current_state': new_state,
          },
        ),
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
        final selected = config['selected'] ?? false;
        final is_disabled = config['disabled'] == true;
        final value = component.config['value']?.toString() ?? '';

        debugPrint(
          '🔍 [${component.id}] selected from config: $selected, value: $value, current_state: $current_state',
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

        return _build_body(
          style,
          config,
          selected,
          context,
          has_label,
          is_disabled,
          component,
        );
      },
    );
  }

  Widget _build_body(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    bool selected,
    BuildContext context,
    bool has_label,
    bool is_disabled,
    DynamicFormModel component,
  ) {
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: GestureDetector(
        onTap: is_disabled
            ? null
            : () {
                _handle_selection_change(!selected, component);
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Create styled container for the selector circle
            Container(
              width: (style['icon_size'] as num?)?.toDouble() ?? 20.0,
              height: (style['icon_size'] as num?)?.toDouble() ?? 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StyleUtils.parseColor(style['background_color']),
                border: Border.all(
                  color: StyleUtils.parseColor(style['border_color']),
                  width: (style['border_width'] as num?)?.toDouble() ?? 2.0,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size:
                          ((style['icon_size'] as num?)?.toDouble() ?? 20.0) *
                          0.6,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (has_label)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  config['label'],
                  style: TextStyle(
                    fontSize: style['label_text_size']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['label_color']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
