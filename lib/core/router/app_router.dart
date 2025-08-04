import 'package:dynamic_form_bi/presentation/screens/home_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/shared_form_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Home route
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // Shared form route with form ID parameter
      GoRoute(
        path: '/forms/:formId',
        builder: (context, state) {
          final formId = state.pathParameters['formId'] ?? '';
          return SharedFormScreen(formId: formId);
        },
      ),
    ],
    // Error page for invalid routes
    errorBuilder: (context, state) => const HomeScreen(),
  );
}
