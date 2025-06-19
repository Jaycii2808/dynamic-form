import 'package:dynamic_form_bi/core/utils/loading_utils.dart';
import 'package:dynamic_form_bi/data/models/text_input_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/text_input/text_input_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/text_input/text_input_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/text_input/text_input_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/text_input_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextInputScreen extends StatelessWidget {
  static const String routeName = '/text-input-screen';
  final String? title;
  final Function(Map<String, dynamic>)? onAction;

  const TextInputScreen({super.key, this.title, this.onAction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TextInputBloc(remoteConfigService: RemoteConfigService())
        ..add(LoadTextInputPageEvent()),
      child: _TextInputContent(title: title, onAction: onAction),
    );
  }
}

class _TextInputContent extends StatefulWidget {
  final String? title;
  final Function(Map<String, dynamic>)? onAction;

  const _TextInputContent({this.title, this.onAction});

  @override
  State<_TextInputContent> createState() => _TextInputContentState();
}

class _TextInputContentState extends State<_TextInputContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TextInputBloc, TextInputState>(
      listener: (context, state) {
        if (state is TextInputError) {
          debugPrint('Error occurred: ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is TextInputLoading) {
          LoadingUtils.showLoading(context, true);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is TextInputSuccess) {
          LoadingUtils.showLoading(context, false);
          return _buildPage(state.page!);
        } else if (state is TextInputEmpty) {
          LoadingUtils.showLoading(context, false);
          return _buildEmptyPage();
        } else if (state is TextInputError) {
          LoadingUtils.showLoading(context, false);
          return _buildErrorPage(state.errorMessage!);
        } else {
          LoadingUtils.showLoading(context, false);
          return _buildEmptyPage();
        }
      },
    );
  }

  Widget _buildPage(TextInputScreenModel page) {
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
              context.read<TextInputBloc>().add(RefreshTextInputPageEvent());
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var component in page.components) TextInputRenderer(textInputComponent: component),
        ],
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
              'Add JSON configuration to Firebase Remote Config\nwith key "text_input_screen" to render UI components',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<TextInputBloc>().add(LoadTextInputPageEvent());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
            GestureDetector(
              onTap: () {
                context.read<TextInputBloc>().add(LoadTextInputPageEvent());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}