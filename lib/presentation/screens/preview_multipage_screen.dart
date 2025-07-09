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

  DynamicFormModel? _buildButton(RemoteButtonConfigKey key) {
    final jsonString = RemoteConfigService().getString(key.key);
    if (jsonString.isNotEmpty) {
      return DynamicFormModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  bool _isFormValid() {
    // Check if all required components have a non-null, non-empty value
    for (final comp in pages.expand((p) => p.components)) {
      if (ComponentUtils.isRequired(comp)) {
        final value = allComponentValues[comp.id];
        if (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final allComponents = pages.expand((p) => p.components).toList();
    // Clone each component and set config['value'] from allComponentValues
    final previewComponents = allComponents.map((comp) {
      final value = allComponentValues[comp.id];
      final newConfig = Map<String, dynamic>.from(comp.config);
      if (value != null) {
        newConfig['value'] = value;
      } else {
        newConfig.remove('value');
      }
      return DynamicFormModel(
        id: comp.id,
        type: comp.type,
        order: comp.order,
        config: newConfig,
        style: comp.style,
        inputTypes: comp.inputTypes,
        variants: comp.variants,
        states: comp.states,
        validation: comp.validation,
        children: comp.children,
      );
    }).toList();
    final previousButton = _buildButton(RemoteButtonConfigKey.previousButton);
    // Find the submit button from previewComponents
    final submitButton = previewComponents.firstWhere(
      (comp) => comp.id == 'form_save_button',
      orElse: () => DynamicFormModel.empty(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview All Pages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...previewComponents.map(
            (comp) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AbsorbPointer(
                absorbing: true,
                child: Opacity(
                  opacity: 0.7,
                  child: DynamicFormRenderer(
                    component: comp,
                    // Optionally pass values if DynamicFormRenderer supports it
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: previousButton != null
                    ? DynamicFormRenderer(
                        component: previousButton,
                        onButtonAction: (action, data) {
                          if (onPrevious != null) onPrevious!();
                        },
                      )
                    : ElevatedButton(
                        onPressed:
                            onPrevious ?? () => Navigator.of(context).pop(),
                        child: const Text('Previous.'),
                      ),
              ),
              if (_isFormValid() && submitButton.id.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: DynamicFormRenderer(
                    component: submitButton,
                    onButtonAction: (action, data) {
                      if (onSubmit != null) onSubmit!();
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
