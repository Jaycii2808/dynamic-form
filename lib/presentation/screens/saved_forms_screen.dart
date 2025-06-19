import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';
import 'package:dynamic_form_bi/data/models/text_input_model.dart';
import 'package:dynamic_form_bi/presentation/screens/text_input_screen.dart';

class SavedFormsScreen extends StatelessWidget {
  const SavedFormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forms = FormMemoryRepository.getAllForms();

    return Scaffold(
      appBar: AppBar(title: const Text('Các form đã lưu')),
      body: forms.isEmpty
          ? const Center(child: Text('Chưa có form nào được lưu!'))
          : ListView.builder(
              itemCount: forms.length,
              itemBuilder: (context, index) {
                final form = forms[index];
                final id = form['id_form'] ?? form['pageId'] ?? 'Không có id';
                final title = form['title'] ?? 'Không có tiêu đề';
                return ListTile(
                  title: Text(title),
                  subtitle: Text('ID: $id'),
                  onTap: () {
                    // Parse lại thành TextInputScreenModel
                    final model = TextInputScreenModel.fromJson(form);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TextInputScreen(
                          title: model.title,
                          onAction: null,
                          // truyền model vào nếu TextInputScreen hỗ trợ, nếu không thì dùng remote config service tạm
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Form: $title'),
                        content: SingleChildScrollView(
                          child: SelectableText(form.toString()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
