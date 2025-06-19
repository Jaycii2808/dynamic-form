import 'dart:convert';
import 'package:dynamic_form_bi/data/models/text_input_model.dart';
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

      // Set default empty JSON
      await _remoteConfig.setDefaults({'text_input_screen': '{}'});

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  TextInputScreenModel? getTextInputScreen() {
    try {
      final String jsonString = _remoteConfig.getString('text_input_screen');
      debugPrint('RemoteConfig text_input_screen: $jsonString');
      if (jsonString.isEmpty || jsonString == '{}') {
        debugPrint('RemoteConfig: text_input_screen is empty or {}');
        return null;
      }
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return TextInputScreenModel.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing UI page: $e');
      return null;
    }
  }

  Future<void> updateTextInputScreen(String jsonString) async {
    try {
      await _remoteConfig.setDefaults({'text_input_screen': jsonString});
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error updating UI page: $e');
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
