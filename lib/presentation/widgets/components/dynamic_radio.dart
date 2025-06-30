// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';

class DynamicRadio extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicRadio({super.key, required this.component});

  @override
  State<DynamicRadio> createState() => _DynamicRadioState();
}

class _DynamicRadioState extends State<DynamicRadio> {
  final FocusNode _focus_node = FocusNode();

  // Common utility function for mapping icon names to IconData
  IconData? _map_icon_name_to_icon_data(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        // Lấy component mới nhất từ state (theo id)
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // 1. Resolve styles from component's style and states
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        final bool is_selected = component.config['value'] == true;
        final bool is_editable =
            (component.config['is_editable'] != false) &&
            (component.config['disabled'] != true);

        // Apply state-specific styles
        String current_state = is_selected ? 'selected' : 'base';
        if (!is_editable) {
          // For disabled items, we don't use states, we just use the styles defined directly on the component.
        } else if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) {
            style.addAll(state_style);
          }
        }

        // 2. Extract configuration
        final String? label = component.config['label'];
        final String? hint = component.config['hint'];
        final String? icon_name = component.config['icon'];
        final IconData? leading_icon_data = icon_name != null
            ? _map_icon_name_to_icon_data(icon_name)
            : null;
        final String? group = component.config['group'];

        // 3. Define visual properties based on style
        final Color background_color = StyleUtils.parseColor(
          style['background_color'],
        );
        final Color border_color = StyleUtils.parseColor(style['border_color']);
        final double border_width =
            (style['border_width'] as num?)?.toDouble() ?? 1.0;
        final Color icon_color = StyleUtils.parseColor(style['icon_color']);
        final double control_width = (style['width'] as num?)?.toDouble() ?? 28;
        final double control_height =
            (style['height'] as num?)?.toDouble() ?? 28;

        final control_border_radius =
            control_width / 2; // Always circular for radio

        debugPrint(
          '[Radio][build] id=${component.id} value=$is_selected state=$current_state',
        );
        debugPrint('[Radio][build] style=${style.toString()}');
        debugPrint(
          '[Radio][build] icon_color=$icon_color, background_color=$background_color, border_color=$border_color',
        );

        // 4. Build the toggle control (the radio button itself)
        Widget toggle_control = Container(
          width: control_width,
          height: control_height,
          decoration: BoxDecoration(
            color: background_color,
            border: Border.all(color: border_color, width: border_width),
            borderRadius: BorderRadius.circular(control_border_radius),
          ),
          child: is_selected
              ? Center(
                  child: Container(
                    width: control_width * 0.5,
                    height: control_height * 0.5,
                    decoration: BoxDecoration(
                      color: icon_color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        );

        // 5. Build the label and hint text column
        Widget? label_and_hint;
        if (label != null) {
          label_and_hint = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: style['label_text_size']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['label_color']),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: StyleUtils.parseColor(style['hint_color']),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          );
        }

        // 6. Handle tap gestures
        void handle_tap() {
          FocusScope.of(context).requestFocus(_focus_node);
          if (!is_editable) return;

          debugPrint(
            '[Radio][tap] id=${component.id} value_before=$is_selected',
          );
          //final newValue = !is_selected;

          // Logic to unselect other radios in the same group
          if (group != null) {
            // Find all siblings in the same group and unselect them
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(componentId: component.id, value: true),
            );
            debugPrint('[Radio][tap] id=${component.id} value_after=true');
            debugPrint('[Radio] Save value: ${component.id} = true');
          } else {
            // If no explicit group, treat it as a single radio button (not common)
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(componentId: component.id, value: true),
            );
            debugPrint('[Radio][tap] id=${component.id} value_after=true');
            debugPrint('[Radio] Save value: ${component.id} = true');
          }
        }

        // 7. Assemble the final widget
        return Focus(
          focusNode: _focus_node,
          child: GestureDetector(
            onTap: handle_tap,
            child: Container(
              key: Key(component.id),
              margin: StyleUtils.parsePadding(style['margin']),
              padding: StyleUtils.parsePadding(style['padding']),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  toggle_control,
                  const SizedBox(width: 12),
                  if (leading_icon_data != null) ...[
                    Icon(
                      leading_icon_data,
                      size: 20,
                      color: StyleUtils.parseColor(style['icon_color']),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (label_and_hint != null) label_and_hint,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focus_node.dispose();
    super.dispose();
  }
}
