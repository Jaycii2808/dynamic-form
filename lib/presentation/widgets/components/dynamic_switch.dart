import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  @override
  Widget build(BuildContext context) {
    final style = Map<String, dynamic>.from(widget.component.style);
    final config = widget.component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final selected = config['selected'] ?? false;

    // Apply variant styles
    if (widget.component.variants != null) {
      if (hasLabel && widget.component.variants!.containsKey('withLabel')) {
        final variantStyle =
            widget.component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (!hasLabel && widget.component.variants!.containsKey('withoutLabel')) {
        final variantStyle =
            widget.component.variants!['withoutLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    if (selected) currentState = 'success';

    if (widget.component.states != null && widget.component.states!.containsKey(currentState)) {
      final stateStyle = widget.component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Switch colors
    final activeColor = StyleUtils.parseColor(style['activeColor'] ?? '#6979F8');
    final inactiveThumbColor = StyleUtils.parseColor(style['inactiveColor'] ?? '#CCCCCC');
    final inactiveTrackColor = StyleUtils.parseColor(style['inactiveColor'] ?? '#E5E5E5');

    return _buildBody(
      style,
      selected,
      config,
      context,
      activeColor,
      inactiveThumbColor,
      inactiveTrackColor,
      hasLabel,
    );
  }

  Container _buildBody(
    Map<String, dynamic> style,
    selected,
    Map<String, dynamic> config,
    BuildContext context,
    Color activeColor,
    Color inactiveThumbColor,
    Color inactiveTrackColor,
    bool hasLabel,
  ) {
    return Container(
      key: ValueKey(widget.component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: selected,
            onChanged: (bool value) {
              setState(() {
                config['selected'] = value;
                context.read<DynamicFormBloc>().add(
                  UpdateFormFieldEvent(componentId: widget.component.id, value: value),
                );
              });
            },
            activeColor: activeColor,
            inactiveThumbColor: inactiveThumbColor,
            inactiveTrackColor: inactiveTrackColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (hasLabel)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                config['label'],
                style: TextStyle(
                  fontSize: style['textSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['color'] ?? '#6979F8'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
