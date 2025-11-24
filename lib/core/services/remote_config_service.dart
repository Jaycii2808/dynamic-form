import 'dart:convert';
import 'package:dynamic_form_bi/core/enums/remote_config_keys_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      // // Set default empty JSON
      // await _remoteConfig.setDefaults({'text_input_screen': '{}'});

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  Map<String, RemoteConfigValue> getAll() {
    return _remoteConfig.getAll();
  }

  DynamicFormPageModel? getConfigKey(String configKey) {
    try {
      final String jsonString = _remoteConfig.getString(configKey);
      debugPrint('RemoteConfig $configKey: $jsonString');
      if (jsonString.isEmpty || jsonString == '{}') {
        debugPrint('RemoteConfig: $configKey is empty or {}');
        return null;
      }
      final dynamic json = jsonDecode(jsonString);
      if (json is List) {
        // Wrap array as {components: array}
        return DynamicFormPageModel.fromJson({'components': json});
      } else if (json is Map<String, dynamic>) {
        return DynamicFormPageModel.fromJson(json);
      } else {
        debugPrint(
          'RemoteConfig: $configKey is not a valid JSON object or array',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error parsing form $configKey: $e');
      return null;
    }
  }

  // Method that accepts enum for better type safety
  DynamicFormPageModel? getConfigByKey(RemoteConfigFormBuilderEnum configKey) {
    return getConfigKey(configKey.key);
  }

  // Method that accepts button enum for better type safety
  DynamicFormPageModel? getButtonConfigByKey(
    RemoteConfigButtonBuilderEnum configKey,
  ) {
    return getButtonConfigKey(configKey.key);
  }

  DynamicFormPageModel? getButtonConfigKey(String configKey) {
    try {
      final String jsonString = _remoteConfig.getString(configKey);
      debugPrint('RemoteConfig $configKey: $jsonString');
      if (jsonString.isEmpty || jsonString == '{}') {
        debugPrint('RemoteConfig: $configKey is empty or {}');
        return null;
      }
      final dynamic json = jsonDecode(jsonString);
      debugPrint('Parsed JSON type: ${json.runtimeType}');

      if (json is List) {
        debugPrint('JSON is List, wrapping as components array');
        // Wrap array as {components: array}
        return DynamicFormPageModel.fromJson({'components': json});
      } else if (json is Map<String, dynamic>) {
        debugPrint('JSON is Map, checking for components field');
        // Check if it has a components field
        if (json.containsKey('components')) {
          debugPrint('Found components field, parsing as DynamicFormPageModel');
          return DynamicFormPageModel.fromJson(json);
        } else {
          debugPrint(
            'No components field, treating as single button component',
          );
          // Single button component object - wrap it as {components: [json]}
          return DynamicFormPageModel.fromJson({
            'components': [json],
          });
        }
      } else {
        debugPrint(
          'RemoteConfig: $configKey is not a valid JSON object or array',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error parsing button config $configKey: $e');
      return null;
    }
  }

  /// Get all configs from all enum values automatically
  /// This method loops through all RemoteConfigFormBuilderEnum values
  /// and returns all available components
  List<DynamicFormModel> getAllConfigs() {
    final components = <DynamicFormModel>[];

    // Get component keys from remote config
    final componentKeys = RemoteConfigFormBuilderEnum.getValues();
    debugPrint(
      '🚀 Starting to load ${componentKeys.length} components from remote config',
    );

    for (final configKey in componentKeys) {
      debugPrint('📦 Processing component key: ${configKey.key}');
      final configPage = getConfigByKey(configKey);
      if (configPage != null && configPage.components.isNotEmpty) {
        components.addAll(configPage.components);
        debugPrint(
          '✅ Loaded ${configPage.components.length} components from ${configKey.key}',
        );
      } else {
        debugPrint('❌ No valid components found in ${configKey.key}');
      }
    }

    debugPrint('🎯 Total components loaded: ${components.length}');
    return components;
  }

  /// Get all button configs from all enum values automatically
  /// This method loops through all RemoteConfigButtonBuilderEnum values
  /// and returns all available button components
  List<DynamicFormModel> getAllButtonConfigs() {
    final components = <DynamicFormModel>[];

    // Get button component keys from remote config
    final buttonComponentKeys = RemoteConfigButtonBuilderEnum.getValues();
    debugPrint(
      '🚀 Starting to load ${buttonComponentKeys.length} button components from remote config',
    );

    for (final configKey in buttonComponentKeys) {
      debugPrint('📦 Processing button component key: ${configKey.key}');
      final configPage = getButtonConfigKey(configKey.key);
      debugPrint(
        '📦 Config page result: ${configPage != null ? 'not null' : 'null'}',
      );
      if (configPage != null) {
        debugPrint('📦 Components count: ${configPage.components.length}');
        if (configPage.components.isNotEmpty) {
          components.addAll(configPage.components);
          debugPrint(
            '✅ Loaded ${configPage.components.length} button components from ${configKey.key}',
          );
        } else {
          debugPrint('❌ No components in config page for ${configKey.key}');
        }
      } else {
        debugPrint('❌ No valid button components found in ${configKey.key}');
      }
    }

    debugPrint('🎯 Total button components loaded: ${components.length}');
    return components;
  }

  /// Get component keys from remote config
  List<RemoteConfigFormBuilderEnum> getComponentKeysFromRemoteConfig() {
    return RemoteConfigFormBuilderEnum.getValues();
  }

  /// Get configs by specific enum values
  /// Useful when you only want components from specific config keys
  /// Example: getConfigsByKeys([RemoteConfigFormBuilderEnum.textFieldComponentV4])
  List<DynamicFormModel> getConfigsByKeys(
    List<RemoteConfigFormBuilderEnum> configKeys,
  ) {
    final components = <DynamicFormModel>[];

    for (final configKey in configKeys) {
      final configPage = getConfigByKey(configKey);
      if (configPage != null && configPage.components.isNotEmpty) {
        components.addAll(configPage.components);
        debugPrint(
          'Loaded ${configPage.components.length} components from ${configKey.key}',
        );
      } else {
        debugPrint('No valid components found in ${configKey.key}');
      }
    }

    return components;
  }

  // Extension methods for better API
  String getStringByKey(RemoteConfigFormBuilderEnum configKey) {
    return getString(configKey.key);
  }

  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }
}
