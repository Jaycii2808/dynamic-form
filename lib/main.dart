import 'package:dynamic_form_bi/core/services/remote_config_service.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart';
import 'package:dynamic_form_bi/firebase_options.dart';
import 'package:dynamic_form_bi/presentation/app_router.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_button/dynamic_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/simple_bloc_observer.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nested/nested.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  Bloc.observer = SimpleBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RemoteConfigService().initialize();
  await dotenv.load(fileName: "lib/dotenv");
  runApp(const MyProviders());
}

class MyProviders extends StatelessWidget {
  const MyProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _buildBlocProviders(),
      child: _buildMaterialApp(),
    );
  }

  MaterialApp _buildMaterialApp() {
    return MaterialApp.router(
      title: 'Dynamic Form Builder V3',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      routerConfig: AppRouter.router,
      // Clamp text scale factor to prevent UI overflow while keeping accessibility
      builder: (context, child) {
        return _buildScaleFactory(context, child);
      },
    );
  }

  Widget _buildScaleFactory(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.of(context).textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.5, // Allow up to 150% scaling
        ),
      ),
      child: child!,
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
        create: (_) => DynamicButtonBloc(),
      ),
      BlocProvider(
        create: (context) => FormBuilderBloc(
          remoteConfigService: RemoteConfigService(),
          userFormsService: UserFormsService(),
        ),
      ),
      BlocProvider(
        create: (context) => UserFormsBloc(
          userFormsService: UserFormsService(),
          remoteConfigService: RemoteConfigService(),
        ),
      ),
    ];
  }
}
