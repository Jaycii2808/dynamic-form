import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/ui_component_model.dart';

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
      await _remoteConfig.setDefaults({'ui_page': '{}'});

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  UIPageModel? getUIPage() {
    try {
      final String jsonString = _remoteConfig.getString('ui_page');
      print('RemoteConfig ui_page: $jsonString');
      if (jsonString.isEmpty || jsonString == '{}') {
        print('RemoteConfig: ui_page is empty or {}');
        return null;
      }
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UIPageModel.fromJson(json);
    } catch (e) {
      print('Error parsing UI page: $e');
      return null;
    }
  }

  Future<void> updateUIPage(String jsonString) async {
    try {
      await _remoteConfig.setDefaults({'ui_page': jsonString});
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error updating UI page: $e');
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
