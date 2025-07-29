import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:dynamic_form_bi/core/enums/remote_button_config_key_enum.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'dart:convert';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';

class PreviewMultiPageScreen extends StatelessWidget {
  final List<DynamicFormPageModel> pages;
  final Map<String, dynamic> allComponentValues;
  final VoidCallback? onSubmit;
  final VoidCallback? onPrevious;

  const PreviewMultiPageScreen({
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

  Widget _buildBody(BuildContext context) {
    final pageBlocks = pages.asMap().entries.map((entry) {
      final pageIndex = entry.key;
      final page = entry.value;
      final pageComponents = page.components
          .map((componentItem) {
            final value = allComponentValues[componentItem.id];
            final newConfig = Map<String, dynamic>.from(
              componentItem.config?.toJson() ?? {},
            );
            if (value != null) {
              newConfig['value'] = value;
            } else {
              newConfig.remove('value');
            }
            return DynamicFormModel(
              id: componentItem.id,
              type: componentItem.type,
              order: componentItem.order,
              config: ConfigModel.fromJson(newConfig),
              style: componentItem.style,
              inputTypes: componentItem.inputTypes,
              variants: componentItem.variants,
              states: componentItem.states,
              validation: componentItem.validation,
              children: componentItem.children,
            );
          })
          .where((c) => c.type != FormTypeEnum.buttonFormType)
          .toList();

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Only show page header when there's more than 1 page
            if (pages.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Trang ${pageIndex + 1}/${pages.length}: ${page.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ...pageComponents.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AbsorbPointer(
                  absorbing: true, // ✅ chỉ chặn tương tác từng component
                  child: DynamicFormRenderer(component: c),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();

    final previewComponents = _buildPreviewComponents(
      pages,
      allComponentValues,
    );
    final previousButton = previewComponents.firstWhere(
      (c) =>
          c.type == FormTypeEnum.buttonFormType &&
          c.config?.action == 'previous_page',
      orElse: () => DynamicFormModel.empty(),
    );

    // Create a submit button for the preview screen
    final submitButton = DynamicFormModel(
      id: 'preview_submit_button',
      type: FormTypeEnum.buttonFormType,
      order: 999,
      config: ConfigModel(
        label: 'Submit Form',
        icon: 'submit',
        action: 'submit_form',
      ),
      style: const StyleModel(),
      inputTypes: null,
      variants: null,
      states: null,
      validation: null,
      children: null,
    );

    final isFormValid = isAllRequiredFilled(
      previewComponents,
      allComponentValues,
    );

    return Stack(
      children: [
        // ✅ Cuộn được
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

        // ✅ Overlay báo chế độ preview
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.15),
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
                    color: Colors.red.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Chế độ xem trước (Read Only)',
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

        // ✅ Nút Submit & Previous
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

      // Convert to custom format for multi-page forms
      final formData = {
        'form_id': 'preview_form_${DateTime.now().millisecondsSinceEpoch}',
        'pages': pages.map((page) {
          return {
            'pageId': page.pageId,
            'title': page.title,
            'order': page.order,
            'components': page.components.map((component) {
              return {
                'id': component.id,
                'type': component.type.toJson(),
                'order': component.order,
                'config': component.config?.toJson(),
                'style': component.style?.toJson(),
                'validation': component.validation?.toJson(),
                'children': component.children
                    ?.map(
                      (child) => {
                        'id': child.id,
                        'type': child.type.toJson(),
                        'order': child.order,
                        'config': child.config?.toJson(),
                        'style': child.style?.toJson(),
                        'validation': child.validation?.toJson(),
                      },
                    )
                    .toList(),
              };
            }).toList(),
          };
        }).toList(),
        'component_values': allComponentValues,
      };

      await savedFormsService.saveFormWithCustomFormat(
        formId: formData['form_id'] as String,
        name: 'Preview Form - ${DateTime.now().toString().substring(0, 19)}',
        description:
            'Form with ${pages.length} pages and ${allComponentValues.length} filled fields',
        formData: formData,
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
  Map<String, dynamic> allComponentValues,
) {
  return pages.expand((p) => p.components).map((componentItem) {
    final value = allComponentValues[componentItem.id];
    final newConfig = Map<String, dynamic>.from(
      componentItem.config?.toJson() ?? {},
    );
    if (value != null) {
      newConfig['value'] = value;
    } else {
      newConfig.remove('value');
    }
    return DynamicFormModel(
      id: componentItem.id,
      type: componentItem.type,
      order: componentItem.order,
      config: ConfigModel.fromJson(newConfig),
      style: componentItem.style,
      inputTypes: componentItem.inputTypes,
      variants: componentItem.variants,
      states: componentItem.states,
      validation: componentItem.validation,
      children: componentItem.children,
    );
  }).toList();
}

DynamicFormModel? buildRemoteButton(RemoteButtonConfigKey key) {
  final jsonString = RemoteConfigService().getString(key.key);
  if (jsonString.isNotEmpty) {
    return DynamicFormModel.fromJson(jsonDecode(jsonString));
  }
  return null;
}

bool isAllRequiredFilled(
  List<DynamicFormModel> components,
  Map<String, dynamic> allComponentValues,
) {
  for (final component in components) {
    if (ComponentUtils.isRequired(component)) {
      final value = allComponentValues[component.id];
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
