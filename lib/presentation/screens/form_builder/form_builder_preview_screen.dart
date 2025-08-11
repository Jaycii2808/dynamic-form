import 'dart:convert';

import 'package:dynamic_form_bi/core/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/screens/preview_page_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/dialogs/email_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dynamic_form_bi/presentation/screens/shared_form_screen.dart';
import 'package:go_router/go_router.dart';
// Added import for UserFormsService
import 'package:dynamic_form_bi/data/models/validation/composite_validation_model.dart';
import 'package:dynamic_form_bi/data/models/validation/required_validation.dart';
import 'package:dynamic_form_bi/data/models/validation/short_answer_validation_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

class FormBuilderPreviewScreen extends StatefulWidget {
  static const String routeName = '/form-builder-preview';
  final FormBuilderModel formBuilderModel;
  final bool isEditing;

  const FormBuilderPreviewScreen({
    super.key,
    required this.formBuilderModel,
    this.isEditing = false,
  });

  @override
  State<FormBuilderPreviewScreen> createState() =>
      _FormBuilderPreviewScreenState();
}

class _FormBuilderPreviewScreenState extends State<FormBuilderPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ComponentValuesModel componentValues = ComponentValuesModel.empty();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Preview: ${widget.formBuilderModel.name}'),
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Form Preview', icon: Icon(Icons.visibility)),
          Tab(text: 'Multi-Page JSON', icon: Icon(Icons.pages)),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFormPreviewTab(),
        _buildMultiPageJsonOutputTab(),
      ],
    );
  }

  Widget _buildFormPreviewTab() {
    // Convert FormBuilderModel pages to DynamicFormPageModel format
    final dynamicPages = widget.formBuilderModel.pages.map((page) {
      return DynamicFormPageModel(
        pageId: page.pageId,
        title: page.title,
        order: page.order,
        components: page.components,
      );
    }).toList();

    return Stack(
      children: [
        PreviewPageScreen(
          pages: dynamicPages,
          allComponentValues: componentValues,
        ),
        // Floating action buttons
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save Form button
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: FloatingActionButton.extended(
                  heroTag: 'save_form_button',
                  onPressed: () => _saveUserForm(),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Form'),
                ),
              ),
              // Share Form button
              FloatingActionButton.extended(
                heroTag: 'share_form_button',
                onPressed: () => _openActualDynamicForm(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Share Form'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Save user form to Firebase
  void _saveUserForm() async {
    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Decide Update vs Save
      final userFormsBloc = context.read<UserFormsBloc>();
      final formId = widget.formBuilderModel.formId;
      final isEditing = widget.isEditing;

      if (isEditing) {
        // Try to update existing by formId; if fails, fallback to save
        try {
          userFormsBloc.add(
            UpdateUserFormEvent(
              formId: formId,
              formBuilderModel: widget.formBuilderModel,
              userId: 'user001',
            ),
          );
        } catch (_) {
          userFormsBloc.add(
            SaveUserFormEvent(
              formBuilderModel: widget.formBuilderModel,
              userId: 'user001',
            ),
          );
        }
      } else {
        userFormsBloc.add(
          SaveUserFormEvent(
            formBuilderModel: widget.formBuilderModel,
            userId: 'user001',
          ),
        );
      }

      if (mounted) {
        // Close loading dialog
        context.pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Form updated successfully!'
                  : 'Form saved successfully! You can find it in My Forms.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        context.pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving form: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Open actual dynamic form multiscreen with current data
  void _openActualDynamicForm() async {
    try {
      // Validate form before sharing
      final validationResult = _validateFormBeforeShare();
      if (!validationResult.isValid) {
        _showValidationErrorDialog(validationResult.errorMessage!);
        return;
      }

      // Show email input dialog first
      final emailData = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const EmailInputDialog(),
      );

      if (emailData == null) {
        // User cancelled the dialog
        return;
      }
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      // Show loading dialog

      // Convert current form to JSON
      final jsonOutput = widget.formBuilderModel.toExportMultiPageJson();
      final formName = widget.formBuilderModel.name;

      // Logging removed; use Bloc Observer
      // Save to Firestore and get form ID
      final firestoreService = FirestoreFormService();
      final formId = await firestoreService.saveSharedForm(
        formData: jsonOutput,
        formName: formName,
        recipientEmail: emailData['email'],
        recipientName: emailData['name'],
      );

      // Generate shareable link
      final shareableLink = firestoreService.generateFormShareLink(formId);
      if (mounted) {
        // Close loading dialog
        context.pop();
      }

      // Show success dialog with options
      _showShareSuccessDialog(shareableLink, formId, jsonOutput);
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        context.pop();
        // Logging removed; use Bloc Observer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving form: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Validate form before sharing
  ValidationResult _validateFormBeforeShare() {
    // Logging removed; use Bloc Observer

    try {
      final pages = widget.formBuilderModel.pages;
      if (pages.isEmpty) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Form must have at least one page',
        );
      }

      for (final page in pages) {
        final components = page.components;
        if (components.isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Page "${page.title}" must have at least one component',
          );
        }

        for (final component in components) {
          // Check all components that need validation
          final validationResult = _validateComponent(component);
          if (!validationResult.isValid) {
            return validationResult;
          }
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage: 'Validation error: ${e.toString()}',
      );
    }
  }

  // Validate individual component
  ValidationResult _validateComponent(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Component "${component.id}" has no configuration',
        );
      }

      // Check required fields for all components
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required component "${component.id}" must have a label',
          );
        }
      }

      // Check placeholder text for input components
      if (component.type == FormTypeEnum.textFieldFormType ||
          component.type == FormTypeEnum.textAreaFormType ||
          component.type == FormTypeEnum.dropdownFormType) {
        if (config.placeholder == null || config.placeholder!.trim().isEmpty) {
          // Logging removed; use Bloc Observer
        }
      }

      // Component-specific validation
      switch (component.type) {
        case FormTypeEnum.textFieldFormType:
          return _validateTextField(component);
        case FormTypeEnum.dropdownFormType:
          return _validateDropdown(component);
        case FormTypeEnum.shortAnswerFormType:
          return _validateShortAnswer(component);
        case FormTypeEnum.textAreaFormType:
          return _validateTextArea(component);
        case FormTypeEnum.dateTimePickerFormType:
          return _validateDateTimePicker(component);
        case FormTypeEnum.dateTimeRangePickerFormType:
          return _validateDateTimeRangePicker(component);
        case FormTypeEnum.switchFormType:
          return _validateSwitch(component);
        case FormTypeEnum.selectorButtonFormType:
          return _validateSelectorButton(component);
        case FormTypeEnum.buttonFormType:
        case FormTypeEnum.container:
        case FormTypeEnum.textFieldTagsFormType:
        case FormTypeEnum.unknown:
          // For other components, just do basic validation
          return _validateBasicComponent(component);
      }
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Component "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate dropdown component specifically
  ValidationResult _validateDropdown(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Dropdown "${component.id}" has no configuration',
        );
      }

      // Check if dropdown has label (required for all dropdowns)
      if (config.label == null || config.label!.trim().isEmpty) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Dropdown "${component.id}" must have a label',
        );
      }

      // Check if dropdown has options
      if (config.options == null || config.options!.isEmpty) {
        return ValidationResult(
          isValid: false,
          errorMessage:
              'Dropdown "${component.id}" must have at least one option',
        );
      }

      // Check if options have valid labels
      for (int i = 0; i < config.options!.length; i++) {
        final option = config.options![i];
        if (option.label.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Dropdown "${component.id}" option ${i + 1} must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Dropdown "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate short answer component specifically
  ValidationResult _validateShortAnswer(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Short answer "${component.id}" has no configuration',
        );
      }

      // Check if short answer has label (required for all short answers)
      if (config.label == null || config.label!.trim().isEmpty) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Short answer "${component.id}" must have a label',
        );
      }

      // Check validation configuration if present
      if (config.validate != null) {
        try {
          final validation = ShortAnswerValidationModel.fromJson(
            config.validate!,
          );

          // Validate regex pattern if present
          if (validation.validationType ==
                  ShortAnswerValidationType.regularExpression &&
              validation.validationValue != null &&
              validation.validationValue!.isNotEmpty) {
            try {
              RegExp(validation.validationValue!);
            } catch (e) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'Short answer "${component.id}" has invalid regex pattern',
              );
            }
          }

          // Validate number value if present
          if (validation.validationType == ShortAnswerValidationType.number &&
              validation.validationValue != null &&
              validation.validationValue!.isNotEmpty) {
            final numberValue = double.tryParse(validation.validationValue!);
            if (numberValue == null) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'Short answer "${component.id}" has invalid number value',
              );
            }
          }

          // Validate length value if present
          if (validation.validationType == ShortAnswerValidationType.length &&
              validation.validationValue != null &&
              validation.validationValue!.isNotEmpty) {
            final lengthValue = int.tryParse(validation.validationValue!);
            if (lengthValue == null || lengthValue < 0) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'Short answer "${component.id}" has invalid length value',
              );
            }
          }
        } catch (e) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Short answer "${component.id}" has invalid validation configuration: $e',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Short answer "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate TextField component (existing logic)
  ValidationResult _validateTextField(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'TextField "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required TextField "${component.id}" must have a label',
          );
        }
      }

      // Check placeholder text
      if (config.placeholder == null || config.placeholder!.trim().isEmpty) {
        // Logging removed; use Bloc Observer
      }

      // Check validation rules if present
      if (component.validation != null) {
        final validation = component.validation!;

        // Check if it's a composite validation
        if (validation is CompositeValidationModel) {
          final requiredValidation = validation.required;
          if (requiredValidation != null && requiredValidation.isRequired) {
            if (config.label == null || config.label!.trim().isEmpty) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'Required TextField "${component.id}" must have a label',
              );
            }
          }
        }

        // Check if it's a required validation
        if (validation is RequiredValidation) {
          if (validation.isRequired) {
            if (config.label == null || config.label!.trim().isEmpty) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'Required TextField "${component.id}" must have a label',
              );
            }
          }
        }
      }

      // Check input types validation if present
      if (component.inputTypes != null) {
        final inputTypes = component.inputTypes!;

        // Check text validation
        if (inputTypes.text != null) {
          final textValidation = inputTypes.text!;
          if (textValidation.minLength != null &&
              textValidation.minLength! < 0) {
            return ValidationResult(
              isValid: false,
              errorMessage:
                  'TextField "${component.id}" has invalid minimum length',
            );
          }
          if (textValidation.maxLength != null &&
              textValidation.maxLength! < 0) {
            return ValidationResult(
              isValid: false,
              errorMessage:
                  'TextField "${component.id}" has invalid maximum length',
            );
          }
          if (textValidation.minLength != null &&
              textValidation.maxLength != null) {
            if (textValidation.minLength! > textValidation.maxLength!) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'TextField "${component.id}" minimum length cannot be greater than maximum length',
              );
            }
          }
          if (textValidation.regex != null &&
              textValidation.regex!.isNotEmpty) {
            try {
              RegExp(textValidation.regex!);
            } catch (e) {
              return ValidationResult(
                isValid: false,
                errorMessage:
                    'TextField "${component.id}" has invalid regex pattern',
              );
            }
          }
        }

        // Check email validation
        if (inputTypes.email != null) {
          final emailValidation = inputTypes.email!;
          if (emailValidation.minLength != null &&
              emailValidation.minLength! < 0) {
            return ValidationResult(
              isValid: false,
              errorMessage:
                  'Email field "${component.id}" has invalid minimum length',
            );
          }
          if (emailValidation.maxLength != null &&
              emailValidation.maxLength! < 0) {
            return ValidationResult(
              isValid: false,
              errorMessage:
                  'Email field "${component.id}" has invalid maximum length',
            );
          }
        }

        // Check password validation
        if (inputTypes.password != null) {
          final passwordValidation = inputTypes.password!;
          if (passwordValidation.minLength != null &&
              passwordValidation.minLength! < 0) {
            return ValidationResult(
              isValid: false,
              errorMessage:
                  'Password field "${component.id}" has invalid minimum length',
            );
          }
          if (passwordValidation.maxLength != null &&
              passwordValidation.maxLength! < 0) {
            return ValidationResult(
              isValid: false,
              errorMessage:
                  'Password field "${component.id}" has invalid maximum length',
            );
          }
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'TextField "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate TextArea component
  ValidationResult _validateTextArea(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'TextArea "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required TextArea "${component.id}" must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'TextArea "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate DateTimePicker component
  ValidationResult _validateDateTimePicker(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'DateTimePicker "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required DateTimePicker "${component.id}" must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'DateTimePicker "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate DateTimeRangePicker component
  ValidationResult _validateDateTimeRangePicker(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage:
              'DateTimeRangePicker "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required DateTimeRangePicker "${component.id}" must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'DateTimeRangePicker "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate Switch component
  ValidationResult _validateSwitch(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Switch "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage: 'Required Switch "${component.id}" must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Switch "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate SelectorButton component
  ValidationResult _validateSelectorButton(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'SelectorButton "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required SelectorButton "${component.id}" must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'SelectorButton "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate basic component (fallback for other types)
  ValidationResult _validateBasicComponent(DynamicFormModel component) {
    // Logging removed; use Bloc Observer

    try {
      final config = component.config;
      if (config == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Component "${component.id}" has no configuration',
        );
      }

      // Check required fields
      if (config.isRequired == true) {
        if (config.label == null || config.label!.trim().isEmpty) {
          return ValidationResult(
            isValid: false,
            errorMessage:
                'Required component "${component.id}" must have a label',
          );
        }
      }

      // Logging removed; use Bloc Observer
      return ValidationResult(isValid: true);
    } catch (e) {
      // Logging removed; use Bloc Observer
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Component "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Show validation error dialog
  void _showValidationErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Form Validation Error',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showShareSuccessDialog(
    String shareableLink,
    String formId,
    Map<String, dynamic> jsonOutput,
  ) {
    showDialog(
      context: context,
      builder: (context) => Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Form Shared Successfully!',
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
                'Your form is now shareable:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shareableLink,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _copyLinkToClipboard(shareableLink),
                      child: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Form ID: $formId',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          actions: [
            Row(
              spacing: 15,
              //space betwween
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _copyLinkToClipboard(shareableLink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Copy Link',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openBrowserLink(shareableLink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Open in Browser',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Add button to navigate directly to shared form
            GestureDetector(
              onTap: () {
                context.pop(); // Close dialog
                _navigateToSharedForm(formId);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Open Form in App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLinkToClipboard(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openBrowserLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $link';
      }
    } catch (e) {
      // Logging removed; use Bloc Observer
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMultiPageJsonOutputTab() {
    final jsonOutput = widget.formBuilderModel.toExportMultiPageJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonOutput);

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pages, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'JSON Export',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Export to Firebase Remote Config button
              GestureDetector(
                onTap: () => _exportToFirebaseRemoteConfig(jsonString),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_upload, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text(
                        'Export',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonString),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text(
                        'Copy',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: const Text(
              'Auto-generated navigation with next_page/previous_page',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Export to Firebase Remote Config with parameter naming
  void _exportToFirebaseRemoteConfig(String jsonString) {
    final TextEditingController parameterNameController =
        TextEditingController();

    // Suggest a default parameter name
    final defaultName =
        'form_${widget.formBuilderModel.name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    parameterNameController.text = defaultName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Export to Firebase Remote Config',
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
              'Enter parameter name for Firebase Remote Config:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: parameterNameController,
              decoration: const InputDecoration(
                labelText: 'Parameter Name',
                hintText: 'e.g., my_form_config',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Note: You need to manually add this parameter to Firebase Console Remote Config with the copied JSON value.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
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
              final parameterName = parameterNameController.text.trim();
              if (parameterName.isNotEmpty) {
                context.pop();
                _performFirebaseExport(parameterName, jsonString);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a parameter name'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Export',
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
  }

  // Perform the actual Firebase export process
  void _performFirebaseExport(String parameterName, String jsonString) {
    // Copy JSON to clipboard
    _copyToClipboard(jsonString);

    // Show instructions dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Flexible(
              child: Text('Firebase Export Instructions'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parameter Name: $parameterName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Steps to complete the export:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Go to Firebase Console → Remote Config'),
            const Text('2. Click "Add parameter"'),
            Text('3. Set Parameter key: $parameterName'),
            const Text('4. Paste the JSON (already copied to clipboard)'),
            const Text('5. Click "Publish changes"'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'JSON has been copied to clipboard!',
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
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Navigate to the shared form screen
  void _navigateToSharedForm(String formId) {
    context.replaceNamed(
      SharedFormScreen.routeName,
      pathParameters: {'formId': formId},
    );
  }
}
