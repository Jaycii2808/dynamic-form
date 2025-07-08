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
  final FocusNode focusNode = FocusNode();

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String _currentState = 'base';
  Map<String, dynamic> _style = {};
  bool _isSelected = false;
  bool _isEditable = true;
  IconData? _leadingIconData;
  Widget? _toggleControl;
  Widget? _labelAndHint;

  // Computed style values
  Color _backgroundColor = Colors.transparent;
  Color _borderColor = Colors.grey;
  double _borderWidth = 1.0;
  Color _iconColor = Colors.black;
  double _controlWidth = 28.0;
  double _controlHeight = 28.0;
  double _controlBorderRadius = 14.0;

  @override
  void initState() {
    super.initState();

    // Initialize with widget component
    _currentComponent = widget.component;
    _computeValues();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _computeValues() {
    _isSelected = _currentComponent.config['value'] == true;
    _isEditable =
        (_currentComponent.config['is_editable'] != false) &&
        (_currentComponent.config['disabled'] != true);

    _currentState = _isSelected ? 'selected' : 'base';

    _computeStyles();
    _computeIconData();
    _computeStyleValues();
    _computeToggleControl();
    _computeLabelAndHint();

    debugPrint(
      '[Radio][_computeValues] id=${_currentComponent.id} value=$_isSelected state=$_currentState',
    );
    debugPrint('[Radio][_computeValues] style=${_style.toString()}');
    debugPrint(
      '[Radio][_computeValues] iconColor=$_iconColor, backgroundColor=$_backgroundColor, borderColor=$_borderColor',
    );
  }

  void _computeStyles() {
    _style = Map<String, dynamic>.from(_currentComponent.style);

    // Apply state-specific styles
    if (!_isEditable) {
      // For disabled items, we don't use states, we just use the styles defined directly on the component.
    } else if (_currentComponent.states != null &&
        _currentComponent.states!.containsKey(_currentState)) {
      final stateStyle =
          _currentComponent.states![_currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) {
        _style.addAll(stateStyle);
      }
    }
  }

  void _computeIconData() {
    final String? iconName = _currentComponent.config['icon'];
    _leadingIconData = iconName != null
        ? mapIconNameToIconData(iconName)
        : null;
  }

  void _computeStyleValues() {
    _backgroundColor = StyleUtils.parseColor(_style['background_color']);
    _borderColor = StyleUtils.parseColor(_style['border_color']);
    _borderWidth = (_style['border_width'] as num?)?.toDouble() ?? 1.0;
    _iconColor = StyleUtils.parseColor(_style['icon_color']);
    _controlWidth = (_style['width'] as num?)?.toDouble() ?? 28;
    _controlHeight = (_style['height'] as num?)?.toDouble() ?? 28;
    _controlBorderRadius = _controlWidth / 2; // Always circular for radio
  }

  void _computeToggleControl() {
    _toggleControl = Container(
      width: _controlWidth,
      height: _controlHeight,
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: _borderColor, width: _borderWidth),
        borderRadius: BorderRadius.circular(_controlBorderRadius),
      ),
      child: _isSelected
          ? Center(
              child: Container(
                width: _controlWidth * 0.5,
                height: _controlHeight * 0.5,
                decoration: BoxDecoration(
                  color: _iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  void _computeLabelAndHint() {
    final String? label = _currentComponent.config['label'];
    final String? hint = _currentComponent.config['hint'];

    if (label != null) {
      _labelAndHint = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: _style['label_text_size']?.toDouble() ?? 16,
                color: StyleUtils.parseColor(_style['label_color']),
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
                    color: StyleUtils.parseColor(_style['hint_color']),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
    } else {
      _labelAndHint = null;
    }
  }

  // Common utility function for mapping icon names to IconData
  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  void handleTap() {
    FocusScope.of(context).requestFocus(focusNode);
    if (!_isEditable) return;

    debugPrint(
      '[Radio][tap] id=${_currentComponent.id} valueBefore=$_isSelected',
    );

    final String? group = _currentComponent.config['group'];

    // Logic to unselect other radios in the same group
    if (group != null) {
      // Find all siblings in the same group and unselect them
      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(componentId: _currentComponent.id, value: true),
      );
      debugPrint('[Radio][tap] id=${_currentComponent.id} valueAfter=true');
      debugPrint('[Radio] Save value: ${_currentComponent.id} = true');
    } else {
      // If no explicit group, treat it as a single radio button (not common)
      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(componentId: _currentComponent.id, value: true),
      );
      debugPrint('[Radio][tap] id=${_currentComponent.id} valueAfter=true');
      debugPrint('[Radio] Save value: ${_currentComponent.id} = true');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Update component from state and recompute values only when necessary
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Only update if component actually changed
        if (updatedComponent != _currentComponent ||
            updatedComponent.config['value'] !=
                _currentComponent.config['value'] ||
            updatedComponent.config['is_editable'] !=
                _currentComponent.config['is_editable'] ||
            updatedComponent.config['disabled'] !=
                _currentComponent.config['disabled']) {
          setState(() {
            _currentComponent = updatedComponent;
            _computeValues();
          });
        }
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when something visual actually changes
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          return prevComponent?.config['value'] !=
                  currComponent?.config['value'] ||
              prevComponent?.config['is_editable'] !=
                  currComponent?.config['is_editable'] ||
              prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'];
        },
        builder: (context, state) {
          return Focus(
            focusNode: focusNode,
            child: GestureDetector(
              onTap: handleTap,
              child: Container(
                key: Key(_currentComponent.id),
                margin: StyleUtils.parsePadding(_style['margin']),
                padding: StyleUtils.parsePadding(_style['padding']),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _toggleControl!,
                    const SizedBox(width: 12),
                    if (_leadingIconData != null) ...[
                      Icon(
                        _leadingIconData,
                        size: 20,
                        color: StyleUtils.parseColor(_style['icon_color']),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_labelAndHint != null) _labelAndHint!,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
