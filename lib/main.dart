import 'package:dynamic_form_bi/core/router/app_router.dart';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';
import 'package:dynamic_form_bi/domain/services/form_template_service.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/core/services/email_service.dart';
import 'package:dynamic_form_bi/firebase_options.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nested/nested.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RemoteConfigService().initialize();
  await dotenv.load(fileName: "lib/dotenv");
  await FormMemoryRepository.loadTemplatesFromStorage();
  await EmailService().initialize(); // Initialize email service
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _buildBlocProviders(),
      child: MaterialApp.router(
        title: 'Dynamic Form Builder V3',
        debugShowCheckedModeBanner: false,
        theme: _buildThemeData(),
        routerConfig: AppRouter.router,
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
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
