import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDropdown extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic)? onComplete;
  final Function(DynamicFormModel)? onComponentUpdate;
  final bool isSharedForm;
  final String? currentPageId; // Add page ID for navigation tracking

  const DynamicDropdown({
    super.key,
    required this.component,
    this.onComplete,
    this.onComponentUpdate,
    this.isSharedForm = false,
    this.currentPageId, // Add page ID parameter
  });

  @override
  State<DynamicDropdown> createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  String? selectedValue;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    debugPrint(
      '🏗️ [DynamicDropdown] Initializing dropdown component: ${widget.component.id}',
    );
    debugPrint(
      '🏗️ [DynamicDropdown] Current page ID: ${widget.currentPageId}',
    );
    selectedValue = widget.component.config?.value?.toString();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🔍 [DynamicDropdown] Building dropdown component: ${widget.component.id}',
    );
    debugPrint('🔍 [DynamicDropdown] Is shared form: ${widget.isSharedForm}');
    debugPrint('🔍 [DynamicDropdown] Current page ID: ${widget.currentPageId}');
    debugPrint(
      '🔍 [DynamicDropdown] Component config: ${widget.component.config?.toJson()}',
    );

    return BlocConsumer<DynamicDropdownBloc, DynamicDropdownState>(
      listener: (context, state) {
        if (state is DynamicDropdownSuccess) {
          selectedValue = state.currentValue;
          if (widget.onComplete != null) {
            widget.onComplete!(state.currentValue);
          }
        }
      },
      builder: (context, state) {
        debugPrint('🔍 [DynamicDropdown] State: ${state.runtimeType}');
        debugPrint('🔍 [DynamicDropdown] Current value: ${state.currentValue}');
        return _buildDropdownWidget(state);
      },
    );
  }

  Widget _buildDropdownWidget(DynamicDropdownState state) {
    debugPrint('🔍 [DynamicDropdown] Building dropdown widget');
    debugPrint('🔍 [DynamicDropdown] Component type: ${state.component.type}');
    debugPrint(
      '🔍 [DynamicDropdown] Options count: ${state.component.config?.options?.length ?? 0}',
    );

    try {
      final styleModel = state.component.style;
      final inputConfig = state.inputConfig;
      final component = state.component;
      final currentState = state.currentState;
      final errorText = state.errorText;

      // Get shuffled options if enabled
      final options = context.read<DynamicDropdownBloc>().getShuffledOptions();
      debugPrint(
        '🔍 [DynamicDropdown] Shuffled options count: ${options.length}',
      );

      if (options.isEmpty) {
        debugPrint(
          '⚠️ [DynamicDropdown] No options available, showing fallback',
        );
        return _buildFallbackWidget(component, 'No options available');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (component.config?.label != null) ...[
            Row(
              children: [
                Text(
                  component.config!.label!,
                  style: TextStyle(
                    color: widget.isSharedForm
                        ? Colors.white
                        : (styleModel.labelColor ?? Colors.white),
                    fontSize: styleModel.fontSize ?? 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Add red asterisk for required fields
                if (component.config?.isRequired == true) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Description
          if (component.config?.description != null) ...[
            Text(
              component.config!.description!,
              style: TextStyle(
                color: widget.isSharedForm
                    ? Colors.white
                    : (styleModel.helperTextColor ?? Colors.grey),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Dropdown field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                styleModel.borderRadius ?? 8.0,
              ),
              border: _buildBorder(
                styleModel,
                component,
                currentState,
                errorText,
              ),
              // Set dark background for shared form mode to make white text visible
              color: widget.isSharedForm ? const Color(0xFF2D2D2D) : null,
            ),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              focusNode: _focusNode,
              decoration: InputDecoration(
                isDense: true,
                hintText:
                    component.config?.placeholder ??
                    inputConfig.placeholder ??
                    'Please select',
                hintStyle: TextStyle(
                  color: widget.isSharedForm
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey,
                ),
                // Set transparent background to avoid conflicts with container
                filled: widget.isSharedForm,
                fillColor: widget.isSharedForm ? Colors.transparent : null,
                // Add default dropdown arrow icon
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: widget.isSharedForm ? Colors.white : Colors.grey,
                ),
                prefixIcon: _buildPrefixIcon(component, currentState),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: styleModel.contentVerticalPadding ?? 12.0,
                  horizontal: styleModel.contentHorizontalPadding ?? 12.0,
                ),
                border: InputBorder.none,
                errorText: errorText,
                helperText: _getHelperText(styleModel, currentState, component),
                helperStyle: TextStyle(
                  color: _getHelperTextColor(
                    styleModel,
                    currentState,
                    component,
                  ),
                  fontSize: 12,
                ),
              ),
              style: TextStyle(
                fontSize: styleModel.fontSize ?? 16,
                // Selected value text should be white in shared form mode
                color: widget.isSharedForm
                    ? Colors.white
                    : _getTextColor(styleModel, currentState, component),
              ),
              dropdownColor: widget.isSharedForm
                  ? Colors.white
                  : (styleModel.backgroundColor ?? Colors.white),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: styleModel.fontSize ?? 16,
                      // Use dark text for dropdown items to ensure visibility
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: inputConfig.disabled || inputConfig.readOnly
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        final selectedOption = options.firstWhere(
                          (opt) => opt.value == newValue,
                          orElse: () => options.first,
                        );

                        context.read<DynamicDropdownBloc>().add(
                          DropdownOptionSelectedEvent(
                            value: newValue,
                            action: selectedOption.action,
                            targetSection: selectedOption.targetSection,
                          ),
                        );

                        // Handle option actions
                        _handleOptionAction(selectedOption);
                      }
                    },
              validator: (value) {
                if (component.config?.isRequired == true &&
                    (value == null || value.isEmpty)) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [DynamicDropdown] Error building dropdown widget: $e');
      debugPrint('❌ [DynamicDropdown] Stack trace: $stackTrace');
      return _buildFallbackWidget(state.component, 'Error: $e');
    }
  }

  Widget _buildFallbackWidget(DynamicFormModel component, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            component.config?.label ?? 'Dropdown',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Component ID: ${component.id}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Border _buildBorder(
    StyleModel styleModel,
    DynamicFormModel component,
    StatesEnum currentState,
    String? errorText,
  ) {
    StatesEnum borderState = currentState;
    if (errorText != null && errorText.isNotEmpty) {
      borderState = StatesEnum.error;
    }

    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      borderState,
    );
    final Color color =
        stateStyle?.iconColor ?? styleModel.borderColor ?? Colors.grey;
    final double width =
        stateStyle?.borderWidth ?? styleModel.borderWidth ?? 1.0;

    return Border.all(color: color, width: width);
  }

  Widget? _buildPrefixIcon(
    DynamicFormModel component,
    StatesEnum currentState,
  ) {
    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      currentState,
    );
    final iconName = component.config?.icon?.toString();

    if (iconName != null && iconName.isNotEmpty && stateStyle != null) {
      final iconColor = stateStyle.iconColor;
      final iconSize = stateStyle.iconSize;
      final iconData = IconTypeEnum.fromString(iconName).toIconData();

      if (iconData != null) {
        return Icon(iconData, color: iconColor, size: iconSize);
      }
    }
    return null;
  }

  String? _getHelperText(
    StyleModel styleModel,
    StatesEnum currentState,
    DynamicFormModel component,
  ) {
    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      currentState,
    );
    return stateStyle?.helperText ?? styleModel.helperText;
  }

  Color _getHelperTextColor(
    StyleModel styleModel,
    StatesEnum currentState,
    DynamicFormModel component,
  ) {
    // In shared form mode, always use white text for better visibility on dark background
    if (widget.isSharedForm) {
      return Colors.white;
    }

    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      currentState,
    );
    return stateStyle?.helperTextColor ??
        styleModel.helperTextColor ??
        Colors.white;
  }

  Color _getTextColor(
    StyleModel styleModel,
    StatesEnum currentState,
    DynamicFormModel component,
  ) {
    // In shared form mode, always use white text for better visibility on dark background
    if (widget.isSharedForm) {
      return Colors.white;
    }

    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      currentState,
    );
    return stateStyle?.textColor ?? styleModel.textColor ?? Colors.white;
  }

  void _handleOptionAction(Option selectedOption) {
    final action = selectedOption.action;
    final targetSection = selectedOption.targetSection;

    debugPrint('🎯 [DynamicDropdown] Handling option action: $action');
    debugPrint('🎯 [DynamicDropdown] Target section: $targetSection');
    debugPrint('🎯 [DynamicDropdown] Current page ID: ${widget.currentPageId}');

    switch (action?.toLowerCase()) {
      case 'continue':
        // Continue to next section - will be handled when next button is pressed
        debugPrint(
          '➡️ [DynamicDropdown] Continue action stored for next button',
        );
        break;
      case 'goto':
        // Go to specific section - will be handled when next button is pressed
        if (targetSection != null) {
          debugPrint(
            '🎯 [DynamicDropdown] Goto action stored for next button: $targetSection',
          );
        }
        break;
      case 'submit':
        // Submit form - will be handled when next button is pressed
        debugPrint('📤 [DynamicDropdown] Submit action stored for next button');
        break;
      default:
        // Default behavior - just update value
        debugPrint(
          '✅ [DynamicDropdown] Option selected: ${selectedOption.label}',
        );
        break;
    }
  }
}
