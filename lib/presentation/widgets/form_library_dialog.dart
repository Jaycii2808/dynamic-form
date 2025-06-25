import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/domain/services/form_template_service.dart';
import 'package:flutter/material.dart';

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
                hintText: 'Tìm kiếm template...',
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
                      'Chưa có template nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lưu form đầu tiên để bắt đầu!',
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
                                  '${template.formData.components.length} trường',
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'load') {
                              Navigator.of(context).pop();
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                              widget.onLoad?.call(template);
                            } else if (value == 'preview') {
                              widget.onPreview?.call(template);
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: Text(
                                    'Bạn có chắc muốn xóa template "${template.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Xóa'),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Template "${template.name}" đã được xóa',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lỗi khi xóa template'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'load',
                              child: Row(
                                children: [
                                  Icon(Icons.play_arrow),
                                  SizedBox(width: 8),
                                  Text('Load'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'preview',
                              child: Row(
                                children: [
                                  Icon(Icons.preview),
                                  SizedBox(width: 8),
                                  Text('Preview'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
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
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Đóng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
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
