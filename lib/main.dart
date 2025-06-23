import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/firebase_options.dart';
import 'package:dynamic_form_bi/presentation/screens/dynamic_form_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Remote Config
  await RemoteConfigService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic UI BI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToForm(BuildContext context, String configKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicFormScreen(
          configKey: configKey,
          title: configKey.replaceAll('_', ' ').toUpperCase(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Predefined remote config keys (extendable in future)
    final configKeys = [
      'text_input_screen',
      'select_input',
      'text_area_form',
      'datetime_picker_form',
      'dropdown_input',
      'checkbox_input',
      'radio_button',
      'filter_price',
      'selector_component',
      'switch_component',
      'textfield_tags_component',
      'file_uploader',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Forms'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configKeys.length,
            itemBuilder: (context, index) {
              final configKey = configKeys[index];
              return ListTile(
                title: Text(
                  configKey.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DynamicFormScreen(
                        configKey: configKey,
                        title: configKey.replaceAll('_', ' ').toUpperCase(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
