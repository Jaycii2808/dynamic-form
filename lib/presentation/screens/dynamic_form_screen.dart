import 'package:dynamic_form_bi/core/utils/loading_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';

class DynamicFormScreen extends StatelessWidget {
  static const String routeName = '/dynamic-form-screen';
  final String configKey;
  final String? title;
  final Function(Map<String, dynamic>)? onAction;

  const DynamicFormScreen({
    super.key,
    required this.configKey,
    this.title,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicFormBloc(remoteConfigService: RemoteConfigService())
            ..add(LoadDynamicFormPageEvent(configKey: configKey)),
      child: _DynamicFormContent(
        configKey: configKey,
        title: title,
        onAction: onAction,
      ),
    );
  }
}

class _DynamicFormContent extends StatefulWidget {
  final String configKey;
  final String? title;
  final Function(Map<String, dynamic>)? onAction;

  const _DynamicFormContent({
    required this.configKey,
    this.title,
    this.onAction,
  });

  @override
  State<_DynamicFormContent> createState() => _DynamicFormContentState();
}

class _DynamicFormContentState extends State<_DynamicFormContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        if (state is DynamicFormError) {
          debugPrint('Error occurred:  24{state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DynamicFormLoading) {
          LoadingUtils.showLoading(context, true);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is DynamicFormSuccess) {
          LoadingUtils.showLoading(context, false);
          return _buildPage(state.page!);
        } else if (state is DynamicFormEmpty) {
          LoadingUtils.showLoading(context, false);
          return _buildEmptyPage();
        } else if (state is DynamicFormError) {
          LoadingUtils.showLoading(context, false);
          return _buildErrorPage(state.errorMessage!);
        } else {
          LoadingUtils.showLoading(context, false);
          return _buildEmptyPage();
        }
      },
    );
  }

  Widget _buildPage(DynamicFormPageModel page) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          page.title.isNotEmpty ? page.title : (widget.title ?? 'Dynamic Form'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DynamicFormBloc>().add(
                RefreshDynamicFormPageEvent(configKey: widget.configKey),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var component in page.components)
            DynamicFormRenderer(component: component),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Lưu form'),
              onPressed: () {
                String idForm = page.pageId.isNotEmpty
                    ? page.pageId
                    : 'form_ 24{DateTime.now().millisecondsSinceEpoch}_ 24{Random().nextInt(10000)}';
                int order = page.order != 1
                    ? page.order
                    : DateTime.now().millisecondsSinceEpoch;
                final json = {
                  'id_form': idForm,
                  'order': order,
                  'title': page.title,
                  'components': page.components.map((c) => c.toJson()).toList(),
                };
                FormMemoryRepository.saveForm(idForm, json);
                _showFormJsonDialog(context, jsonEncode(json));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Dynamic Form'),
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
              'Add JSON configuration to Firebase Remote Config\nwith key " 24{widget.configKey}" to render UI components',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<DynamicFormBloc>().add(
                  LoadDynamicFormPageEvent(configKey: widget.configKey),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
        title: Text(widget.title ?? 'Dynamic Form'),
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
                context.read<DynamicFormBloc>().add(
                  LoadDynamicFormPageEvent(configKey: widget.configKey),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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

  void _showFormJsonDialog(BuildContext context, String json) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('JSON Form'),
          content: Text(json),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
