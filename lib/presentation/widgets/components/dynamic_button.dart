import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/validation/button_condition_validation_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_factory.dart';
import 'package:dynamic_form_bi/data/models/variants/variants_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicButton extends StatefulWidget {
  final DynamicFormModel component;
  final Function(String action, FormActionDataModel? data)? onAction;

  const DynamicButton({super.key, required this.component, this.onAction});

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  bool _isLoading = false;

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  StatesEnum _currentState = StatesEnum.base;
  late StyleModel _style;
  late ConfigModel _config;
  String _buttonText = 'Button';
  ButtonAction _action = ButtonAction.custom;
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
    _config = _currentComponent.config ?? const ConfigModel();
    _buttonText =
        _config.label?.toString() ?? _config.buttonText?.toString() ?? 'Button';

    // Convert action to ButtonAction enum
    try {
      final actionString = _config.action?.toString();
      if (actionString != null) {
        _action = ButtonAction.fromString(actionString);
      } else {
        _action = ButtonAction.custom;
      }
    } catch (e) {
      _action = ButtonAction.custom;
    }

    _isVisible = true; // Default visibility

    debugPrint('🔍 [Button] Starting validation for ${_currentComponent.id}');
    debugPrint('🔍 [Button] Config: ${_config.toJson()}');

    bool validationPassed = true;
    final validateJson = _config.validate;
    debugPrint('🔍 [Button] Validate object: $validateJson');

    // Use ValidationFactory to create proper model
    final validation = ValidationFactory.fromJson(validateJson);

    if (validation is ButtonConditionValidationModel) {
      final conditions = validation.conditions;
      debugPrint('🔍 [Button] Conditions: $conditions');

      if (conditions.isNotEmpty) {
        for (final condition in conditions) {
          final id = condition.idComponent;
          final isRequired = condition.isRequired ?? false;
          final regex = condition.regex ?? '';

          debugPrint(
            '🔍 [Button] Condition: id=$id, isRequired=$isRequired, regex=$regex',
          );

          if (isRequired && id.isNotEmpty) {
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

    _isDisabled = _isLoading || !validationPassed;
    debugPrint(
      '🔍 [Button] Final disabled state: $_isDisabled (isLoading=$_isLoading, validationPassed=$validationPassed)',
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
    if (_action == ButtonAction.nextPage ||
        _action == ButtonAction.previousPage) {
      try {
        setState(() {
          _isLoading = true;
        });
        final validate = _currentComponent.validation?.toJson();
        final targetPage =
            validate?[_action == ButtonAction.nextPage
                    ? 'next_page'
                    : 'previous_page']
                as String?;
        debugPrint('🔘 [Button] Target page: $targetPage');

        widget.onAction?.call(
          _action.value,
          FormActionDataModel.navigation(
            action: _action.value,
            targetPage: targetPage ?? '',
            formId: _currentComponent.id,
            configKey: _currentComponent.id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('❌ [Button] Error handling button action: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Handle custom actions
      try {
        setState(() {
          _isLoading = true;
        });

        widget.onAction?.call(
          _action.value,
          FormActionDataModel.create(
            action: _action.value,
            formId: _currentComponent.id,
            customData: _config.toJson()['customData'],
            configKey: _currentComponent.id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
    _style = _currentComponent.style;

    // Apply variant styles
    if (_currentComponent.variants != null) {
      final variant = _config.toJson()['variant']?.toString() ?? 'primary';
      final variantStyle = _currentComponent.variants?.getByKey(variant)?.style;
      if (variantStyle != null) {
        // Merge variant styles with base styles
        _style = _mergeStyleModels(
          _style,
          _convertStyleStatesToStyleModel(variantStyle),
        );
      }
    }

    // Apply state styles
    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
      _currentComponent.states,
      _currentState,
    );
    if (stateStyle != null) {
      // Merge state styles with current styles
      _style = _mergeStyleModels(
        _style,
        _convertStyleStatesToStyleModel(stateStyle),
      );
    }
  }

  // Helper method to convert StyleStatesModel to StyleModel
  StyleModel _convertStyleStatesToStyleModel(StyleStatesModel stateStyle) {
    return StyleModel(
      borderColor: stateStyle.borderColor,
      borderWidth: stateStyle.borderWidth,
      helperText: stateStyle.helperText,
      helperTextColor: stateStyle.helperTextColor,
      textColor: stateStyle.textColor,
      icon: stateStyle.icon,
      iconColor: stateStyle.iconColor,
      iconSize: stateStyle.iconSize,
    );
  }

  // Helper method to merge two StyleModels
  StyleModel _mergeStyleModels(StyleModel base, StyleModel overlay) {
    return StyleModel(
      fontSize: overlay.fontSize ?? base.fontSize,
      fontStyle: overlay.fontStyle ?? base.fontStyle,
      contentVerticalPadding:
          overlay.contentVerticalPadding ?? base.contentVerticalPadding,
      contentHorizontalPadding:
          overlay.contentHorizontalPadding ?? base.contentHorizontalPadding,
      backgroundColor: overlay.backgroundColor ?? base.backgroundColor,
      helperText: overlay.helperText ?? base.helperText,
      helperTextColor: overlay.helperTextColor ?? base.helperTextColor,
      labelTextSize: overlay.labelTextSize ?? base.labelTextSize,
      labelColor: overlay.labelColor ?? base.labelColor,
      maxLines: overlay.maxLines ?? base.maxLines,
      minLines: overlay.minLines ?? base.minLines,
      borderRadius: overlay.borderRadius ?? base.borderRadius,
      borderColor: overlay.borderColor ?? base.borderColor,
      borderWidth: overlay.borderWidth ?? base.borderWidth,
      borderOpacity: overlay.borderOpacity ?? base.borderOpacity,
      iconColor: overlay.iconColor ?? base.iconColor,
      hintColor: overlay.hintColor ?? base.hintColor,
      width: overlay.width ?? base.width,
      height: overlay.height ?? base.height,
      activeColor: overlay.activeColor ?? base.activeColor,
      inactiveColor: overlay.inactiveColor ?? base.inactiveColor,
      inactiveTrackColor: overlay.inactiveTrackColor ?? base.inactiveTrackColor,
      tagBackgroundColor: overlay.tagBackgroundColor ?? base.tagBackgroundColor,
      tagRemoveIconColor: overlay.tagRemoveIconColor ?? base.tagRemoveIconColor,
      thumbColor: overlay.thumbColor ?? base.thumbColor,
      thumbIconColor: overlay.thumbIconColor ?? base.thumbIconColor,
      valueLabelColor: overlay.valueLabelColor ?? base.valueLabelColor,
      iconSize: overlay.iconSize ?? base.iconSize,
      textColor: overlay.textColor ?? base.textColor,
      buttonBackgroundColor:
          overlay.buttonBackgroundColor ?? base.buttonBackgroundColor,
      buttonBorderRadius: overlay.buttonBorderRadius ?? base.buttonBorderRadius,
      buttonTextColor: overlay.buttonTextColor ?? base.buttonTextColor,
      icon: overlay.icon ?? base.icon,
      iconPosition: overlay.iconPosition ?? base.iconPosition,
      fontWeight: overlay.fontWeight ?? base.fontWeight,
      elevation: overlay.elevation ?? base.elevation,
      shadowColor: overlay.shadowColor ?? base.shadowColor,
      focusedBorderColor: overlay.focusedBorderColor ?? base.focusedBorderColor,
      errorBorderColor: overlay.errorBorderColor ?? base.errorBorderColor,
    );
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
    final iconName = _config.icon?.toString() ?? _style.icon;
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
    final fontSize = _style.fontSize ?? 10.0;
    final fontWeight = _parseFontWeight(
      _style.fontWeight?.toString() ?? 'normal',
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
                _style.textColor ?? Colors.white,
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

    // Check icon position from config
    final isIconRightPosition =
        _config.toJson()['is_icon_right_position'] == true ||
        _config.toJson()['is_icon_right_position'] == 'true';

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
    final backgroundColor = _style.backgroundColor ?? Colors.blue;
    final textColor = _style.textColor ?? Colors.white;
    final borderColor = _style.borderColor ?? Colors.black;
    final borderWidth = _style.borderWidth ?? 1.0;
    final elevation = _style.elevation ?? 2.0;

    return Container(
      key: Key(_currentComponent.id),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SizedBox(
        width: _style.width,
        height: _style.height ?? 48.0,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            elevation: elevation,
            shadowColor: _style.shadowColor ?? Colors.purpleAccent,
          ),
          child: _buttonContent,
        ),
      ),
    );
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
            updatedComponent.config?.label != _config.label ||
            updatedComponent.config?.buttonText != _config.buttonText) {
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

          return prevComponent?.config?.label != currComponent?.config?.label ||
              prevComponent?.config?.buttonText !=
                  currComponent?.config?.buttonText;
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          return _buttonWidget ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
