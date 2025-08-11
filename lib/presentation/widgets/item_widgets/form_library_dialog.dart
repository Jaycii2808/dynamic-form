import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/menu_action_enum.dart';
import 'package:dynamic_form_bi/core/services/form_template_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FormLibraryDialog extends StatefulWidget {
  final void Function(FormTemplateModel template)? onLoad;
  final void Function(FormTemplateModel template)? onPreview;
  final void Function(FormTemplateModel template)? onDelete;

  const FormLibraryDialog({
    super.key,
    this.onLoad,
    this.onPreview,
    this.onDelete,
  });

  @override
  State<FormLibraryDialog> createState() => _FormLibraryDialogState();
}

class _FormLibraryDialogState extends State<FormLibraryDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<FormTemplateModel> _templates = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text.trim();
      });
    });
  }

  void _loadTemplates() {
    final service = FormTemplateService();
    setState(() {
      if (_search.isEmpty) {
        _templates = service.getAllTemplates();
      } else {
        _templates = service.searchTemplates(_search);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.library_books, color: Colors.blue, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Form Library',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_templates.length} templates',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search templates...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_templates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No templates yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Save your first form to get started!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            template.name.isNotEmpty
                                ? template.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          template.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (template.description.isNotEmpty)
                              Text(
                                template.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.widgets,
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${template.formData.components.length} fields',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(template.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<MenuAction>(
                          onSelected: (value) async {
                            if (value == MenuAction.load) {
                              context.pop();
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                              widget.onLoad?.call(template);
                            } else if (value == MenuAction.preview) {
                              widget.onPreview?.call(template);
                            } else if (value == MenuAction.delete) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete template "${template.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.pop(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final service = FormTemplateService();
                                final success = service.deleteTemplate(
                                  template.id,
                                );
                                if (success) {
                                  setState(_loadTemplates);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Template "${template.name}" has been deleted',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error deleting template',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<MenuAction>(
                              value: MenuAction.load,
                              child: Row(
                                children: [
                                  Icon(Icons.play_arrow),
                                  SizedBox(width: 8),
                                  Text('Load'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<MenuAction>(
                              value: MenuAction.preview,
                              child: Row(
                                children: [
                                  Icon(Icons.preview),
                                  SizedBox(width: 8),
                                  Text('Preview'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<MenuAction>(
                              value: MenuAction.delete,
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
