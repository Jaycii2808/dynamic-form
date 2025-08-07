import 'dart:convert';

import 'package:dynamic_form_bi/core/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/screens/multi_screen/preview_multipage_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/dialogs/email_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dynamic_form_bi/presentation/screens/shared_form_screen.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart'; // Added import for UserFormsService
import 'package:dynamic_form_bi/data/models/validation/composite_validation_model.dart';
import 'package:dynamic_form_bi/data/models/validation/required_validation.dart';

// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

class FormBuilderPreviewScreen extends StatefulWidget {
  final FormBuilderModel formBuilderModel;

  const FormBuilderPreviewScreen({
    super.key,
    required this.formBuilderModel,
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
      debugPrint(
        '🔄 [FormBuilderPreviewScreen] Saving user form: ${widget.formBuilderModel.name}',
      );

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

      // Save to Firebase using UserFormsService
      final userFormsService = UserFormsService();
      final formId = await userFormsService.saveUserForm(
        formBuilderModel: widget.formBuilderModel,
        userId: 'user001', // Default user ID
      );

      debugPrint(
        '✅ [FormBuilderPreviewScreen] User form saved with ID: $formId',
      );

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Form saved successfully! You can find it in My Forms.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] Error saving user form: $e');

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] Form validation passed, proceeding with share',
      );

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

      debugPrint('Saving form to Firestore: $formName');
      debugPrint('Recipient email: ${emailData['email']}');
      debugPrint('Recipient name: ${emailData['name']}');

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
        Navigator.of(context).pop();
      }

      // Show success dialog with options
      _showShareSuccessDialog(shareableLink, formId, jsonOutput);
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        debugPrint('Error saving form to Firestore: $e');
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
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Starting form validation for share',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] Form validation completed successfully',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] Validation error: $e');
      return ValidationResult(
        isValid: false,
        errorMessage: 'Validation error: ${e.toString()}',
      );
    }
  }

  // Validate individual component
  ValidationResult _validateComponent(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating component: ${component.id} - ${component.type}',
    );

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
      if (component.type.toString() == 'FormTypeEnum.textFieldFormType' ||
          component.type.toString() == 'FormTypeEnum.textAreaFormType' ||
          component.type.toString() == 'FormTypeEnum.dropdownFormType') {
        if (config.placeholder == null || config.placeholder!.trim().isEmpty) {
          debugPrint(
            '⚠️ [FormBuilderPreviewScreen] Component "${component.id}" has no placeholder',
          );
        }
      }

      // Component-specific validation
      switch (component.type.toString()) {
        case 'FormTypeEnum.textFieldFormType':
          return _validateTextField(component);
        case 'FormTypeEnum.dropdownFormType':
          return _validateDropdown(component);
        case 'FormTypeEnum.textAreaFormType':
          return _validateTextArea(component);
        case 'FormTypeEnum.dateTimePickerFormType':
          return _validateDateTimePicker(component);
        case 'FormTypeEnum.dateTimeRangePickerFormType':
          return _validateDateTimeRangePicker(component);
        case 'FormTypeEnum.switchFormType':
          return _validateSwitch(component);
        case 'FormTypeEnum.selectorButtonFormType':
          return _validateSelectorButton(component);
        default:
          // For other components, just do basic validation
          debugPrint(
            '⚠️ [FormBuilderPreviewScreen] Unknown component type: ${component.type}, using basic validation',
          );
          return _validateBasicComponent(component);
      }
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] Component validation error: $e');
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Component "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate dropdown component specifically
  ValidationResult _validateDropdown(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating dropdown: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] Dropdown "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] Dropdown validation error: $e');
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Dropdown "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate TextField component (existing logic)
  ValidationResult _validateTextField(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating TextField: ${component.id}',
    );

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
        debugPrint(
          '⚠️ [FormBuilderPreviewScreen] TextField "${component.id}" has no placeholder',
        );
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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] TextField "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] TextField validation error: $e');
      return ValidationResult(
        isValid: false,
        errorMessage:
            'TextField "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate TextArea component
  ValidationResult _validateTextArea(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating TextArea: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] TextArea "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] TextArea validation error: $e');
      return ValidationResult(
        isValid: false,
        errorMessage:
            'TextArea "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate DateTimePicker component
  ValidationResult _validateDateTimePicker(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating DateTimePicker: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] DateTimePicker "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint(
        '❌ [FormBuilderPreviewScreen] DateTimePicker validation error: $e',
      );
      return ValidationResult(
        isValid: false,
        errorMessage:
            'DateTimePicker "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate DateTimeRangePicker component
  ValidationResult _validateDateTimeRangePicker(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating DateTimeRangePicker: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] DateTimeRangePicker "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint(
        '❌ [FormBuilderPreviewScreen] DateTimeRangePicker validation error: $e',
      );
      return ValidationResult(
        isValid: false,
        errorMessage:
            'DateTimeRangePicker "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate Switch component
  ValidationResult _validateSwitch(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating Switch: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] Switch "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint('❌ [FormBuilderPreviewScreen] Switch validation error: $e');
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Switch "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate SelectorButton component
  ValidationResult _validateSelectorButton(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating SelectorButton: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] SelectorButton "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint(
        '❌ [FormBuilderPreviewScreen] SelectorButton validation error: $e',
      );
      return ValidationResult(
        isValid: false,
        errorMessage:
            'SelectorButton "${component.id}" validation error: ${e.toString()}',
      );
    }
  }

  // Validate basic component (fallback for other types)
  ValidationResult _validateBasicComponent(DynamicFormModel component) {
    debugPrint(
      '🔍 [FormBuilderPreviewScreen] Validating basic component: ${component.id}',
    );

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

      debugPrint(
        '✅ [FormBuilderPreviewScreen] Basic component "${component.id}" validation passed',
      );
      return ValidationResult(isValid: true);
    } catch (e) {
      debugPrint(
        '❌ [FormBuilderPreviewScreen] Basic component validation error: $e',
      );
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
            onPressed: () => Navigator.of(context).pop(),
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
                Navigator.of(context).pop(); // Close dialog
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
              onPressed: () => Navigator.of(context).pop(),
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
      debugPrint('Error opening browser link: $e');
      //if contet mounted
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final parameterName = parameterNameController.text.trim();
              if (parameterName.isNotEmpty) {
                Navigator.of(context).pop();
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Navigate to the shared form screen
  void _navigateToSharedForm(String formId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SharedFormScreen(formId: formId),
      ),
    );
  }
}
