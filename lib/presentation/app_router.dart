import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_preview_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/home_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/preview_page_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/shared_form_screen.dart';
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
          final isEditing = extra?['isEditing'] as bool? ?? false;
          return NoTransitionPage(
            child: FormBuilderPreviewScreen(
              formBuilderModel: model,
              isEditing: isEditing,
            ),
          );
        },
      ),
    ],
    // Error page for invalid routes
    errorBuilder: (context, state) => const HomeScreen(),
  );
}
