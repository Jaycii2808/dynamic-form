import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_app_bar.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_body.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FormBuilderScreen extends StatefulWidget {
  static const String routePath = '/form-builder';
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
          // Load existing form directly via Bloc
          formBuilderBloc.add(LoadExistingFormEvent(widget.existingForm!));
        } else if (widget.editingFormId != null &&
            widget.editingFormId!.isNotEmpty) {
          // Load existing form by ID via Bloc
          formBuilderBloc.add(
            LoadExistingFormByIdEvent(
              formId: widget.editingFormId!,
            ),
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _buildFirstPageNameDialog(),
          );
        }
      }
    });
  }

  Widget _buildFirstPageNameDialog() {
    final formController = TextEditingController(
      text: widget.existingForm?.name ?? 'Untitled form',
    );
    final pageController = TextEditingController(
      text: widget.existingForm?.pages.isNotEmpty == true
          ? widget.existingForm!.pages.first.title
          : 'Page 1',
    );

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormBuilderBloc, FormBuilderState>(
      listener: (context, state) {
        if (state is FormBuilderError) {
          final errorMsg = state.errorMessage ?? 'An error occurred';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          // If error loading form by ID, show dialog as fallback
          if (errorMsg.contains('Failed to load form by ID')) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildFirstPageNameDialog(),
            );
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: formBuilderAppBar(
          context,
          formBuilderBloc,
          existingForm: widget.existingForm,
          isEditing: widget.isEditing,
          editingFormId: widget.editingFormId,
        ),
        backgroundColor: const Color(0xFF000000),
        body: Column(
          children: [
            Expanded(
              child: formBuilderBody(context, formBuilderBloc),
            ),
          ],
        ),
        bottomNavigationBar: formBuilderBottomNavigation(
          context,
          formBuilderBloc,
        ),
      ),
    );
  }
}
