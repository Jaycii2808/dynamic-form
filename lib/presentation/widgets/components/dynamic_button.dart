import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';

class DynamicButton extends StatefulWidget {
  final DynamicFormModel component;
  final Function(String action, Map<String, dynamic>? data)? onAction;

  const DynamicButton({super.key, required this.component, this.onAction});

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    final config = component.config;
    final style = Map<String, dynamic>.from(component.style);

    // Get button text and action
    final buttonText = config['text'] ?? 'Button';
    final action = config['action'] ?? 'custom';
    final isDisabled = config['disabled'] == true || _isLoading;

    // Apply variant styles
    if (component.variants != null) {
      final variant = config['variant'] ?? 'primary';
      if (component.variants!.containsKey(variant)) {
        final variantStyle =
            component.variants![variant]['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'default';
    if (isDisabled) currentState = 'disabled';
    if (_isLoading) currentState = 'loading';

    // Apply state styles
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Parse style properties
    final backgroundColor = StyleUtils.parseColor(
      style['backgroundColor'] ?? '#2196f3',
    );
    final textColor = StyleUtils.parseColor(style['color'] ?? '#ffffff');
    final borderColor = StyleUtils.parseColor(
      style['borderColor'] ?? 'transparent',
    );
    final borderWidth = style['borderWidth']?.toDouble() ?? 0.0;
    final borderRadius = StyleUtils.parseBorderRadius(
      style['borderRadius'] ?? 8,
    );
    final fontSize = style['fontSize']?.toDouble() ?? 16.0;
    final fontWeight = _parseFontWeight(style['fontWeight'] ?? 'normal');
    final padding = StyleUtils.parsePadding(style['padding'] ?? '12 24');
    final margin = StyleUtils.parsePadding(style['margin'] ?? '16 0');

    // Get icon if specified
    IconData? iconData;
    if (config['icon'] != null) {
      iconData = IconTypeEnum.fromString(config['icon']).toIconData();
    }

    return Container(
      key: Key(component.id),
      margin: margin,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _handleButtonPress(action),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          side: borderWidth > 0
              ? BorderSide(color: borderColor, width: borderWidth)
              : null,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          padding: padding,
          elevation: style['elevation']?.toDouble() ?? 2.0,
          shadowColor: StyleUtils.parseColor(style['shadowColor'] ?? '#000000'),
        ),
        child: _buildButtonContent(buttonText, iconData, fontSize, fontWeight),
      ),
    );
  }

  Widget _buildButtonContent(
    String text,
    IconData? icon,
    double fontSize,
    FontWeight fontWeight,
  ) {
    if (_isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                StyleUtils.parseColor(
                  widget.component.style['color'] ?? '#ffffff',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  void _handleButtonPress(String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data based on action
      Map<String, dynamic>? data;

      switch (action) {
        case 'submit':
          data = {
            'action': 'submit',
            'timestamp': DateTime.now().toIso8601String(),
            'formId': widget.component.id,
          };
          break;
        case 'save':
          data = {
            'action': 'save',
            'timestamp': DateTime.now().toIso8601String(),
            'formId': widget.component.id,
          };
          break;
        case 'reset':
          data = {
            'action': 'reset',
            'timestamp': DateTime.now().toIso8601String(),
            'formId': widget.component.id,
          };
          break;
        default:
          data = {
            'action': action,
            'timestamp': DateTime.now().toIso8601String(),
            'formId': widget.component.id,
            'customData': widget.component.config['customData'],
          };
      }

      // Call the onAction callback
      widget.onAction?.call(action, data);

      // Add delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  FontWeight _parseFontWeight(String weight) {
    switch (weight.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }
}
