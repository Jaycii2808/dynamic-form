import 'dart:convert';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
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
          fetchTimeout: const Duration(milliseconds: 1500),
          minimumFetchInterval: Duration.zero,
        ),
      );

      // Set default empty JSON
      await _remoteConfig.setDefaults({'text_input_screen': '{}'});

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  DynamicFormPageModel? getTextInputScreen(String configKey) {
    try {
      final String jsonString = _remoteConfig.getString(configKey);
      debugPrint('RemoteConfig $configKey: $jsonString');
      if (jsonString.isEmpty || jsonString == '{}') {
        debugPrint('RemoteConfig: $configKey is empty or {}');
        return null;
      }
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return DynamicFormPageModel.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing form $configKey: $e');
      return null;
    }
  }

  Future<void> updateTextInputScreen(
    String configKey,
    String jsonString,
  ) async {
    try {
      await _remoteConfig.setDefaults({configKey: jsonString});
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error updating form $configKey: $e');
    }
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
