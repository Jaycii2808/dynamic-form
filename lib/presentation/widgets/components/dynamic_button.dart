import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        // Get the latest component from BLoC state to see visibility changes
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        final config = component.config;
        final style = Map<String, dynamic>.from(component.style);

        // Get button properties safely first
        final buttonText =
            config['label']?.toString() ??
            config['text']?.toString() ??
            'Button';
        final action = config['action']?.toString() ?? 'custom';

        // Check visibility first - hide button if validation fails
        final isVisible = config['is_visible'] ?? true;

        // Debug log for Save button visibility
        if (action == 'submit_form') {
          debugPrint(
            '🔘 Save Button (${component.id}): isVisible=$isVisible, canSave=${config['canSave']}',
          );
        }

        if (!isVisible) {
          debugPrint(
            '🚫 Hiding button ${component.id} due to validation failure',
          );
          return const SizedBox.shrink(); // Hide button completely
        }

        // Check if button should be disabled
        final isDisabled = config['disabled'] == true || _isLoading;

        // Apply variant styles
        if (component.variants != null) {
          final variant = config['variant']?.toString() ?? 'primary';
          if (component.variants!.containsKey(variant)) {
            final variantStyle =
                component.variants![variant]['style'] as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
        }

        // Determine current state
        String currentState = 'base';
        if (isDisabled) currentState = 'disabled';
        if (_isLoading) currentState = 'loading';

        // Apply state styles
        if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }

        // Parse style properties safely
        final backgroundColor = StyleUtils.parseColor(
          style['background_color']?.toString() ?? '#2196f3',
        );
        final textColor = StyleUtils.parseColor(
          style['color']?.toString() ?? '#ffffff',
        );
        final borderColor = StyleUtils.parseColor(
          style['border_color']?.toString() ?? 'transparent',
        );
        final borderWidth = _parseDouble(style['border_width']) ?? 1.0;
        final borderRadius = StyleUtils.parseBorderRadius(
          _parseInt(style['border_radius']) ?? 8,
        );
        final fontSize = _parseDouble(style['font_size']) ?? 16.0;
        final fontWeight = _parseFontWeight(
          style['font_weight']?.toString() ?? 'normal',
        );
        final padding = StyleUtils.parsePadding(
          style['padding']?.toString() ?? '12px 24px',
        );
        final margin = StyleUtils.parsePadding(
          style['margin']?.toString() ?? '8px 4px',
        );
        final elevation = _parseDouble(style['elevation']) ?? 2.0;

        // Get icon if specified
        IconData? iconData;
        final iconName =
            config['icon']?.toString() ?? style['icon']?.toString();
        if (iconName != null && iconName.isNotEmpty) {
          iconData = IconTypeEnum.fromString(iconName).toIconData();
        }

        return Container(
          key: Key(component.id),
          margin: margin,
          child: SizedBox(
            width: _parseDouble(style['width']),
            height: _parseDouble(style['height']) ?? 48.0,
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
                elevation: elevation,
                shadowColor: StyleUtils.parseColor(
                  style['shadow_color']?.toString() ?? '#000000',
                ),
              ),
              child: _buildButtonContent(
                buttonText,
                iconData,
                fontSize,
                fontWeight,
                textColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(
    String text,
    IconData? icon,
    double fontSize,
    FontWeight fontWeight,
    Color textColor,
  ) {
    final isIconRightPosition =
        widget.component.config['is_icon_right_position'] == true ||
        widget.component.config['is_icon_right_position'] == 'true';

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
                  widget.component.style['color']?.toString() ?? '#ffffff',
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
      if (isIconRightPosition) {
        // right
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: fontSize + 4),
          ],
        );
      } else {
        // leffft
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: fontSize + 4),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ],
        );
      }
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
    );
  }

  void _handleButtonPress(String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data based on action
      final data = {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        'formId': widget.component.id,
        'customData': widget.component.config['customData'],
      };

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

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove 'px' suffix if present
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '').trim();
      return double.tryParse(cleanValue);
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Remove any non-numeric characters
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '').trim();
      return int.tryParse(cleanValue);
    }
    return null;
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
