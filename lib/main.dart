import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/firebase_options.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/dynamic_form_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DynamicFormBloc(remoteConfigService: RemoteConfigService()),
        ),
      ],
      child: MaterialApp(
        title: 'Dynamic UI BI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Predefined remote config keys (extendable in future)
    final configKeys = [
      'text_field_component',
      'select_component',
      'text_area_component',
      'date_time_picker_component',
      'drop_down_component',
      'check_box_component',
      'radio_component',
      'filter_price_component',
      'selector_component',
      'switch_component',
      'text_field_tags_component',
      'file_uploader_component',
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
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DynamicFormScreen(configKey: configKey, title: configKey),
                    ),
                  );
                },
                child: Container(
                  color: Colors.blueGrey,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: Text(configKey, style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
