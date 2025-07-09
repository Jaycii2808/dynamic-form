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

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String _currentState = 'base';
  Map<String, dynamic> _style = {};
  Map<String, dynamic> _config = {};
  String _buttonText = 'Button';
  String _action = 'custom';
  bool _isVisible = true;
  bool _isDisabled = false;
  IconData? _iconData;

  // Pre-computed UI elements
  Widget? _buttonWidget;
  VoidCallback? _onPressedHandler;
  Widget? _buttonContent;

  @override
  void initState() {
    super.initState();

    // Initialize with widget component
    _currentComponent = widget.component;
    _computeValues();
  }

  void _computeValues() {
    _config = Map<String, dynamic>.from(_currentComponent.config);

    // Extract button properties
    _buttonText =
        _config['label']?.toString() ?? _config['text']?.toString() ?? 'Button';
    _action = _config['action']?.toString() ?? 'custom';
    _isVisible = _config['isVisible'] ?? true;
    _isDisabled = _config['disabled'] == true || _isLoading;

    // Debug log for Save button visibility
    if (_action == 'submit_form') {
      debugPrint(
        '🔘 Save Button (${_currentComponent.id}): isVisible=$_isVisible, canSave=${_config['canSave']}',
      );
    }

    if (!_isVisible) {
      debugPrint(
        '🚫 Hiding button ${_currentComponent.id} due to validation failure',
      );
    }

    _computeStyles();
    _computeCurrentState();
    _computeIcon();
    _computeUIElements();

    debugPrint(
      '[Button][_computeValues] id=${_currentComponent.id} text=$_buttonText action=$_action visible=$_isVisible disabled=$_isDisabled',
    );
  }

  void _computeStyles() {
    _style = Map<String, dynamic>.from(_currentComponent.style);

    // Apply variant styles
    if (_currentComponent.variants != null) {
      final variant = _config['variant']?.toString() ?? 'primary';
      if (_currentComponent.variants!.containsKey(variant)) {
        final variantStyle =
            _currentComponent.variants![variant]['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
    }

    // Apply state styles
    if (_currentComponent.states != null &&
        _currentComponent.states!.containsKey(_currentState)) {
      final stateStyle =
          _currentComponent.states![_currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) _style.addAll(stateStyle);
    }
  }

  void _computeCurrentState() {
    if (_isDisabled) {
      _currentState = 'disabled';
    } else if (_isLoading) {
      _currentState = 'loading';
    } else {
      _currentState = 'base';
    }
  }

  void _computeIcon() {
    final iconName = _config['icon']?.toString() ?? _style['icon']?.toString();
    if (iconName != null && iconName.isNotEmpty) {
      _iconData = IconTypeEnum.fromString(iconName).toIconData();
    } else {
      _iconData = null;
    }
  }

  void _computeUIElements() {
    // Pre-compute event handler
    _onPressedHandler = (_isDisabled || !_isVisible)
        ? null
        : _handleButtonPress;

    // Pre-compute button content
    _buttonContent = _buildButtonContent();

    // Pre-compute button widget
    if (!_isVisible) {
      _buttonWidget = const SizedBox.shrink();
    } else {
      _buttonWidget = _buildButtonWidget();
    }
  }

  Widget _buildButtonContent() {
    final fontSize = _parseDouble(_style['fontSize']) ?? 16.0;
    final fontWeight = _parseFontWeight(
      _style['fontWeight']?.toString() ?? 'normal',
    );

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
                  _style['color']?.toString() ?? '#ffffff',
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
    final isIconRightPosition =
        widget.component.config['is_icon_right_position'] == true ||
            widget.component.config['is_icon_right_position'] == 'true';

    if (_iconData != null) {
      if (isIconRightPosition) {
        // right
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _buttonText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                //color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(_iconData, size: fontSize + 4),
          ],
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconData, size: fontSize + 4),
          const SizedBox(width: 8),
          Text(
            _buttonText,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }

    return Text(
      _buttonText,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildButtonWidget() {
    // Parse style properties
    final backgroundColor = StyleUtils.parseColor(
      _style['backgroundColor']?.toString() ?? '#2196f3',
    );
    final textColor = StyleUtils.parseColor(
      _style['color']?.toString() ?? '#ffffff',
    );
    final borderColor = StyleUtils.parseColor(
      _style['borderColor']?.toString() ?? 'transparent',
    );
    final borderWidth = _parseDouble(_style['borderWidth']) ?? 1.0;
    final borderRadius = StyleUtils.parseBorderRadius(
      _parseInt(_style['borderRadius']) ?? 8,
    );
    final padding = StyleUtils.parsePadding(
      _style['padding']?.toString() ?? '12px 24px',
    );
    final margin = StyleUtils.parsePadding(
      _style['margin']?.toString() ?? '8px 4px',
    );
    final elevation = _parseDouble(_style['elevation']) ?? 2.0;

    return Container(
      key: Key(_currentComponent.id),
      margin: margin,
      child: SizedBox(
        width: _parseDouble(_style['width']),
        height: _parseDouble(_style['height']) ?? 48.0,
        child: ElevatedButton(
          onPressed: _onPressedHandler,
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
              _style['shadowColor']?.toString() ?? '#000000',
            ),
          ),
          child: _buttonContent,
        ),
      ),
    );
  }

  // Event handler - business logic
  void _handleButtonPress() async {
    setState(() {
      _isLoading = true;
      _computeValues(); // Recompute for loading state
    });

    try {
      // Prepare data based on action
      final data = {
        'action': _action,
        'timestamp': DateTime.now().toIso8601String(),
        'formId': _currentComponent.id,
        'customData': _currentComponent.config['customData'],
      };

      // Call the onAction callback
      widget.onAction?.call(_action, data);

      // Add delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _computeValues(); // Recompute to exit loading state
        });
      }
    }
  }

  // Helper methods
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
            updatedComponent.config['isVisible'] !=
                _currentComponent.config['isVisible'] ||
            updatedComponent.config['disabled'] !=
                _currentComponent.config['disabled'] ||
            updatedComponent.config['label'] !=
                _currentComponent.config['label'] ||
            updatedComponent.config['text'] !=
                _currentComponent.config['text']) {
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

          return prevComponent?.config['isVisible'] !=
                  currComponent?.config['isVisible'] ||
              prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'] ||
              prevComponent?.config['label'] !=
                  currComponent?.config['label'] ||
              prevComponent?.config['text'] != currComponent?.config['text'];
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          return _buttonWidget ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
