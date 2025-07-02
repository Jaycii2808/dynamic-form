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
  final FocusNode focusNode = FocusNode();

  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        final bool isSelected = component.config['value'] == true;
        final bool isEditable =
            (component.config['editable'] != false) &&
            (component.config['disabled'] != true);
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        String currentState = isSelected ? 'selected' : 'base';
        if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }

        final String? label = component.config['label'];
        final String? hint = component.config['hint'];
        final String? iconName = component.config['icon'];
        final IconData? leadingIconData = iconName != null
            ? mapIconNameToIconData(iconName)
            : null;

        final Color backgroundColor = StyleUtils.parseColor(
          style['background_color'],
        );
        final Color borderColor = StyleUtils.parseColor(style['border_color']);
        final double borderWidth =
            (style['border_width'] as num?)?.toDouble() ?? 1.0;
        final Color iconColor = StyleUtils.parseColor(style['icon_color']);
        final double controlWidth = (style['width'] as num?)?.toDouble() ?? 28;
        final double controlHeight =
            (style['height'] as num?)?.toDouble() ?? 28;
        final controlBorderRadius = (StyleUtils.parseBorderRadius(
          style['border_radius'],
        ).resolve(TextDirection.ltr).topLeft.x);

        debugPrint(
          '[Checkbox][build] id=${component.id} value=$isSelected state=$currentState',
        );
        debugPrint('[Checkbox][build] style=${style.toString()}');
        debugPrint(
          '[Checkbox][build] iconColor=$iconColor, backgroundColor=$backgroundColor, borderColor=$borderColor',
        );

        Widget toggleControl = Container(
          width: controlWidth,
          height: controlHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(controlBorderRadius),
          ),
          child: isSelected
              ? Icon(Icons.check, color: iconColor, size: controlWidth * 0.75)
              : null,
        );

        Widget? labelAndHint;
        if (label != null) {
          labelAndHint = Expanded(
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

        void handleTap() {
          FocusScope.of(context).requestFocus(focusNode);
          if (!isEditable) return;
          debugPrint(
            '[Checkbox][tap] id=${component.id} valueBefore=$isSelected',
          );
          final newValue = !isSelected;
          context.read<DynamicFormBloc>().add(
            UpdateFormFieldEvent(componentId: component.id, value: newValue),
          );
          debugPrint('[Checkbox][tap] id=${component.id} valueAfter=$newValue');
          debugPrint('[Checkbox] Save value: ${component.id} = $newValue');
        }

        return Focus(
          focusNode: focusNode,
          child: GestureDetector(
            onTap: handleTap,
            child: Container(
              margin: StyleUtils.parsePadding(style['margin']),
              padding: StyleUtils.parsePadding(style['padding']),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  toggleControl,
                  const SizedBox(width: 12),
                  if (leadingIconData != null) ...[
                    Icon(
                      leadingIconData,
                      size: 20,
                      color: StyleUtils.parseColor(style['icon_color']),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (labelAndHint != null) labelAndHint,
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
    focusNode.dispose();
    super.dispose();
  }
}
