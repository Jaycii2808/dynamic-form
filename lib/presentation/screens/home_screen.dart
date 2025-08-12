import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<UserFormsBloc>();
      bloc.add(const LoadUserFormsEvent(userId: 'user001'));
      bloc.add(const LoadFormTemplatesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserFormsBloc, UserFormsState>(
      listener: (context, state) {
        if (state is UserFormsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Prevent background navigation when HomeScreen is not the top route
        final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
        if (!isCurrentRoute) return;

        // Navigate for imported form or open form
        if (state.openFormId != null && state.openFormId!.isNotEmpty) {
          context.push('${FormBuilderScreen.routePath}/${state.openFormId}');
          context.read<UserFormsBloc>().add(const ClearOpenFormEvent());
        } else if (state.openFormModel != null) {
          context.push(
            FormBuilderScreen.routePath,
            extra: state.openFormModel,
          );
          context.read<UserFormsBloc>().add(const ClearOpenFormEvent());
        } else if (state.importedForm != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form imported successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                BlocBuilder<UserFormsBloc, UserFormsState>(
                  builder: (context, state) {
                    final imported = state is UserFormsSuccess
                        ? state.importedForm
                        : null;
                    if (imported == null) return const SizedBox.shrink();
                    return _buildImportedFormSection(imported);
                  },
                ),
                _buildFormsSection(),
              ],
            ),
          ),
          floatingActionButton: _buildMainActionButton(),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F2937),
            Color(0xFF111827),
          ],
        ),
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.dynamic_form,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Create Dynamic Forms',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Build beautiful, responsive forms with our intuitive form builder',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildHeroButtonsRow(),
        ],
      ),
    );
  }

  Widget _buildFormsSection() {
    return BlocBuilder<UserFormsBloc, UserFormsState>(
      builder: (context, state) {
        if (state is UserFormsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is UserFormsSuccess) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildUserFormsSubsection(state),
                const SizedBox(height: 32),
                _buildFormTemplatesSubsection(state),
              ],
            ),
          );
        } else {
          return const Text("Error somewhere in _buildFormsSection");
        }
      },
    );
  }

  Widget _buildUserFormsSubsection(UserFormsSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            const Icon(Icons.description, color: Colors.blue, size: 20),
            const Text(
              'My Forms',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '(${state.userForms.length})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.userForms.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'You have no forms yet. Start building one!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.userForms.length,
            itemBuilder: (context, index) {
              final form = state.userForms[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            form['name'] ?? 'Untitled Form',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Created: ${_formatDate(form['createdAt'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<UserFormsBloc>().add(
                          OpenFormForEditEvent(form: form),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'Edit Form',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () => _deleteUserForm(form['formId']),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: 'Delete Form',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFormTemplatesSubsection(UserFormsSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Form Templates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '(${state.formTemplates.length})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.formTemplates.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'No form templates available yet. Check back later!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.formTemplates.length,
            itemBuilder: (context, index) {
              final template = state.formTemplates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template['name'] ?? 'Untitled Template',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            template['description'] ?? 'Form template',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            _buildTemplatePreviewDialog(template),
                      ),
                      icon: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'Preview Template',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () => _createFormFromTemplate(template),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.green,
                        size: 20,
                      ),
                      tooltip: 'Create Form from Template',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMainActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton.extended(
        heroTag: 'create_form_button',
        onPressed: () {
          context.push(FormBuilderScreen.routePath);
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Form',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is DateTime) {
        return DateFormat('MM/dd/yyyy HH:mm').format(date);
      } else if (date is String) {
        return DateFormat('MM/dd/yyyy HH:mm').format(DateTime.parse(date));
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  Widget _buildDeleteFormDialog(String formId) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Delete Form'),
        ],
      ),
      content: const Text(
        'Are you sure you want to delete this form? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        GestureDetector(
          onTap: () {
            context.pop();
            context.read<UserFormsBloc>().add(
              DeleteUserFormEvent(
                formId: formId,
                userId: 'user001',
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deleting form...'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
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
    );
  }

  void _deleteUserForm(String? formId) {
    if (formId != null) {
      showDialog(
        context: context,
        builder: (context) => _buildDeleteFormDialog(formId),
      );
    }
  }

  Widget _buildTemplatePreviewDialog(Map<String, dynamic> template) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.visibility, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              template['name'] ?? 'Untitled Template',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            template['description'] ?? 'No description available',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Text(
              template['category'] ?? 'General',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (template['formData'] != null) ...[
            const Text(
              'Form Structure:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildFormStructurePreview(template['formData']),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Close'),
        ),
        GestureDetector(
          onTap: () {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => _createFormFromTemplate(template),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Create Form',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormStructurePreview(Map<String, dynamic> formData) {
    try {
      final pages = formData['pages'] as List<dynamic>? ?? [];
      final totalComponents = pages.fold<int>(
        0,
        (sum, page) =>
            sum + ((page['components'] as List<dynamic>?)?.length ?? 0),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ${pages.length} page${pages.length != 1 ? 's' : ''}'),
          Text(
            '• $totalComponents component${totalComponents != 1 ? 's' : ''}',
          ),
          const SizedBox(height: 8),
          if (pages.isNotEmpty) ...[
            const Text(
              'Pages:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                final pageTitle = page['title'] ?? 'Untitled Page';
                final components = page['components'] as List<dynamic>? ?? [];
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Text(
                    '• $pageTitle (${components.length} components)',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ],
      );
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error building form structure preview: $e');
      return const Text('Error loading form structure');
    }
  }

  Widget _createFormFromTemplate(Map<String, dynamic> template) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_circle, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Create Form from Template',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template: ${template['name']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            template['description'] ?? 'No description available',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This will create a copy of the template as your own form that you can edit.',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        GestureDetector(
          onTap: () {
            context.pop();
            context.read<UserFormsBloc>().add(
              CreateUserFormFromTemplateEvent(
                templateData: template['formData'] ?? {},
                templateName: template['name'] ?? 'Untitled Template',
                userId: 'user001',
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Creating form from template: ${template['name']}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Create Form',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportedFormSection(FormBuilderModel imported) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.file_download_done,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imported.name.isNotEmpty ? imported.name : 'Imported Form',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pages: ${imported.pages.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(
                  FormBuilderScreen.routePath,
                  extra: imported,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    Text(
                      'Open in Builder',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildImportJsonDialog() {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: const Text('Import JSON'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste the Multi-Page JSON exported from Form Builder.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  height: 200,
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText:
                          '{\n  "formId": "...",\n  "name": "...",\n  "pages": [ ... ]\n}',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final data = await Clipboard.getData('text/plain');
            if (data?.text != null && data!.text!.trim().isNotEmpty) {
              controller.text = data.text!.trim();
            } else {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Clipboard is empty'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(Icons.paste, size: 16, color: Colors.white),
                Text(
                  'Paste from Clipboard',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        GestureDetector(
          onTap: () {
            context.read<UserFormsBloc>().add(
              ImportFormFromJsonEvent(rawJson: controller.text),
            );
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Importing JSON...'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Import',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImportJsonDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildImportJsonDialog(),
    );
  }

  Widget _buildHeroButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeroButton(
          icon: Icons.add_circle_outline,
          label: 'Start Building',
          color: Colors.blue,
          onTap: () => context.push(FormBuilderScreen.routePath),
        ),
        _buildHeroButton(
          icon: Icons.content_paste,
          label: 'Import JSON',
          color: Colors.orange,
          onTap: _showImportJsonDialog,
        ),
      ],
    );
  }

  Widget _buildHeroButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final borderColor = color.withValues(alpha: 0.3);
    final shadowColor = color.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          spacing: 8,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
