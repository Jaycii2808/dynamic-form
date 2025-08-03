import 'package:dynamic_form_bi/domain/services/form_template_service.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/firebase_options.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';
import 'package:nested/nested.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RemoteConfigService().initialize();
  await FormMemoryRepository.loadTemplatesFromStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _buildBlocProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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

  List<SingleChildWidget> _buildBlocProviders() {
    return [
      BlocProvider(
        create: (context) => DynamicFormBloc(
          remoteConfigService: RemoteConfigService(),
          formTemplateService: FormTemplateService(),
        ),
      ),
      BlocProvider(
        create: (context) => FormBuilderBloc(
          remoteConfigService: RemoteConfigService(),
        ),
      ),
    ];
  }
}
