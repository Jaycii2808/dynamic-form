import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/domain/services/form_template_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:dynamic_form_bi/presentation/widgets/form_library_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFormScreen extends StatefulWidget {
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
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  @override
  Widget build(BuildContext context) {
    return _DynamicFormContent(
      configKey: widget.configKey,
      title: widget.title,
      onAction: widget.onAction,
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
  void initState() {
    super.initState();

    context
        .read<DynamicFormBloc>()
        .add(LoadDynamicFormPageEvent(configKey: widget.configKey));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        if (state is DynamicFormError) {
          debugPrint('Error occurred: ${state.errorMessage}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred')));
        }
      },
      builder: (context, state) {
        if (state is DynamicFormLoading || state is DynamicFormInitial) {
          return _buildLoadingPage();
        }
        if (state is DynamicFormSuccess) {
          return _buildPage(state.page!);
        } else if (state is DynamicFormError) {
          return _buildErrorPage(state.errorMessage!);
        } else {
          return _buildEmptyPage();
        }
      },
    );
  }

  Widget _buildPage(DynamicFormPageModel page) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              page.title.isNotEmpty
                  ? page.title
                  : (widget.title ?? 'Dynamic Form'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  context.read<DynamicFormBloc>().add(
                        RefreshDynamicFormEvent(configKey: widget.configKey),
                      );
                },
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _showSaveTemplateDialog(page),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.grey[900],
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (var component in page.components)
                            DynamicFormRenderer(component: component),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Lưu form template',
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () => _showSaveTemplateDialog(page),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black45,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.library_books),
                              label: const Text('Form Library',
                                  overflow: TextOverflow.ellipsis),
                              onPressed: _showFormLibrary,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black45,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveTemplateDialog(DynamicFormPageModel page) {
    final nameController = TextEditingController(text: page.title);
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lưu Form Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên template',
                  hintText: 'Nhập tên cho form template',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả ngắn gọn về form này',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(
                      content: Text('Vui lòng nhập tên template')));
                  return;
                }
                _saveFormTemplate(
                    page, name, descriptionController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _saveFormTemplate(
      DynamicFormPageModel page, String name, String description) {
    final formTemplateService = FormTemplateService();

    final success = formTemplateService.saveFormTemplate(
      name: name,
      description: description,
      originalConfigKey: widget.configKey,
      formData: page,
      metadata: {
        'componentsCount': page.components.length,
        'hasValidation': page.components.any((c) => c.validation != null),
        'componentTypes':
            page.components.map((c) => c.type.toJson()).toSet().toList(),
        'formLayoutFormat': true,
      },
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template "$name" đã được lưu thành công!'),
          backgroundColor: Colors.green,
          action:
              SnackBarAction(label: 'Xem', onPressed: () => _showFormLibrary()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi khi lưu template!'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showFormLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FormLibraryDialog(
        onLoad: (template) => _loadFormTemplate(template),
        onPreview: (template) => _previewFormTemplate(template),
        onDelete: (template) async {},
      ),
    );
  }

  void _loadFormTemplate(FormTemplateModel template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicFormScreen(
          configKey: template.id,
          title: template.name,
          onAction: (formData) {
            debugPrint('Form submitted with data: $formData');
          },
        ),
      ),
    );
  }

  void _previewFormTemplate(FormTemplateModel template) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Preview: ${template.name}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${template.description}'),
                  const SizedBox(height: 16),
                  Text('Components: ${template.formData.components.length}'),
                  const SizedBox(height: 8),
                  Text('Created: ${_formatDate(template.createdAt)}'),
                  const SizedBox(height: 8),
                  Text('Updated: ${_formatDate(template.updatedAt)}'),
                  const SizedBox(height: 16),
                  const Text('Components:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...template.formData.components.map(
                    (component) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${component.type.toJson()}: ${component.config['label'] ?? component.id}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng')),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoadingPage() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Form...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Config: ${widget.configKey}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Fetching from Remote Config',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w400,
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
            Text('No UI Components Found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Add JSON configuration to Firebase Remote Config\nwith key "${widget.configKey}" to render UI components',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Refresh',
                    style: TextStyle(color: Colors.white)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
