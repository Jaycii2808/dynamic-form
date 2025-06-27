import 'package:dynamic_form_bi/domain/services/form_template_service.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/firebase_options.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/dynamic_form_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/saved_forms_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Remote Config
  await RemoteConfigService().initialize();

  // Load templates from local storage
  await FormMemoryRepository.loadTemplatesFromStorage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DynamicFormBloc(
            remoteConfigService: RemoteConfigService(),
            formTemplateService: FormTemplateService(),
          ),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> configKeys = [];

  @override
  void initState() {
    super.initState();
    loadConfigKeys();
  }

  void loadConfigKeys() {
    setState(() {
      configKeys = RemoteConfigService().getAll().keys.toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    // list parameters on remote configs Firebase
    // final configKeys = RemoteConfigService().getAll().keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Forms'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedFormsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Saved Forms',
          ),
          //icon button   await RemoteConfigService().initialize();
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              await RemoteConfigService().initialize();

              await Future.delayed(const Duration(milliseconds: 50));
              Navigator.of(context).pop();
              loadConfigKeys();
            },

            icon: const Icon(Icons.restart_alt ),
            tooltip: 'Reload  Online',
          ),
        ],
      ),
      body: ListView(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configKeys.length,
            itemBuilder: (context, index) {
              final configKey = configKeys[index];
              debugPrint('CONFIG_KEY: $configKey');
              return buildItem(context, configKey);
            },
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, String configKey) {
    return GestureDetector(
      onTap: () => onTapOpenForm(context, configKey),
      child: buildItemContainer(configKey),
    );
  }

  void onTapOpenForm(BuildContext context, String configKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DynamicFormScreen(configKey: configKey, title: configKey),
      ),
    );
  }

  Widget buildItemContainer(String configKey) {
    return Container(
      color: Colors.blueGrey,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Text(configKey, style: const TextStyle(color: Colors.white)),
    );
  }
}
