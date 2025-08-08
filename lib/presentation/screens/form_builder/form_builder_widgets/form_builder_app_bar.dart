import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

PreferredSizeWidget formBuilderAppBar(
  BuildContext context,
  FormBuilderBloc formBuilderBloc,
) {
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
        onTap: () => Navigator.of(context).pop(),
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
        builder: (context, state) =>
            _buildActionButtons(context, state, formBuilderBloc),
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
  FormBuilderBloc formBuilderBloc,
) {
  return IconButton(
    onPressed: () => _handleSubmitForm(context, state, formBuilderBloc),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                formBuilderBloc.add(UpdateFormTitleEvent(newTitle));
              }
              Navigator.of(context).pop();
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
  FormBuilderBloc formBuilderBloc,
) {
  // Validate form before allowing preview and share
  final validationResult = _validateFormBeforePreview(state);
  if (!validationResult.isValid) {
    _showValidationErrorDialog(context, validationResult.errorMessage!);
    return;
  }

  debugPrint(
    '✅ [FormBuilderAppBar] Form validation passed, proceeding with preview',
  );

  if (state.pages.isEmpty ||
      state.pages.every((page) => page.components.isEmpty)) {
    DialogUtils.showErrorDialog(
      context,
      'Please add at least one component to the form',
    );
    return;
  }
  final formBuilderModel = FormBuilderModel(
    formId: 'form_${DateTime.now().millisecondsSinceEpoch}',
    name: state.formTitle,
    pages: state.pages,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          FormBuilderPreviewScreen(formBuilderModel: formBuilderModel),
    ),
  );
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
          '⚠️ [FormBuilderAppBar] Component "${component.id}" has no placeholder',
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
      '✅ [FormBuilderAppBar] Dropdown "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Dropdown validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'Dropdown "${component.id}" validation error: ${e.toString()}',
    );
  }
}

// Validate TextField component
ValidationResult _validateTextField(DynamicFormModel component) {
  debugPrint('🔍 [FormBuilderAppBar] Validating TextField: ${component.id}');

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

    debugPrint(
      '✅ [FormBuilderAppBar] TextField "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] TextField validation error: $e');
    return ValidationResult(
      isValid: false,
      errorMessage:
          'TextField "${component.id}" validation error: ${e.toString()}',
    );
  }
}

// Validate TextArea component
ValidationResult _validateTextArea(DynamicFormModel component) {
  debugPrint('🔍 [FormBuilderAppBar] Validating TextArea: ${component.id}');

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
          errorMessage: 'Required TextArea "${component.id}" must have a label',
        );
      }
    }

    debugPrint(
      '✅ [FormBuilderAppBar] TextArea "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] TextArea validation error: $e');
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
    '🔍 [FormBuilderAppBar] Validating DateTimePicker: ${component.id}',
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
      '✅ [FormBuilderAppBar] DateTimePicker "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] DateTimePicker validation error: $e');
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
    '🔍 [FormBuilderAppBar] Validating DateTimeRangePicker: ${component.id}',
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
      '✅ [FormBuilderAppBar] DateTimeRangePicker "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint(
      '❌ [FormBuilderAppBar] DateTimeRangePicker validation error: $e',
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
  debugPrint('🔍 [FormBuilderAppBar] Validating Switch: ${component.id}');

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
      '✅ [FormBuilderAppBar] Switch "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] Switch validation error: $e');
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
    '🔍 [FormBuilderAppBar] Validating SelectorButton: ${component.id}',
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
      '✅ [FormBuilderAppBar] SelectorButton "${component.id}" validation passed',
    );
    return ValidationResult(isValid: true);
  } catch (e) {
    debugPrint('❌ [FormBuilderAppBar] SelectorButton validation error: $e');
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
