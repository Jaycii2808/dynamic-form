import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? componentId; // Offending component id for UI highlight

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.componentId,
  });
}

PreferredSizeWidget formBuilderAppBar(
  BuildContext context,
  FormBuilderBloc formBuilderBloc, {
  FormBuilderModel? existingForm,
  bool isEditing = false,
  String? editingFormId,
}) {
  return AppBar(
    title: BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) => _buildTitle(context, state, formBuilderBloc),
    ),
    backgroundColor: const Color(0xFF000000),
    foregroundColor: Colors.white,
    elevation: 1,
    toolbarHeight: 80,
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    ),

    actions: [
      BlocBuilder<FormBuilderBloc, FormBuilderState>(
        builder: (context, state) => _buildActionButtons(
          context,
          state,
          formBuilderBloc,
          existingForm: existingForm,
          isEditing: isEditing,
          editingFormId: editingFormId,
        ),
      ),
    ],
  );
}

Widget _buildTitle(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  final isMultiPage = state.pages.length > 1;
  final currentPageIndex = state.pages.indexWhere(
    (page) => page.pageId == state.currentPageId,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Form Title Row
      Row(
        children: [
          Flexible(
            child: _buildEditableFormTitle(context, state, formBuilderBloc),
          ),
          if (isMultiPage) ...[
            const SizedBox(width: 8),
            _buildPageIndicator(currentPageIndex, state.pages.length),
          ],
        ],
      ),
    ],
  );
}

Widget _buildEditableFormTitle(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return GestureDetector(
    onTap: () => _showEditFormTitleDialog(context, state, formBuilderBloc),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              state.formTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.edit,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

Widget _buildPageIndicator(int currentPageIndex, int totalPages) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '${currentPageIndex + 1}/$totalPages',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _buildActionButtons(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc, {
  FormBuilderModel? existingForm,
  bool isEditing = false,
  String? editingFormId,
}) {
  return IconButton(
    onPressed: () => _handleSubmitForm(
      context,
      state,
      formBuilderBloc,
      existingForm: existingForm,
      isEditing: isEditing,
      editingFormId: editingFormId,
    ),
    icon: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.preview, size: 16),
        SizedBox(width: 4),
        Icon(Icons.share, size: 16),
        SizedBox(width: 6),
        Text(
          'Share',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    ),
    style: IconButton.styleFrom(
      backgroundColor: Colors.green.shade100,
      foregroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(40, 36),
    ),
    tooltip: 'Preview & Share',
  );
}

void _showEditFormTitleDialog(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  final controller = TextEditingController(text: state.formTitle);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Form Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Form Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                formBuilderBloc.add(UpdateFormTitleEvent(newTitle));
              }
              context.pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _handleSubmitForm(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc, {
  FormBuilderModel? existingForm,
  bool isEditing = false,
  String? editingFormId,
}) {
  // Show loading dialog and keep its local context to close safely later
  BuildContext? loadingDialogContext;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      loadingDialogContext = dialogContext;
      return const Center(child: CircularProgressIndicator());
    },
  );

  // Using GoRouter for navigation
  final router = GoRouter.of(context);

  // Handle focus operations directly to avoid BuildContext async gap issues
  // First, unfocus any active text fields to trigger their onTapOutside events
  final currentFocus = FocusScope.of(context).focusedChild;
  if (currentFocus != null) {
    currentFocus.unfocus();
  }

  // Also try to unfocus the entire form to catch any other focused elements
  FocusScope.of(context).unfocus();

  // Dispatch events to force save all components
  formBuilderBloc.add(const ForceSaveAllComponentsEvent());
  formBuilderBloc.add(const ForceRebuildUIEvent());

  // Wait for onTapOutside events to process and state to update
  Future.delayed(const Duration(milliseconds: 1000), () {
    // Close only the loading dialog using its own context
    if (loadingDialogContext != null && loadingDialogContext!.mounted) {
      loadingDialogContext!.pop();
      loadingDialogContext = null;
    }

    try {
      // Get the LATEST state from the bloc after the delay
      final currentState = formBuilderBloc.state;

      // Validate form after forcing save and rebuild
      final validationResult = _validateFormBeforePreview(currentState);
      if (!validationResult.isValid) {
        // Highlight offending component if available
        if (validationResult.componentId != null) {
          formBuilderBloc.add(
            HighlightComponentEvent(validationResult.componentId!),
          );
        }
        if (context.mounted) {
          _showValidationErrorDialog(context, validationResult.errorMessage!);
        }

        return;
      }

      // Create FormBuilderModel with current state
      final now = DateTime.now();
      final resolvedFormId = () {
        if (isEditing) {
          if (existingForm != null && existingForm.formId.isNotEmpty) {
            return existingForm.formId;
          }
          if (editingFormId != null && editingFormId.isNotEmpty) {
            return editingFormId;
          }
        }
        return 'form_${now.millisecondsSinceEpoch}';
      }();

      final resolvedCreatedAt = () {
        if (isEditing && existingForm != null) {
          return existingForm.createdAt;
        }
        return now;
      }();

      final formBuilderModel = FormBuilderModel(
        formId: resolvedFormId,
        name: currentState.formTitle,
        pages: currentState.pages,
        createdAt: resolvedCreatedAt,
        updatedAt: now,
      );

      debugPrint(
        '✅ [FormBuilderAppBar] FormBuilderModel created successfully',
      );
      debugPrint('  - Form ID: ${formBuilderModel.formId}');
      debugPrint('  - Form Name: ${formBuilderModel.name}');
      debugPrint('  - Pages Count: ${formBuilderModel.pages.length}');
      debugPrint(
        '  - Components Count: ${formBuilderModel.pages.fold(0, (sum, page) => sum + page.components.length)}',
      );
      //unfocus
      if (context.mounted) {
        FocusScope.of(context).unfocus();
      }

      // Navigate to preview screen
      router.pushNamed(
        FormBuilderPreviewScreen.routeName,
        extra: {
          'formBuilderModel': formBuilderModel,
          'isEditing': isEditing,
          'editingFormId': resolvedFormId,
        },
      );
    } catch (e) {
      debugPrint('❌ [FormBuilderAppBar] Error creating FormBuilderModel: $e');
      debugPrint('❌ [FormBuilderAppBar] Error details: $e');
    }
  });
}

// Validate form before preview and share
ValidationResult _validateFormBeforePreview(FormBuilderState state) {
  debugPrint('🔍 [FormBuilderAppBar] Starting form validation for preview');

  try {
    final pages = state.pages;
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
          errorMessage: 'Page "${page.title}" must have at least one component',
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

    debugPrint('✅ [FormBuilderAppBar] Form validation completed successfully');
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage: 'Validation error: ${e.toString()}',
    );
  }
}

// Validate individual component
ValidationResult _validateComponent(DynamicFormModel component) {
  debugPrint(
    '🔍 [FormBuilderAppBar] Validating component: ${component.id} - ${component.type}',
  );

  try {
    final config = component.config;
    if (config == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Component "${component.id}" has no configuration',
        componentId: component.id,
      );
    }

    // Check that ALL components have a label (question) - this is mandatory for sharing
    if (config.label == null || config.label!.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Component "${component.id}" must have a question/label before sharing the form',
        componentId: component.id,
      );
    }

    // Check required fields for all components
    if (config.isRequired == true) {
      if (config.label == null || config.label!.trim().isEmpty) {
        return ValidationResult(
          isValid: false,
          errorMessage:
              'Required component "${component.id}" must have a label',
          componentId: component.id,
        );
      }
    }

    // Component-specific validation
    switch (component.type) {
      case FormTypeEnum.shortAnswerFormType:
        return _validateShortAnswer(component);
      case FormTypeEnum.dropdownFormType:
        return _validateDropdown(component);
      case FormTypeEnum.buttonFormType:
        return _validateButton(component);
      default:
        debugPrint(
          '⚠️ [FormBuilderAppBar] Unknown component type: ${component.type}, using basic validation',
        );
        return _validateBasicComponent(component);
    }
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Component validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'Component "${component.id}" validation error: ${e.toString()}',
      componentId: component.id,
    );
  }
}

// Validate dropdown component specifically
ValidationResult _validateDropdown(DynamicFormModel component) {
  debugPrint('🔍 [FormBuilderAppBar] Validating dropdown: ${component.id}');

  try {
    final config = component.config;
    if (config == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Dropdown "${component.id}" has no configuration',
        componentId: component.id,
      );
    }

    // Check that dropdown has a label (question) - this is mandatory for sharing
    if (config.label == null || config.label!.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Dropdown "${component.id}" must have a question/label before sharing the form',
        componentId: component.id,
      );
    }

    // Check that dropdown has at least one option
    if (config.options == null || config.options!.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Dropdown "${component.id}" must have at least one option before sharing the form',
        componentId: component.id,
      );
    }

    debugPrint(
      '✅ [FormBuilderAppBar] Dropdown "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Dropdown validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'Dropdown "${component.id}" validation error: ${e.toString()}',
      componentId: component.id,
    );
  }
}

// Validate ShortAnswer component
ValidationResult _validateShortAnswer(DynamicFormModel component) {
  debugPrint('🔍 [FormBuilderAppBar] Validating ShortAnswer: ${component.id}');

  try {
    final config = component.config;
    if (config == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'ShortAnswer "${component.id}" has no configuration',
        componentId: component.id,
      );
    }

    // Check that ShortAnswer has a label (question) - this is mandatory for sharing
    if (config.label == null || config.label!.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'ShortAnswer "${component.id}" must have a question/label before sharing the form',
        componentId: component.id,
      );
    }

    debugPrint(
      '✅ [FormBuilderAppBar] ShortAnswer "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] ShortAnswer validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'ShortAnswer "${component.id}" validation error: ${e.toString()}',
      componentId: component.id,
    );
  }
}

// Validate Button component
ValidationResult _validateButton(DynamicFormModel component) {
  debugPrint('🔍 [FormBuilderAppBar] Validating Button: ${component.id}');

  try {
    final config = component.config;
    if (config == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Button "${component.id}" has no configuration',
      );
    }

    // Check that Button has a label (text) - this is mandatory for sharing
    if (config.label == null || config.label!.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Button "${component.id}" must have text/label before sharing the form',
      );
    }

    debugPrint(
      '✅ [FormBuilderAppBar] Button "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Button validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'Button "${component.id}" validation error: ${e.toString()}',
    );
  }
}

// Validate basic component (fallback for other types)
ValidationResult _validateBasicComponent(DynamicFormModel component) {
  debugPrint(
    '🔍 [FormBuilderAppBar] Validating basic component: ${component.id}',
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
      '✅ [FormBuilderAppBar] Basic component "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Basic component validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'Component "${component.id}" validation error: ${e.toString()}',
    );
  }
}

// Show validation error dialog
void _showValidationErrorDialog(BuildContext context, String errorMessage) {
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
