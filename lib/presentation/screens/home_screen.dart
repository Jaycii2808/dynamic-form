import 'package:dynamic_form_bi/presentation/screens/watch_components_forms/existing_forms_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/saved_forms_screen.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_state.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserFormsBloc _userFormsBloc;

  @override
  void initState() {
    super.initState();
    _userFormsBloc = UserFormsBloc(
      userFormsService: UserFormsService(),
      remoteConfigService: RemoteConfigService(),
    );

    // Load user forms and templates
    _userFormsBloc.add(const LoadUserFormsEvent(userId: 'user001'));
    _userFormsBloc.add(const LoadFormTemplatesEvent());
  }

  @override
  void dispose() {
    _userFormsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _userFormsBloc,
      child: BlocListener<UserFormsBloc, UserFormsState>(
        listener: (context, state) {
          if (state is UserFormsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is UserFormsSuccess) {
            // Handle success states if needed
            debugPrint(
              '✅ [HomeScreen] UserFormsBloc state updated successfully',
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                _buildUserFormsSection(),
                _buildFormTemplatesSection(),
                _buildFeaturesSection(),
                _buildHowToUseSection(),
              ],
            ),
          ),
          floatingActionButton: _buildMainActionButton(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dynamic Form Builder',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Create Amazing Forms',
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
        _buildExistingFormsButton(),
        _buildSavedFormsButton(),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.dynamic_form,
              size: 60,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create Dynamic Forms',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Build beautiful, responsive forms with our intuitive form builder',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormBuilderScreen(
                    existingForm: null,
                    isEditing: false,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Start Building',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFormsSection() {
    return BlocBuilder<UserFormsBloc, UserFormsState>(
      builder: (context, state) {
        if (state is UserFormsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserFormsSuccess) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Forms (user001)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.userForms.isEmpty)
                  const Center(
                    child: Text(
                      'You have no forms yet. Start building one!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
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
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(10),
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
                                    form['name'] ?? 'Untitled Form',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Created: ${_formatDate(form['createdAt'])}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editUserForm(form),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              tooltip: 'Edit Form',
                            ),
                            IconButton(
                              onPressed: () => _deleteUserForm(form['formId']),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Form',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildFormTemplatesSection() {
    return BlocBuilder<UserFormsBloc, UserFormsState>(
      builder: (context, state) {
        if (state is UserFormsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserFormsSuccess) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Form Templates',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.formTemplates.isEmpty)
                  const Center(
                    child: Text(
                      'No form templates available yet. Check back later!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
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
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
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
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.description,
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template['name'] ?? 'Untitled Template',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template['description'] ?? 'Form template',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _previewTemplate(template),
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                              ),
                              tooltip: 'Preview Template',
                            ),
                            IconButton(
                              onPressed: () =>
                                  _createFormFromTemplate(template),
                              icon: const Icon(Icons.add, color: Colors.green),
                              tooltip: 'Create Form from Template',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.drag_indicator,
            title: 'Drag & Drop Interface',
            description:
                'Intuitive form building with drag and drop components',
          ),
          _buildFeatureItem(
            icon: Icons.phone_android,
            title: 'Responsive Design',
            description: 'Forms that work perfectly on all devices',
          ),
          _buildFeatureItem(
            icon: Icons.save,
            title: 'Save & Share',
            description: 'Save your forms and share them with others',
          ),
          _buildFeatureItem(
            icon: Icons.cloud_sync,
            title: 'Cloud Sync',
            description: 'Access your forms from anywhere with cloud storage',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToUseSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Use',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildStepItem(
            number: '1',
            title: 'Create New Form',
            description: 'Tap the "Start Building" button to create a new form',
          ),
          _buildStepItem(
            number: '2',
            title: 'Add Components',
            description:
                'Drag and drop form components like text fields, checkboxes, etc.',
          ),
          _buildStepItem(
            number: '3',
            title: 'Configure Settings',
            description: 'Set validation rules, styling, and form behavior',
          ),
          _buildStepItem(
            number: '4',
            title: 'Save & Test',
            description:
                'Save your form and test it to ensure everything works',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton.extended(
        heroTag: 'create_form_button',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormBuilderScreen(
                existingForm: null,
                isEditing: false,
              ),
            ),
          );
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

  Widget _buildExistingFormsButton() {
    return Builder(
      builder: (context) => IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExistingFormsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.list_alt),
        tooltip: 'Existing Forms',
      ),
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

  void _editUserForm(Map<String, dynamic> form) {
    try {
      debugPrint('🔄 [HomeScreen] Edit user form: ${form['name']}');

      // Convert form data back to FormBuilderModel
      if (form['formData'] != null) {
        final formData = form['formData'] as Map<String, dynamic>;
        final formBuilderModel = FormBuilderModel.fromJson(formData);

        debugPrint(
          '🔄 [HomeScreen] FormBuilderModel created: ${formBuilderModel.name}',
        );
        debugPrint(
          '🔄 [HomeScreen] Form has ${formBuilderModel.pages.length} pages',
        );

        // Navigate to FormBuilderScreen with existing form data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormBuilderScreen(
              existingForm: formBuilderModel,
              isEditing: true,
            ),
          ),
        );
      } else {
        debugPrint('❌ [HomeScreen] Form data is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Form data not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error editing user form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error editing form: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteUserForm(String? formId) {
    if (formId != null) {
      debugPrint('🔄 [HomeScreen] Delete user form: $formId');

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteForm(formId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _confirmDeleteForm(String formId) {
    try {
      debugPrint('🔄 [HomeScreen] Confirming delete for form: $formId');

      // Dispatch delete event to Bloc
      _userFormsBloc.add(
        DeleteUserFormEvent(
          formId: formId,
          userId: 'user001',
        ),
      );

      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting form...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error deleting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previewTemplate(Map<String, dynamic> template) {
    try {
      debugPrint('🔄 [HomeScreen] Preview template: ${template['name']}');

      // Show template preview dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createFormFromTemplate(template);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Form'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error previewing template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error previewing template: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            ...pages.map<Widget>((page) {
              final pageTitle = page['title'] ?? 'Untitled Page';
              final components = page['components'] as List<dynamic>? ?? [];
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Text(
                  '• $pageTitle (${components.length} components)',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }),
          ],
        ],
      );
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error building form structure preview: $e');
      return const Text('Error loading form structure');
    }
  }

  void _createFormFromTemplate(Map<String, dynamic> template) {
    try {
      debugPrint(
        '🔄 [HomeScreen] Create form from template: ${template['name']}',
      );

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmCreateFormFromTemplate(template);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Form'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error creating form from template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating form from template: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmCreateFormFromTemplate(Map<String, dynamic> template) {
    try {
      debugPrint(
        '🔄 [HomeScreen] Confirming create form from template: ${template['name']}',
      );

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating form from template...'),
            ],
          ),
        ),
      );

      // Dispatch create form from template event to Bloc
      _userFormsBloc.add(
        CreateUserFormFromTemplateEvent(
          templateData: template['formData'] ?? {},
          templateName: template['name'] ?? 'Untitled Template',
          userId: 'user001',
        ),
      );

      // Close loading dialog after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Form created from template: ${template['name']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error creating form from template: $e');

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating form from template: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
