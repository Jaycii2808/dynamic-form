import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ui_bloc.dart';
import '../bloc/ui_state.dart';
import '../bloc/ui_event.dart';
import '../../core/models/ui_component_model.dart';
import '../../core/services/remote_config_service.dart';
import '../../core/utils/loading_utils.dart';
import '../widgets/dynamic_ui_renderer.dart';

class DynamicPage extends StatelessWidget {
  final String? title;
  final Function(Map<String, dynamic>)? onAction;

  const DynamicPage({super.key, this.title, this.onAction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UIBloc(remoteConfigService: RemoteConfigService())..add(LoadUIPage()),
      child: _DynamicPageContent(title: title, onAction: onAction),
    );
  }
}

class _DynamicPageContent extends StatefulWidget {
  final String? title;
  final Function(Map<String, dynamic>)? onAction;

  const _DynamicPageContent({this.title, this.onAction});

  @override
  State<_DynamicPageContent> createState() => _DynamicPageContentState();
}

class _DynamicPageContentState extends State<_DynamicPageContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UIBloc, UIState>(
      listener: (context, state) {
        if (state is UIError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is UILoading) {
          LoadingUtils.showLoading(context, true);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is UILoaded) {
          LoadingUtils.showLoading(context, false);
          return _buildPage(state.page);
        } else if (state is UIEmpty) {
          LoadingUtils.showLoading(context, false);
          return _buildEmptyPage();
        } else if (state is UIError) {
          LoadingUtils.showLoading(context, false);
          return _buildErrorPage(state.message);
        } else {
          LoadingUtils.showLoading(context, false);
          return _buildEmptyPage();
        }
      },
    );
  }

  Widget _buildPage(UIPageModel page) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          page.title.isNotEmpty ? page.title : (widget.title ?? 'Dynamic Page'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UIBloc>().add(RefreshUIPage());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: page.components
              .map((component) => DynamicUIRenderer(component: component))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Dynamic Page'),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No UI Components Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add JSON configuration to Firebase Remote Config\nwith key "ui_page" to render UI components',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UIBloc>().add(LoadUIPage());
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPage(String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Dynamic Page'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UIBloc>().add(LoadUIPage());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
