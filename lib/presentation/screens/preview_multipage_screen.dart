import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_data_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';

class PreviewPageScreen extends StatelessWidget {
  final List<DynamicFormPageModel> pages;
  final ComponentValuesModel allComponentValues;
  final VoidCallback? onSubmit;
  final VoidCallback? onPrevious;

  const PreviewPageScreen({
    super.key,
    required this.pages,
    required this.allComponentValues,
    this.onSubmit,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  // Build page blocks with explicit loops instead of map
  Widget _buildBody(BuildContext context) {
    final List<Widget> pageBlocks = [];

    // Build each page block
    for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      final page = pages[pageIndex];
      final List<DynamicFormModel> pageComponents = [];

      // Process each component in the page
      for (final componentItem in page.components) {
        final value = allComponentValues.values[componentItem.id];
        final updatedConfig = componentItem.config?.copyWith(value: value);

        final processedComponent = DynamicFormModel(
          id: componentItem.id,
          type: componentItem.type,
          order: componentItem.order,
          config: updatedConfig,
          style: componentItem.style,
          inputTypes: componentItem.inputTypes,
          variants: componentItem.variants,
          states: componentItem.states,
          validation: componentItem.validation,
          children: componentItem.children,
        );

        // Only add non-button components
        if (processedComponent.type != FormTypeEnum.buttonFormType) {
          pageComponents.add(processedComponent);
        }
      }

      // Build page header and components
      final List<Widget> pageChildren = [];

      // Add page header if multiple pages
      if (pages.length > 1) {
        pageChildren.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Page ${pageIndex + 1}/${pages.length}: ${page.title}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      }

      // Add each component widget
      for (final component in pageComponents) {
        pageChildren.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AbsorbPointer(
              absorbing: true, // Block interaction for each component
              child: DynamicFormRenderer(component: component),
            ),
          ),
        );
      }

      pageBlocks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pageChildren,
          ),
        ),
      );
    }

    final previewComponents = _buildPreviewComponents(
      pages,
      allComponentValues,
    );

    // Find previous button
    DynamicFormModel? previousButton;
    for (final component in previewComponents) {
      if (component.type == FormTypeEnum.buttonFormType &&
          component.config?.action == 'previous_page') {
        previousButton = component;
        break;
      }
    }
    previousButton ??= DynamicFormModel.empty();

    // Create a submit button for the preview screen
    final submitButton = DynamicFormModel(
      id: 'preview_submit_button',
      type: FormTypeEnum.buttonFormType,
      order: 999,
      config: ConfigModel(
        label: 'Submit',
        icon: 'submit',
        action: ButtonAction.submitForm.value,
      ),
      style: const StyleModel(),
    );

    final isFormValid = isAllRequiredFilled(
      previewComponents,
      allComponentValues,
    );

    return Stack(
      children: [
        // Scrollable content
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...pageBlocks,
          ],
        ),

        // Overlay showing preview mode
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withValues(alpha: 0.15),
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Preview Mode (Read Only)',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Submit & Previous buttons
        _buildPreviewButtonsRow(
          previousButton: previousButton,
          submitButton: submitButton,
          isFormValid: isFormValid,
          onPrevious: onPrevious,
          onSubmit: () async {
            if (isFormValid) {
              // Save form data
              await _saveForm(context);

              // Show success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form submitted and saved successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }

              // Navigate back to first screen
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please fill all required fields before submitting.',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _saveForm(BuildContext context) async {
    try {
      final savedFormsService = SavedFormsService();

      // Use the new SavedFormDataModel instead of List<Map<String, dynamic>>
      final savedFormData = SavedFormDataBuilder.createFromDynamicFormPages(
        formId: 'preview_form_${DateTime.now().millisecondsSinceEpoch}',
        pages: pages,
        componentValues: allComponentValues.values,
      );

      await savedFormsService.saveFormWithCustomFormat(
        formId: savedFormData.formId,
        name: 'Preview Form - ${DateTime.now().toString().substring(0, 19)}',
        description:
            'Form with ${pages.length} pages and ${allComponentValues.values.length} filled fields',
        formData: savedFormData.toJson(),
        originalConfigKey: 'preview_form',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving form: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Preview All Pages'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () => _saveForm(context),
        ),
      ],
    );
  }
}

List<DynamicFormModel> _buildPreviewComponents(
  List<DynamicFormPageModel> pages,
  ComponentValuesModel allComponentValues,
) {
  final List<DynamicFormModel> allComponents = [];

  // Process each page
  for (final page in pages) {
    // Process each component in the page
    for (final componentItem in page.components) {
      final value = allComponentValues.values[componentItem.id];
      final updatedConfig = componentItem.config?.copyWith(value: value);

      final processedComponent = DynamicFormModel(
        id: componentItem.id,
        type: componentItem.type,
        order: componentItem.order,
        config: updatedConfig,
        style: componentItem.style,
        inputTypes: componentItem.inputTypes,
        variants: componentItem.variants,
        states: componentItem.states,
        validation: componentItem.validation,
        children: componentItem.children,
      );

      allComponents.add(processedComponent);
    }
  }

  return allComponents;
}

// DynamicFormModel? buildRemoteButton(RemoteButtonConfigKey key) {
//   final jsonString = RemoteConfigService().getString(key.key);
//   if (jsonString.isNotEmpty) {
//     return DynamicFormModel.fromJson(jsonDecode(jsonString));
//   }
//   return null;
// }

bool isAllRequiredFilled(
  List<DynamicFormModel> components,
  ComponentValuesModel allComponentValues,
) {
  for (final component in components) {
    if (ComponentUtils.isRequired(component)) {
      final value = allComponentValues.values[component.id];
      if (value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty)) {
        return false;
      }
    }
  }
  return true;
}

Widget _buildPreviewButtonsRow({
  required DynamicFormModel? previousButton,
  required DynamicFormModel submitButton,
  required bool isFormValid,
  VoidCallback? onPrevious,
  VoidCallback? onSubmit,
}) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: previousButton != null
                  ? DynamicFormRenderer(
                      component: previousButton,
                      onButtonAction: (action, data) {
                        if (onPrevious != null) onPrevious();
                      },
                    )
                  : const Text("Missing Previous Button"),
            ),
            if (submitButton.id.isNotEmpty) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Opacity(
                  opacity: isFormValid ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: !isFormValid,
                    child: DynamicFormRenderer(
                      component: submitButton,
                      onButtonAction: (action, data) {
                        if (isFormValid && onSubmit != null) onSubmit();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
