import 'package:dynamic_form_bi/data/models/saved_form_model.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavedFormsScreen extends StatefulWidget {
  const SavedFormsScreen({super.key});

  @override
  State<SavedFormsScreen> createState() => _SavedFormsScreenState();
}

class _SavedFormsScreenState extends State<SavedFormsScreen> {
  final SavedFormsService _savedFormsService = SavedFormsService();
  List<SavedFormModel> _savedForms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedForms();
  }

  Future<void> _loadSavedForms() async {
    debugPrint('🔄 Loading saved forms...');
    setState(() => _isLoading = true);
    try {
      final forms = await _savedFormsService.getSavedForms();
      debugPrint('📋 Loaded ${forms.length} saved forms');
      for (final form in forms) {
        debugPrint('  - ${form.name} (${form.id}) - ${form.savedAt}');
      }
      setState(() {
        _savedForms = forms;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading saved forms: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading saved forms: $e')),
        );
      }
    }
  }

  Future<void> _deleteSavedForm(SavedFormModel form) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Form'),
        content: Text('Are you sure you want to delete "${form.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _savedFormsService.deleteSavedForm(form.id);
        await _loadSavedForms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${form.name} deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting form: $e')));
        }
      }
    }
  }

  void _loadSavedForm(SavedFormModel savedForm) {
    try {
      // Check if we have custom form data (new format)
      if (savedForm.customFormData != null) {
        final customData = savedForm.customFormData!;
        final components = customData['components'] as List<dynamic>? ?? [];

        // Convert components back to DynamicFormModel list
        final formComponents = components
            .map(
              (comp) => DynamicFormModel.fromJson(comp as Map<String, dynamic>),
            )
            .toList();

        // Create DynamicFormPageModel from saved data
        final formPage = DynamicFormPageModel(
          pageId: customData['page_id'] ?? savedForm.originalConfigKey,
          title: savedForm.name,
          order: 0,
          components: formComponents,
        );

        debugPrint('🔄 Loading saved form with custom format');
        debugPrint('📋 Form ID: ${customData['form_id']}');
        debugPrint('🔢 Components loaded: ${formComponents.length}');

        Navigator.pop(context); // Close saved forms screen

        // Navigate to preview screen with loaded data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormPreviewScreen(
              page: formPage,
              title: savedForm.name,
              isViewOnly: true,
            ),
          ),
        );
      } else if (savedForm.formData != null) {
        // Legacy format support
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormPreviewScreen(
              page: savedForm.formData!,
              title: savedForm.name,
              isViewOnly: true,
            ),
          ),
        );
      } else {
        throw Exception('No form data available');
      }
    } catch (e) {
      debugPrint('❌ Error loading saved form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.archive_outlined, size: 24),
            SizedBox(width: 8),
            Text('Saved Forms'),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadSavedForms,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          if (_savedForms.isNotEmpty)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'clear_all') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Forms'),
                      content: const Text(
                        'Are you sure you want to delete all saved forms? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      await _savedFormsService.clearAllSavedForms();
                      await _loadSavedForms();
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('All forms cleared')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Error clearing forms: $e')),
                        );
                      }
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedForms.isEmpty
          ? _buildEmptyState()
          : _buildFormsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Saved Forms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save forms from the preview page to access them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedForms.length,
      itemBuilder: (context, index) {
        final form = _savedForms[index];
        return _buildFormCard(form);
      },
    );
  }

  Widget _buildFormCard(SavedFormModel form) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _loadSavedForm(form),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (form.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            form.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'load',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Load Form'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'load') {
                        _loadSavedForm(form);
                      } else if (value == 'delete') {
                        _deleteSavedForm(form);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Saved ${dateFormat.format(form.savedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.source, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'From: ${form.originalConfigKey}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_getComponentsCount(form)} components',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getComponentsCount(SavedFormModel form) {
    if (form.customFormData != null) {
      final customData = form.customFormData!;
      final components = customData['components'] as List<dynamic>? ?? [];
      return components.length;
    } else if (form.formData != null) {
      return form.formData!.components.length;
    } else {
      throw Exception('No form data available');
    }
  }
}
