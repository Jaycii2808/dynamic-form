import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_app_bar.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_body.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_floating_action_buttons.dart'
    show formBuilderBottomNavigation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart';

class FormBuilderScreen extends StatefulWidget {
  static const String routeName = '/form-builder';
  final FormBuilderModel? existingForm;
  final bool isEditing;
  final String? editingFormId;

  const FormBuilderScreen({
    super.key,
    this.existingForm,
    this.isEditing = false,
    this.editingFormId,
  });

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  late FormBuilderBloc formBuilderBloc;

  @override
  void initState() {
    super.initState();
    formBuilderBloc = context.read<FormBuilderBloc>();

    // Always load components first
    formBuilderBloc.add(const LoadComponentsEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing) {
        if (widget.existingForm != null) {
          // Wait a bit for components to load, then load existing form
          Future.delayed(const Duration(milliseconds: 100), () {
            _loadExistingForm(widget.existingForm!);
          });
        } else if (widget.editingFormId != null &&
            widget.editingFormId!.isNotEmpty) {
          // Load existing form by ID from backend and feed into bloc
          _loadExistingFormById(widget.editingFormId!);
        } else {
          _showFirstPageNameDialog();
        }
      } else {
        //_showFirstPageNameDialog();
      }
    });
  }

  void _loadExistingForm(FormBuilderModel model) {
    try {
      debugPrint('🔄 [FormBuilderScreen] Loading existing form: ${model.name}');
      debugPrint('🔄 [FormBuilderScreen] Form has ${model.pages.length} pages');

      // Load existing form data into the bloc
      formBuilderBloc.add(LoadExistingFormEvent(model));

      debugPrint('✅ [FormBuilderScreen] Existing form loaded successfully');
    } catch (e) {
      debugPrint('❌ [FormBuilderScreen] Error loading existing form: $e');
      // Fallback to new form dialog
      _showFirstPageNameDialog();
    }
  }

  Future<void> _loadExistingFormById(String formId) async {
    try {
      debugPrint('🔄 [FormBuilderScreen] Fetching form by ID: $formId');
      final service = UserFormsService();
      final data = await service.getUserFormById(formId: formId);
      if (data == null || data['formData'] == null) {
        throw Exception('Form not found');
      }
      final formBuilderModel = FormBuilderModel.fromJson(
        Map<String, dynamic>.from(data['formData'] as Map),
      );
      if (!mounted) return;
      // Slight delay to ensure components are ready
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadExistingForm(formBuilderModel);
      });
    } catch (e) {
      debugPrint('❌ [FormBuilderScreen] Error loading form by ID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load form: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFirstPageNameDialog() {
    final formController = TextEditingController(
      text: widget.existingForm?.name ?? 'Untitled form',
    );
    final pageController = TextEditingController(
      text: widget.existingForm?.pages.isNotEmpty == true
          ? widget.existingForm!.pages.first.title
          : 'Page 1',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.isEditing ? 'Edit Your Form' : 'Create Your Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEditing
                    ? 'Update your form and first page names:'
                    : 'Let\'s start by naming your form and first page:',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: formController,
                decoration: const InputDecoration(
                  labelText: 'Form Name',
                  hintText: 'e.g., Customer Feedback, Event Registration',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pageController,
                decoration: const InputDecoration(
                  labelText: 'First Page Title',
                  hintText: 'e.g., Personal Information, Contact Details',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                final formName = formController.text.trim();
                final pageName = pageController.text.trim();
                if (formName.isNotEmpty && pageName.isNotEmpty) {
                  formBuilderBloc.add(UpdateFormTitleEvent(formName));
                  formBuilderBloc.add(UpdateFirstPageTitleEvent(pageName));
                  context.pop();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isEditing ? 'Update Form' : 'Create Form',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: formBuilderAppBar(
        context,
        formBuilderBloc,
        existingForm: widget.existingForm,
        isEditing: widget.isEditing,
      ),
      backgroundColor: const Color(0xFF000000),
      body: Column(
        children: [
          Expanded(
            child: formBuilderBody(context, formBuilderBloc),
          ),
          // Show bottom navigation only when keyboard is not open
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            formBuilderBottomNavigation(context, formBuilderBloc),
        ],
      ),
    );
  }
}
