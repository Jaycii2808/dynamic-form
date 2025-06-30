// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';

class ComponentUtils {
  /// Create updated DynamicFormModel with new config - clean and safe
  static DynamicFormModel updateComponentConfig(
    DynamicFormModel component,
    Map<String, dynamic> newConfig,
  ) {
    return DynamicFormModel(
      id: component.id,
      type: component.type,
      order: component.order,
      config: newConfig,
      style: component.style,
      inputTypes: component.inputTypes,
      variants: component.variants,
      states: component.states,
      validation: component.validation,
      children: component.children,
    );
  }

  /// Clone component for clean immutable updates
  static DynamicFormModel cloneComponent(DynamicFormModel component) {
    return DynamicFormModel(
      id: component.id,
      type: component.type,
      order: component.order,
      config: Map<String, dynamic>.from(component.config),
      style: Map<String, dynamic>.from(component.style),
      inputTypes: component.inputTypes != null
          ? Map<String, dynamic>.from(component.inputTypes!)
          : null,
      variants: component.variants != null
          ? Map<String, dynamic>.from(component.variants!)
          : null,
      states: component.states != null
          ? Map<String, dynamic>.from(component.states!)
          : null,
      validation: component.validation != null
          ? Map<String, dynamic>.from(component.validation!)
          : null,
      children: component.children,
    );
  }

  /// Merge styles with null safety and state priority
  static Map<String, dynamic> mergeStyles(
    DynamicFormModel component, {
    String? variant,
    String? state,
    Map<String, dynamic>? additionalStyle,
  }) {
    final style = Map<String, dynamic>.from(component.style);

    // Apply variant style if exists
    if (variant != null &&
        component.variants != null &&
        component.variants!.containsKey(variant)) {
      final variantStyle =
          component.variants![variant]['style'] as Map<String, dynamic>?;
      if (variantStyle != null) {
        style.addAll(variantStyle);
      }
    }

    // Apply state style if exists (higher priority)
    if (state != null &&
        component.states != null &&
        component.states!.containsKey(state)) {
      final stateStyle =
          component.states![state]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) {
        style.addAll(stateStyle);
      }
    }

    // Apply additional style (highest priority)
    if (additionalStyle != null) {
      style.addAll(additionalStyle);
    }

    return style;
  }

  /// Get keyboard type with null safety
  static TextInputType getKeyboardType(DynamicFormModel component) {
    final inputTypes = component.inputTypes;
    if (inputTypes == null || inputTypes.isEmpty) return TextInputType.text;

    // Priority order for keyboard types
    if (inputTypes.containsKey('email')) return TextInputType.emailAddress;
    if (inputTypes.containsKey('tel')) return TextInputType.phone;
    if (inputTypes.containsKey('password'))
      return TextInputType.visiblePassword;
    if (inputTypes.containsKey('number')) return TextInputType.number;
    if (inputTypes.containsKey('url')) return TextInputType.url;

    return TextInputType.text;
  }

  /// Get multiline keyboard type for text areas
  static TextInputType getMultilineKeyboardType(DynamicFormModel component) {
    final basicType = getKeyboardType(component);

    // Convert single-line types to multiline equivalents
    if (basicType == TextInputType.emailAddress ||
        basicType == TextInputType.phone ||
        basicType == TextInputType.visiblePassword) {
      return TextInputType.multiline;
    }

    return basicType == TextInputType.text
        ? TextInputType.multiline
        : basicType;
  }

  /// Check if component is disabled with comprehensive checks
  static bool isComponentDisabled(DynamicFormModel component) {
    final config = component.config;
    return config['disabled'] == true ||
        config['readOnly'] == true ||
        !(config['editable'] ?? true);
  }

  /// Get safe config value with fallback and null safety
  static T getConfigValue<T>(
    DynamicFormModel component,
    String key,
    T defaultValue, {
    String? fallbackKey,
  }) {
    final config = component.config;

    // Try primary key
    if (config.containsKey(key) && config[key] is T) {
      return config[key] as T;
    }

    // Try fallback key (for camelCase/snake_case compatibility)
    if (fallbackKey != null &&
        config.containsKey(fallbackKey) &&
        config[fallbackKey] is T) {
      return config[fallbackKey] as T;
    }

    return defaultValue;
  }

  /// Get safe style value with fallback and null safety
  static T getStyleValue<T>(
    Map<String, dynamic> style,
    String key,
    T defaultValue, {
    String? fallbackKey,
  }) {
    // Try primary key
    if (style.containsKey(key) && style[key] is T) {
      return style[key] as T;
    }

    // Try fallback key (for camelCase/snake_case compatibility)
    if (fallbackKey != null &&
        style.containsKey(fallbackKey) &&
        style[fallbackKey] is T) {
      return style[fallbackKey] as T;
    }

    return defaultValue;
  }

  /// Create form field update event data with validation
  static Map<String, dynamic> createFieldUpdateData({
    required dynamic value,
    String? errorText,
    String? currentState,
    bool? selected,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{'value': value};

    if (errorText != null) data['error_text'] = errorText;
    if (currentState != null) data['current_state'] = currentState;
    if (selected != null) data['selected'] = selected;
    if (additionalData != null) data.addAll(additionalData);

    return data;
  }

  /// Get label with null safety and fallback
  static String getLabel(DynamicFormModel component, {String? fallback}) {
    final label = component.config['label'] as String?;
    return label ?? fallback ?? '';
  }

  /// Get placeholder with null safety and fallback
  static String getPlaceholder(DynamicFormModel component, {String? fallback}) {
    final placeholder = component.config['placeholder'] as String?;
    return placeholder ?? fallback ?? '';
  }

  /// Check if component has required validation
  static bool isRequired(DynamicFormModel component) {
    return component.config['isRequired'] == true ||
        component.config['required'] == true;
  }

  /// Get error message from component config
  static String? getErrorMessage(DynamicFormModel component) {
    return component.config['error_text'] as String? ??
        component.config['errorText'] as String?;
  }

  /// Get current state from component config
  static String getCurrentState(DynamicFormModel component) {
    return component.config['current_state'] as String? ??
        component.config['currentState'] as String? ??
        'base';
  }
}
