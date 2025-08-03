import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_app_bar.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_body.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  late FormBuilderBloc formBuilderBloc;

  @override
  void initState() {
    super.initState();
    formBuilderBloc = context.read<FormBuilderBloc>();
    formBuilderBloc.add(const LoadComponentsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstPageNameDialog();
    });
  }

  void _showFirstPageNameDialog() {
    final formController = TextEditingController(text: 'Untitled form');
    final pageController = TextEditingController(text: 'Page 1');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Your Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Let\'s start by naming your form and first page:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
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
            ElevatedButton(
              onPressed: () {
                final formName = formController.text.trim();
                final pageName = pageController.text.trim();
                if (formName.isNotEmpty && pageName.isNotEmpty) {
                  formBuilderBloc.add(UpdateFormTitleEvent(formName));
                  formBuilderBloc.add(UpdateFirstPageTitleEvent(pageName));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create Form'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: formBuilderAppBar(context, formBuilderBloc),
      backgroundColor: const Color(0xFF000000),
      floatingActionButton: formBuilderFloatingActionButtons(context, formBuilderBloc),
      body: formBuilderBody(context, formBuilderBloc),
    );
  }
}