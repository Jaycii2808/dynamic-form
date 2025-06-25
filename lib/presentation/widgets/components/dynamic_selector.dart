import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
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

    return _buildBody(style, config, selected, context, hasLabel);
  }

  Container _buildBody(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    selected,
    BuildContext context,
    bool hasLabel,
  ) {
    return Container(
      key: Key(widget.component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: GestureDetector(
        onTap: () {
          setState(() {
            config['selected'] = !selected;
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(componentId: widget.component.id, value: !selected),
            );
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selected ? 'assets/svg/Active.svg' : 'assets/svg/Inactive.svg',
              width: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
              height: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
            ),
            if (hasLabel)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  config['label'],
                  style: TextStyle(
                    fontSize: style['labelTextSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['labelColor']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
