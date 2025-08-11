import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/screens/multi_screen/dynamic_form_multi_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/watch_components_forms/dynamic_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExistingFormsScreen extends StatefulWidget {
  static const String routeName = '/existing-forms';
  const ExistingFormsScreen({super.key});

  @override
  State<ExistingFormsScreen> createState() => _ExistingFormsScreenState();
}

class _ExistingFormsScreenState extends State<ExistingFormsScreen> {
  List<String> configKeys = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigKeys();
  }

  Future<void> _loadConfigKeys() async {
    setState(() => isLoading = true);
    try {
      final keys = RemoteConfigService().getAll().keys.toList();
      setState(() {
        configKeys = keys;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading config keys: $e');
    }
  }

  Future<void> _reloadConfig() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    await RemoteConfigService().initialize();
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      context.pop();
      await _loadConfigKeys();
    }
  }

  Future<void> _navigateToForm(BuildContext context, String configKey) async {
    // Show loading dialog while fetching config
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch config string from RemoteConfigService
      final configString =
          RemoteConfigService().getAll()[configKey]?.asString() ?? '';

      // Close loading dialog
      context.pop();

      // Check if config string is valid and in JSON format
      if (configString.isNotEmpty && configString.trim().startsWith('{')) {
        try {
          // Navigate to multi-page form if config is valid JSON
          context.pushNamed(
            DynamicFormMultiScreen.routeName,
            pathParameters: {'configKey': configKey},
          );
        } catch (e) {
          // Show error dialog if JSON parsing fails
          DialogUtils.showErrorDialog(
            context,
            'Invalid JSON format in form config: $e',
          );
        }
      } else {
        // Navigate to single-page form if config is empty or not JSON
        context.pushNamed(
          DynamicFormScreen.routeName,
          pathParameters: {'configKey': configKey},
          extra: {
            'title': configKey,
          },
        );
      }
    } catch (e) {
      // Close loading dialog and show error if config fetch fails
      context.pop();
      DialogUtils.showErrorDialog(context, 'Failed to load form config: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Existing Forms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Available Forms',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        _buildReloadButton(onReload: _reloadConfig),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading forms...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (configKeys.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFormsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Forms Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'There are no forms configured yet.\nCreate your first form using the form builder.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Go to Form Builder',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Forms (${configKeys.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap on any form to open and fill it out',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: configKeys.length,
            itemBuilder: (context, index) => _buildFormItem(
              configKey: configKeys[index],
              onTap: () => _navigateToForm(context, configKeys[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormItem({
    required String configKey,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.description,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    configKey,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to open form',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReloadButton({required Future<void> Function() onReload}) {
    return Builder(
      builder: (context) => IconButton(
        onPressed: onReload,
        icon: const Icon(Icons.restart_alt),
        tooltip: 'Reload Forms',
      ),
    );
  }
}
