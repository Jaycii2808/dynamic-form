// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_models.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/variants/variants_model.dart';

// XÓA extension VariantsModelExt ở đây, chỉ giữ ở variants_model.dart

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
      inputTypes: component.inputTypes, // just reference, since it's immutable
      variants: component.variants, // Đúng kiểu VariantsModel
      states: component.states, // assign as is, do not clone as Map
      validation: component.validation != null
          ? ValidationFactory.fromJson(component.validation!.toJson())
          : null,
      children: component.children,
    );
  }

  static StyleStatesModel? getStateStyle(StatesModel? states, String? key) {
    switch (key) {
      case 'base':
        return states?.base;
      case 'error':
        return states?.error;
      case 'success':
        return states?.success;
      case 'focused':
        return states?.focused;
      default:
        return null;
    }
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
    if (variant != null && component.variants != null) {
      final variantStyle = component.variants!.getByKey(variant)?.style;
      if (variantStyle != null) {
        style.addAll(variantStyle.toJson());
      }
    }

    // Apply state style if exists (higher priority)
    if (state != null && component.states != null) {
      final stateStyle = getStateStyle(component.states, state);
      if (stateStyle != null) {
        style.addAll(stateStyle.toJson());
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
    if (inputTypes.email != null) return TextInputType.emailAddress;
    if (inputTypes.tel != null) return TextInputType.phone;
    if (inputTypes.password != null) {
      return TextInputType.visiblePassword;
    }
    // No number/url in model, fallback to text
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

  /// Centralized style application - eliminates repetitive if-else chains
  static Map<String, dynamic> applyComponentStyles(
    DynamicFormModel component, {
    String? currentState,
    List<String>? conditionalVariants,
  }) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final state = currentState ?? getCurrentState(component);

    // Apply conditional variants based on component configuration
    if (component.variants != null && conditionalVariants != null) {
      for (final variantKey in conditionalVariants) {
        final variantStyle = component.variants!.getByKey(variantKey)?.style;
        if (variantStyle != null) {
          style.addAll(variantStyle.toJson());
        }
      }
    }

    // Apply common variants based on component properties
    if (component.variants != null) {
      // Icon variants
      if ((config['icon'] != null || style['icon'] != null) &&
          component.variants!.withIcon?.style != null) {
        style.addAll(component.variants!.withIcon!.style!.toJson());
      }

      // Label variants
      final hasLabel =
          config['label'] != null && config['label'].toString().isNotEmpty;
      if (hasLabel && component.variants!.withLabel?.style != null) {
        style.addAll(component.variants!.withLabel!.style!.toJson());
      } else if (!hasLabel &&
          component.variants!.getByKey('without_label')?.style != null) {
        style.addAll(
          component.variants!.getByKey('without_label')!.style!.toJson(),
        );
      }

      // Multiple/searchable variants for select/dropdown
      if (config['multiple'] == true &&
          component.variants!.multiple?.style != null) {
        style.addAll(component.variants!.multiple!.style!.toJson());
      }

      if (config['searchable'] == true &&
          component.variants!.searchable?.style != null) {
        style.addAll(component.variants!.searchable!.style!.toJson());
      }
    }

    // Apply state styles (highest priority)
    if (component.states != null) {
      final stateStyle = getStateStyle(component.states, state);
      if (stateStyle != null) {
        style.addAll(stateStyle.toJson());
      }
    }

    return style;
  }

  /// Smart component style builder with automatic variant detection
  static Map<String, dynamic> buildComponentStyles(
    DynamicFormModel component, {
    String? explicitState,
    Map<String, dynamic>? overrideStyles,
  }) {
    // Auto-detect variants based on component configuration
    final conditionalVariants = <String>[];
    final config = component.config;

    // Avatar variant for dropdowns
    if (config['avatar'] != null) {
      conditionalVariants.add('with_avatar');
    }

    final styles = applyComponentStyles(
      component,
      currentState: explicitState,
      conditionalVariants: conditionalVariants,
    );

    // Apply override styles (highest priority)
    if (overrideStyles != null) {
      styles.addAll(overrideStyles);
    }

    return styles;
  }
}
