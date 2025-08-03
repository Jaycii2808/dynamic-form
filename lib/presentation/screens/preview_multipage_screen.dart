import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/button_action_preview_multipage_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_data_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';

class PreviewPageScreen extends StatefulWidget {
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
  State<PreviewPageScreen> createState() => _PreviewPageScreenState();
}

class _PreviewPageScreenState extends State<PreviewPageScreen> {
  int currentPageIndex = 0;
  late ComponentValuesModel componentValues;

  @override
  void initState() {
    super.initState();
    // Use model's copyWith method to create a copy
    componentValues = widget.allComponentValues.copyWith();
  }

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
    for (int pageIndex = 0; pageIndex < widget.pages.length; pageIndex++) {
      final page = widget.pages[pageIndex];
      final List<DynamicFormModel> pageComponents = [];

      // Process each component in the page
      for (final componentItem in page.components) {
        final value = componentValues.values[componentItem.id];
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

        // Add all components including buttons
        pageComponents.add(processedComponent);
      }

      // Build page header and components
      final List<Widget> pageChildren = [];

      // Add page header if multiple pages
      if (widget.pages.length > 1) {
        pageChildren.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Page ${pageIndex + 1}/${widget.pages.length}: ${page.title}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      }

      // Add each component widget with appropriate handling
      for (final component in pageComponents) {
        pageChildren.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildComponentWidget(component),
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
      widget.pages,
      componentValues,
    );

    final isFormValid = isAllRequiredFilled(
      previewComponents,
      componentValues,
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
                    'Preview Mode',
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

        // Save button for preview
        _buildPreviewSaveButton(isFormValid),
      ],
    );
  }

  Widget _buildComponentWidget(DynamicFormModel component) {
    // Handle different component types for preview
    switch (component.type) {
      case FormTypeEnum.buttonFormType:
        return _buildButtonComponent(component);
      default:
        return _buildFormComponent(component);
    }
  }

  Widget _buildFormComponent(DynamicFormModel component) {
    // Form components are read-only in preview
    return AbsorbPointer(
      absorbing: true,
      child: DynamicFormRenderer(
        component: component,
        onFieldChanged: (componentId, value) {
          // Update local state for preview
          setState(() {
            componentValues.values[componentId] = value;
          });
        },
      ),
    );
  }

  Widget _buildButtonComponent(DynamicFormModel component) {
    // Button components are interactive in preview
    return DynamicFormRenderer(
      component: component,
      onButtonAction: (action, data) {
        // Convert string action to enum
        final buttonAction = ButtonActionPreviewMultipageEnum.tryFromString(
          action,
        );
        if (buttonAction != null) {
          _handleButtonAction(buttonAction, data, component);
        } else {
          _showPreviewActionDialog(action, component);
        }
      },
    );
  }

  void _handleButtonAction(
    ButtonActionPreviewMultipageEnum action,
    FormActionDataModel? data,
    DynamicFormModel component,
  ) {
    debugPrint('Button action: ${action.value}, data: $data');

    switch (action) {
      case ButtonActionPreviewMultipageEnum.previousPage:
        _handlePreviousPage();
        break;
      case ButtonActionPreviewMultipageEnum.nextPage:
        _handleNextPage();
        break;
      case ButtonActionPreviewMultipageEnum.submitForm:
        _handleSubmitForm();
        break;
      case ButtonActionPreviewMultipageEnum.saveForm:
        _handleSaveForm();
        break;
      case ButtonActionPreviewMultipageEnum.clearForm:
        _handleClearForm();
        break;
      case ButtonActionPreviewMultipageEnum.customAction:
        _handleCustomAction(data);
        break;
    }
  }

  void _handlePreviousPage() {
    if (currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
      });
      _scrollToPage(currentPageIndex);
    }
  }

  void _handleNextPage() {
    if (currentPageIndex < widget.pages.length - 1) {
      setState(() {
        currentPageIndex++;
      });
      _scrollToPage(currentPageIndex);
    }
  }

  void _handleSubmitForm() {
    _showPreviewActionDialog('submit_form', null);
  }

  void _handleSaveForm() {
    _saveForm(context);
  }

  void _handleClearForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Form'),
        content: const Text(
          'This action would clear all form data in a real form.',
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

  void _handleCustomAction(FormActionDataModel? data) {
    _showPreviewActionDialog('custom_action', null);
  }

  void _showPreviewActionDialog(String action, DynamicFormModel? component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview Action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Action: $action'),
            if (component != null) ...[
              const SizedBox(height: 8),
              Text('Component: ${component.config?.label ?? component.id}'),
            ],
            const SizedBox(height: 8),
            const Text('This action would be executed in a real form.'),
          ],
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

  void _scrollToPage(int pageIndex) {
    // Scroll to the specific page
    // This is a simplified implementation
    debugPrint('Scrolling to page $pageIndex');
  }

  Widget _buildPreviewSaveButton(bool isFormValid) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isFormValid ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: isFormValid ? () => _saveForm(context) : null,
                    child: const Center(
                      child: Text(
                        'Save Form Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveForm(BuildContext context) async {
    try {
      final savedFormsService = SavedFormsService();

      // Use the new SavedFormDataModel instead of List<Map<String, dynamic>>
      final savedFormData = SavedFormDataBuilder.createFromDynamicFormPages(
        formId: 'preview_form_${DateTime.now().millisecondsSinceEpoch}',
        pages: widget.pages,
        componentValues: componentValues.values,
      );

      await savedFormsService.saveFormWithCustomFormat(
        formId: savedFormData.formId,
        name: 'Preview Form - ${DateTime.now().toString().substring(0, 19)}',
        description:
            'Form with ${widget.pages.length} pages and ${componentValues.values.length} filled fields',
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
