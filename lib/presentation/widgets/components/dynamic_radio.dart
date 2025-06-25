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
  // Common utility function for mapping icon names to IconData
  IconData? _mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        // Lấy component mới nhất từ state (theo id)
        final component =
            (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // 1. Resolve styles from component's style and states
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        final bool isSelected = component.config['value'] == true;
        final bool isEditable = component.config['editable'] != false;

        // Apply state-specific styles
        String currentState = isSelected ? 'selected' : 'base';
        if (!isEditable) {
          // For disabled items, we don't use states, we just use the styles defined directly on the component.
        } else if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) {
            style.addAll(stateStyle);
          }
        }

        // 2. Extract configuration
        final String? label = component.config['label'];
        final String? hint = component.config['hint'];
        final String? iconName = component.config['icon'];
        final IconData? leadingIconData = iconName != null
            ? _mapIconNameToIconData(iconName)
            : null;
        final String? group = component.config['group'];

        // 3. Define visual properties based on style
        final Color backgroundColor = StyleUtils.parseColor(
          style['backgroundColor'],
        );
        final Color borderColor = StyleUtils.parseColor(style['borderColor']);
        final double borderWidth =
            (style['borderWidth'] as num?)?.toDouble() ?? 1.0;
        final Color iconColor = StyleUtils.parseColor(style['iconColor']);
        final double controlWidth = (style['width'] as num?)?.toDouble() ?? 28;
        final double controlHeight =
            (style['height'] as num?)?.toDouble() ?? 28;

        final controlBorderRadius =
            controlWidth / 2; // Always circular for radio

        debugPrint(
          '[Radio][build] id=${component.id} value=$isSelected state=$currentState',
        );
        debugPrint('[Radio][build] style=${style.toString()}');
        debugPrint(
          '[Radio][build] iconColor=$iconColor, backgroundColor=$backgroundColor, borderColor=$borderColor',
        );

        // 4. Build the toggle control (the radio button itself)
        Widget toggleControl = Container(
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

        // 5. Build the label and hint text column
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
                    fontSize: style['labelTextSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['labelColor']),
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
                        color: StyleUtils.parseColor(style['hintColor']),
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
        void handleTap() {
          if (!isEditable) return;

          debugPrint(
            '[Radio][tap] id=${component.id} value_before=$isSelected',
          );
          //final newValue = !isSelected;

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
        return GestureDetector(
          onTap: handleTap,
          child: Container(
            key: Key(component.id), // Added Key for consistency
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
                    color: StyleUtils.parseColor(style['iconColor']),
                  ),
                  const SizedBox(width: 8),
                ],
                if (labelAndHint != null) labelAndHint,
              ],
            ),
          ),
        );
      },
    );
  }
}
