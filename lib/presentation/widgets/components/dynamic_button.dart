import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/variants/variants_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_state.dart';

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
  StatesEnum _currentState = StatesEnum.base;
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
    _config = _currentComponent.config?.toJson() ?? <String, dynamic>{};
    _buttonText =
        _config['label']?.toString() ?? _config['text']?.toString() ?? 'Button';
    _action = _config['action']?.toString() ?? 'custom';
    _isVisible = _config['isVisible'] ?? true;

    debugPrint('🔍 [Button] Starting validation for ${_currentComponent.id}');
    debugPrint('🔍 [Button] Config: $_config');

    bool validationPassed = true;
    final validate = _currentComponent.config?.toJson()['validate'];
    debugPrint('🔍 [Button] Validate object: $validate');

    if (validate != null && validate is Map<String, dynamic>) {
      final conditions = validate['condition'] as List?;
      debugPrint('🔍 [Button] Conditions: $conditions');

      if (conditions != null && conditions.isNotEmpty) {
        for (final cond in conditions) {
          final id = cond['id_component'];
          final isRequired = cond['is_required'] == true;
          final regex = cond['regex']?.toString() ?? '';

          debugPrint(
            '🔍 [Button] Condition: id=$id, isRequired=$isRequired, regex=$regex',
          );

          if (isRequired && id != null) {
            final componentValue = _getComponentValue(id);
            debugPrint(
              '🔍 [Button] Validating $id: value=$componentValue, isRequired=$isRequired, regex=$regex',
            );

            // Check required condition
            if (isRequired &&
                (componentValue == null ||
                    (componentValue is bool
                        ? componentValue == false
                        : componentValue.toString().trim().isEmpty))) {
              debugPrint(
                '❌ [Button] Required validation failed for $id in ${_currentComponent.id}',
              );
              validationPassed = false;
              break;
            }

            // Check regex condition
            if (regex.isNotEmpty &&
                componentValue != null &&
                componentValue.toString().isNotEmpty) {
              try {
                final regexPattern = RegExp(regex);
                if (!regexPattern.hasMatch(componentValue.toString())) {
                  debugPrint(
                    '❌ [Button] Regex validation failed for $id in ${_currentComponent.id}',
                  );
                  validationPassed = false;
                  break;
                }
              } catch (e) {
                debugPrint(
                  '❌ [Button] Invalid regex pattern: $regex for ${_currentComponent.id}',
                );
                validationPassed = false;
                break;
              }
            }
          }
        }
      }
    }

    _isDisabled =
        _config['disabled'] == true || _isLoading || !validationPassed;
    debugPrint(
      '🔍 [Button] Final disabled state: $_isDisabled (config_disabled=${_config['disabled']}, isLoading=$_isLoading, validationPassed=$validationPassed)',
    );

    _computeStyles();
    _computeCurrentState();
    _computeIcon();
    _computeUIElements();
  }

  void _handleButtonPress() async {
    if (_isLoading) {
      debugPrint('⚠️ [Button] Prevented double click: ${_currentComponent.id}');
      return;
    }
    debugPrint(
      '🔘 [Button] Button pressed: ${_currentComponent.id}, action: $_action',
    );

    // For navigation buttons, set loading state briefly to prevent double click
    if (_action == 'next_page' || _action == 'previous_page') {
      setState(() {
        _isLoading = true;
        _computeValues();
      });
      final validate = _currentComponent.validation?.toJson();
      final targetPage =
          validate?[_action == 'next_page' ? 'next_page' : 'previous_page']
              as String?;
      debugPrint('🔘 [Button] Target page: $targetPage');
      final data = {
        'action': _action,
        'timestamp': DateTime.now().toIso8601String(),
        'formId': _currentComponent.id,
        'customData': _currentComponent.config?.toJson()['customData'],
        'targetPage': targetPage,
      };
      widget.onAction?.call(_action, data);
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _computeValues();
        });
      }
      return;
    }
    // For other actions, keep the original loading logic
    setState(() {
      _isLoading = true;
      _computeValues();
    });
    try {
      final data = {
        'action': _action,
        'timestamp': DateTime.now().toIso8601String(),
        'formId': _currentComponent.id,
        'customData': _currentComponent.config?.toJson()['customData'],
      };
      widget.onAction?.call(_action, data);
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _computeValues();
        });
      }
    }
  }

  // Helper method to get component value from form state
  dynamic _getComponentValue(String componentId) {
    try {
      // Try to get from form bloc state
      final formState = context.read<DynamicFormBloc>().state;
      if (formState.page != null) {
        final component = formState.page!.components.firstWhere(
          (comp) => comp.id == componentId,
          orElse: () => DynamicFormModel.empty(),
        );
        if (component.id.isNotEmpty) {
          final value = component.config?.value;
          debugPrint('🔍 [Button] Getting value for $componentId: $value');
          return value;
        }
      }

      // Try to get from multi page form bloc state
      try {
        final multiPageState = context.read<MultiPageFormBloc>().state;
        if (multiPageState is MultiPageFormSuccess) {
          final value = multiPageState.componentValues.getValue(componentId);
          debugPrint(
            '🔍 [Button] Getting value from MultiPageForm for $componentId: $value',
          );
          return value;
        }
      } catch (e) {
        debugPrint(
          '🔍 [Button] MultiPageForm not available for $componentId: $e',
        );
      }
    } catch (e) {
      debugPrint('Error getting component value for $componentId: $e');
    }
    return null;
  }

  void _computeStyles() {
    final styleModel = _currentComponent.style;
    _style = styleModel.toJson();

    // Apply variant styles
    if (_currentComponent.variants != null) {
      final variant = _config['variant']?.toString() ?? 'primary';
      final variantStyle = _currentComponent.variants
          ?.getByKey(variant)
          ?.style
          ?.toJson();
      if (variantStyle != null) _style.addAll(variantStyle);
    }

    // Apply state styles
    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
      _currentComponent.states,
      _currentState,
    );
    if (stateStyle != null) {
      _style.addAll(stateStyle.toJson());
    }
  }

  void _computeCurrentState() {
    if (_isDisabled) {
      _currentState = StatesEnum.disabled;
    } else if (_isLoading) {
      _currentState = StatesEnum.loading;
    } else {
      _currentState = StatesEnum.base;
    }
  }

  void _computeIcon() {
    final styleModel = StyleModel.fromJson(_currentComponent.style.toJson());
    final iconName = _config['icon']?.toString() ?? styleModel.icon;
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
    final styleModel = StyleModel.fromJson(_currentComponent.style.toJson());
    final fontSize = styleModel.fontSize ?? 16.0;
    final fontWeight = _parseFontWeight(
      styleModel.fontWeight?.toString() ?? 'normal',
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
                styleModel.textColor ?? Colors.white,
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
        _currentComponent.config?.toJson()['is_icon_right_position'] == true ||
        _currentComponent.config?.toJson()['is_icon_right_position'] == 'true';

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
    final styleModel = _currentComponent.style;
    final backgroundColor = styleModel.backgroundColor ?? Colors.blue;
    final textColor = styleModel.textColor ?? Colors.white;
    final borderColor = styleModel.borderColor ?? Colors.black;
    final borderWidth = styleModel.borderWidth ?? 1.0;

    final elevation = styleModel.elevation ?? 2.0;

    return Container(
      key: Key(_currentComponent.id),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SizedBox(
        width: styleModel.width,
        height: styleModel.height ?? 48.0,
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
            //shape: RoundedRectangleBorder(borderRadius: ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            elevation: elevation,
            shadowColor: styleModel.shadowColor ?? Colors.purpleAccent,
          ),
          child: _buttonContent,
        ),
      ),
    );
  }

  // Event handler - business logic

  // Helper methods
  // double? _parseDouble(dynamic value) {
  //   if (value == null) return null;
  //   if (value is double) return value;
  //   if (value is int) return value.toDouble();
  //   if (value is String) {
  //     // Remove 'px' suffix if present
  //     final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '').trim();
  //     return double.tryParse(cleanValue);
  //   }
  //   return null;
  // }

  // int? _parseInt(dynamic value) {
  //   if (value == null) return null;
  //   if (value is int) return value;
  //   if (value is double) return value.toInt();
  //   if (value is String) {
  //     // Remove any non-numeric characters
  //     final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '').trim();
  //     return int.tryParse(cleanValue);
  //   }
  //   return null;
  // }

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
            updatedComponent.config?.toJson()['isVisible'] !=
                _currentComponent.config?.toJson()['isVisible'] ||
            updatedComponent.config?.toJson()['disabled'] !=
                _currentComponent.config?.toJson()['disabled'] ||
            updatedComponent.config?.toJson()['label'] !=
                _currentComponent.config?.toJson()['label'] ||
            updatedComponent.config?.toJson()['text'] !=
                _currentComponent.config?.toJson()['text']) {
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

          return prevComponent?.config?.toJson()['isVisible'] !=
                  currComponent?.config?.toJson()['isVisible'] ||
              prevComponent?.config?.toJson()['disabled'] !=
                  currComponent?.config?.toJson()['disabled'] ||
              prevComponent?.config?.toJson()['label'] !=
                  currComponent?.config?.toJson()['label'] ||
              prevComponent?.config?.toJson()['text'] !=
                  currComponent?.config?.toJson()['text'];
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          return _buttonWidget ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
