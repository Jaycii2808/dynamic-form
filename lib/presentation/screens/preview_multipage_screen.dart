import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:dynamic_form_bi/core/enums/remote_button_config_key_enum.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'dart:convert';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';

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
    final previewComponents = _buildPreviewComponents(
      pages,
      allComponentValues,
    );
    final nonSubmitComponents = previewComponents
        .where((c) => c.id != RemoteButtonConfigKey.formSaveButton.key)
        .toList();
    final submitButton = previewComponents.firstWhere(
      (c) => c.id == RemoteButtonConfigKey.formSaveButton.key,
      orElse: () => DynamicFormModel.empty(),
    );
    final previousButton = buildRemoteButton(
      RemoteButtonConfigKey.previousButton,
    );
    final isFormValid = isAllRequiredFilled(
      previewComponents,
      allComponentValues,
    );
    return Stack(
      children: [
        _buildPreviewListView(components: nonSubmitComponents),
        _buildPreviewButtonsRow(
          previousButton: previousButton,
          submitButton: submitButton,
          isFormValid: isFormValid,
          onPrevious: onPrevious,
          onSubmit: () {
            if (onSubmit != null) onSubmit!();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Form submitted successfully.'),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Preview All Pages'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

List<DynamicFormModel> _buildPreviewComponents(
  List<DynamicFormPageModel> pages,
  Map<String, dynamic> allComponentValues,
) {
  return pages.expand((p) => p.components).map((componentItem) {
    final value = allComponentValues[componentItem.id];
    final newConfig = Map<String, dynamic>.from(componentItem.config);
    if (value != null) {
      newConfig[ValueKeyEnum.value.key] = value;
    } else {
      newConfig.remove(ValueKeyEnum.value.key);
    }
    return DynamicFormModel(
      id: componentItem.id,
      type: componentItem.type,
      order: componentItem.order,
      config: newConfig,
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

Widget _buildPreviewListView({required List<DynamicFormModel> components}) {
  return ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    itemCount: components.length,
    separatorBuilder: (_, __) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final component = components[index];
      return AbsorbPointer(
        absorbing: true,
        child: Opacity(
          opacity: 0.7,
          child: DynamicFormRenderer(
            component: component,
          ),
        ),
      );
    },
  );
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
            if (isFormValid && submitButton.id.isNotEmpty) ...[
              const SizedBox(width: 16),
              Expanded(
                child: DynamicFormRenderer(
                  component: submitButton,
                  onButtonAction: (action, data) {
                    if (onSubmit != null) onSubmit();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
