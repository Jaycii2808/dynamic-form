import 'package:dynamic_form_bi/presentation/screens/home_screen.dart';
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
        pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
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
    ],
    // Error page for invalid routes
    errorBuilder: (context, state) => const HomeScreen(),
  );
}
