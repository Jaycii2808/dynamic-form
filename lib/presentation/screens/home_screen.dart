import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/screens/multi_screen/dynamic_form_multi_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/dynamic_form_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/saved_forms_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> configKeys = [];

  @override
  void initState() {
    super.initState();
    _loadConfigKeys();
  }

  Future<void> _loadConfigKeys() async {
    final keys = RemoteConfigService().getAll().keys.toList();
    setState(
      () => configKeys = keys,
    );
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
      Navigator.of(context).pop();
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
      final configString = RemoteConfigService().getAll()[configKey]?.asString() ?? '';

      // Close loading dialog
      Navigator.of(context).pop();

      // Check if config string is valid and in JSON format
      if (configString.isNotEmpty && configString.trim().startsWith('{')) {
        try {
          // Navigate to multi-page form if config is valid JSON
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DynamicFormMultiScreen(configKey: configKey),
            ),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicFormScreen(
              configKey: configKey,
              title: configKey,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error if config fetch fails
      Navigator.of(context).pop();
      DialogUtils.showErrorDialog(context, 'Failed to load form config: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormBuilderScreen(),
            ),
          );
        },
        tooltip: 'Add form builder',
        child: const Icon(Icons.add),
      ),
      body: _buildFormListView(
        configKeys: configKeys,
        onTapForm: _navigateToForm,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Dynamic Forms'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        _buildSavedFormsButton(),
        _buildReloadButton(onReload: _reloadConfig),
      ],
    );
  }

  Widget _buildSavedFormsButton() {
    return Builder(
      builder: (context) => IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavedFormsScreen()),
          );
        },
        icon: const Icon(Icons.archive_outlined),
        tooltip: 'Saved Forms',
      ),
    );
  }

  Widget _buildReloadButton({required Future<void> Function() onReload}) {
    return Builder(
      builder: (context) => IconButton(
        onPressed: onReload,
        icon: const Icon(Icons.restart_alt),
        tooltip: 'Reload Online',
      ),
    );
  }

  Widget _buildFormListView({
    required List<String> configKeys,
    required void Function(BuildContext, String) onTapForm,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: configKeys.length,
      itemBuilder: (context, index) => _buildFormItem(
        configKey: configKeys[index],
        onTap: () => onTapForm(context, configKeys[index]),
      ),
    );
  }

  Widget _buildFormItem({
    required String configKey,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          configKey,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
