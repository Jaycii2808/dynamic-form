import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class RemoteConfigFormBuilderEnum {
  final String key;

  const RemoteConfigFormBuilderEnum._(this.key);

  @override
  String toString() => key;

  // Get component keys from remote config
  static List<String> getComponentKeysFromRemoteConfig() {
    try {
      final remoteConfigService = RemoteConfigService();
      final remoteConfigValue = remoteConfigService.getString(
        'list_component_form_builder',
      );

      // Clean up the string: remove newlines, extra spaces, and split by comma
      final cleanedValue = remoteConfigValue
          .replaceAll('\n', '') // Remove newlines
          .replaceAll('\r', '') // Remove carriage returns
          .trim(); // Remove leading/trailing whitespace

      // Split by comma and clean up whitespace
      final keys = cleanedValue
          .split(',')
          .map((key) => key.trim())
          .where((key) => key.isNotEmpty)
          .toList();

      // If no keys found from remote config, use fallback keys
      if (keys.isEmpty) {
        debugPrint(
          '⚠️ No component keys found in remote config, using fallback keys',
        );
        return [
          'text_field_component_v4',
          'text_area_component_v4',
          'switch_component_v4',
          'selector_button_components_v4',
          'date_time_picker_components_v4',
          'date_time_range_picker_single_component_v4',
          'dropdown_component_v4', // Add dropdown component
        ];
      }

      return keys;
    } catch (e) {
      debugPrint('❌ Error getting remote config: $e, using fallback keys');
      // Return fallback keys when remote config fails
      return [
        'text_field_component_v4',
        'text_area_component_v4',
        'switch_component_v4',
        'selector_button_components_v4',
        'date_time_picker_components_v4',
        'date_time_range_picker_single_component_v4',
        'dropdown_component_v4', // Add dropdown component
      ];
    }
  }

  // Create enum instances from remote config
  static List<RemoteConfigFormBuilderEnum> getValues() {
    final keys = getComponentKeysFromRemoteConfig();
    return keys.map((key) => RemoteConfigFormBuilderEnum._(key)).toList();
  }

  // Helper method to find enum by key string
  static RemoteConfigFormBuilderEnum? fromKey(String key) {
    final values = getValues();
    try {
      return values.firstWhere((e) => e.key == key);
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if key exists
  static bool hasKey(String key) {
    final values = getValues();
    return values.any((e) => e.key == key);
  }

  // Get all keys as strings
  static List<String> getAllKeys() {
    return getComponentKeysFromRemoteConfig();
  }
}

class RemoteConfigButtonBuilderEnum {
  final String key;

  const RemoteConfigButtonBuilderEnum._(this.key);

  @override
  String toString() => key;

  // Get button component keys from remote config
  static List<String> getButtonComponentKeysFromRemoteConfig() {
    try {
      final remoteConfigService = RemoteConfigService();
      final remoteConfigValue = remoteConfigService.getString(
        'list_button_component_form_builder',
      );

      // Clean up the string: remove newlines, extra spaces, and split by comma
      final cleanedValue = remoteConfigValue
          .replaceAll('\n', '') // Remove newlines
          .replaceAll('\r', '') // Remove carriage returns
          .trim(); // Remove leading/trailing whitespace

      // Split by comma and clean up whitespace
      final keys = cleanedValue
          .split(',')
          .map((key) => key.trim())
          .where((key) => key.isNotEmpty)
          .toList();

      // If no keys found from remote config, use fallback keys
      if (keys.isEmpty) {
        debugPrint(
          '⚠️ No button component keys found in remote config, using fallback keys',
        );
        return ['submit_button_config_component_validate_v4'];
      }

      return keys;
    } catch (e) {
      debugPrint(
        '❌ Error getting button remote config: $e, using fallback keys',
      );
      // Return fallback keys when remote config fails
      return ['submit_button_config_component_validate_v4'];
    }
  }

  // Create enum instances from remote config
  static List<RemoteConfigButtonBuilderEnum> getValues() {
    final keys = getButtonComponentKeysFromRemoteConfig();
    return keys.map((key) => RemoteConfigButtonBuilderEnum._(key)).toList();
  }

  // Helper method to find enum by key string
  static RemoteConfigButtonBuilderEnum? fromKey(String key) {
    final values = getValues();
    try {
      return values.firstWhere((e) => e.key == key);
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if key exists
  static bool hasKey(String key) {
    final values = getValues();
    return values.any((e) => e.key == key);
  }

  // Get all keys as strings
  static List<String> getAllKeys() {
    return getButtonComponentKeysFromRemoteConfig();
  }
}
