// ignore_for_file: non_constant_identifier_names

//import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';

class DynamicCheckbox extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicCheckbox({super.key, required this.component});

  @override
  State<DynamicCheckbox> createState() => _DynamicCheckboxState();
}

class _DynamicCheckboxState extends State<DynamicCheckbox> {
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

        final bool is_selected = component.config['value'] == true;
        final bool is_editable =
            (component.config['editable'] != false) &&
            (component.config['disabled'] != true);
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        String current_state = is_selected ? 'selected' : 'base';
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) style.addAll(state_style);
        }

        final String? label = component.config['label'];
        final String? hint = component.config['hint'];
        final String? icon_name = component.config['icon'];
        final IconData? leading_icon_data = icon_name != null
            ? _map_icon_name_to_icon_data(icon_name)
            : null;

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
        final control_border_radius = (StyleUtils.parseBorderRadius(
          style['border_radius'],
        ).resolve(TextDirection.ltr).topLeft.x);

        debugPrint(
          '[Checkbox][build] id=${component.id} value=$is_selected state=$current_state',
        );
        debugPrint('[Checkbox][build] style=${style.toString()}');
        debugPrint(
          '[Checkbox][build] icon_color=$icon_color, background_color=$background_color, border_color=$border_color',
        );

        Widget toggle_control = Container(
          width: control_width,
          height: control_height,
          decoration: BoxDecoration(
            color: background_color,
            border: Border.all(color: border_color, width: border_width),
            borderRadius: BorderRadius.circular(control_border_radius),
          ),
          child: is_selected
              ? Icon(Icons.check, color: icon_color, size: control_width * 0.75)
              : null,
        );

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

        void handle_tap() {
          FocusScope.of(context).requestFocus(_focus_node);
          if (!is_editable) return;
          debugPrint(
            '[Checkbox][tap] id=${component.id} value_before=$is_selected',
          );
          final new_value = !is_selected;
          context.read<DynamicFormBloc>().add(
            UpdateFormFieldEvent(componentId: component.id, value: new_value),
          );
          debugPrint(
            '[Checkbox][tap] id=${component.id} value_after=$new_value',
          );
          debugPrint('[Checkbox] Save value: ${component.id} = $new_value');
        }

        return Focus(
          focusNode: _focus_node,
          child: GestureDetector(
            onTap: handle_tap,
            child: Container(
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
