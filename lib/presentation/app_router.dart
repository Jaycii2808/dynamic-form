import 'package:dynamic_form_bi/presentation/screens/home_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/shared_form_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/saved_forms_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/watch_components_forms/existing_forms_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/watch_components_forms/dynamic_form_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/multi_screen/preview_multipage_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_preview_screen.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: HomeScreen.routeName,
    debugLogDiagnostics: true,
    routes: [
      // Home route
      GoRoute(
        path: HomeScreen.routeName,
        //  name: HomeScreen.routeName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      // Shared form route with form ID parameter
      GoRoute(
        path: SharedFormScreen.routePath,
        name: SharedFormScreen.routeName,
        pageBuilder: (context, state) {
          final String formId = state.pathParameters['formId']!;
          return NoTransitionPage(child: SharedFormScreen(formId: formId));
        },
      ),
      // Form builder (no params)
      GoRoute(
        path: FormBuilderScreen.routeName,
        // name: FormBuilderScreen.routeName,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final existing = extra is FormBuilderModel ? extra : null;
          return NoTransitionPage(
            child: FormBuilderScreen(
              existingForm: existing,
              isEditing: existing != null,
            ),
          );
        },
      ),
      // Saved forms (no params)
      GoRoute(
        path: SavedFormsScreen.routeName,
        //name: SavedFormsScreen.routeName,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SavedFormsScreen(),
        ),
      ),
      // Existing forms (no params)
      GoRoute(
        path: ExistingFormsScreen.routeName,
        //name: ExistingFormsScreen.routeName,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ExistingFormsScreen(),
        ),
      ),
      // Dynamic single-page form with configKey path param
      GoRoute(
        path: DynamicFormScreen.routePath,
        //name: DynamicFormScreen.routeName,
        pageBuilder: (context, state) {
          final configKey = state.pathParameters['configKey']!;
          final title = (state.extra is Map<String, dynamic>)
              ? (state.extra as Map<String, dynamic>)['title'] as String?
              : null;
          return NoTransitionPage(
            child: DynamicFormScreen(configKey: configKey, title: title),
          );
        },
      ),
      // Dynamic multi-page form with configKey path param
      // GoRoute(
      //   path: DynamicFormMultiScreen.routePath,
      //   // name: DynamicFormMultiScreen.routeName,
      //   pageBuilder: (context, state) {
      //     final configKey = state.pathParameters['configKey']!;
      //     return NoTransitionPage(
      //       child: DynamicFormMultiScreen(configKey: configKey),
      //     );
      //   },
      // ),
      // Preview screen (pass pages and values via extra)
      GoRoute(
        path: PreviewPageScreen.routeName,
        // name: PreviewPageScreen.routeName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final pages = extra?['pages'] as List<DynamicFormPageModel>;
          final values = extra?['values'];
          return NoTransitionPage(
            child: PreviewPageScreen(
              pages: pages,
              allComponentValues: values,
            ),
          );
        },
      ),
      // FormBuilder preview (pass formBuilderModel via extra)
      GoRoute(
        path: FormBuilderPreviewScreen.routeName,
        name: FormBuilderPreviewScreen.routeName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final model = extra?['formBuilderModel'] as FormBuilderModel;
          return NoTransitionPage(
            child: FormBuilderPreviewScreen(formBuilderModel: model),
          );
        },
      ),
    ],
    // Error page for invalid routes
    errorBuilder: (context, state) => const HomeScreen(),
  );
}
