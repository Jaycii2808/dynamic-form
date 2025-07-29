import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';

import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_state.dart';
import 'package:dynamic_form_bi/presentation/screens/preview_multipage_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFormMultiPageWidget extends StatelessWidget {
  final FormForMultiPageModel page;
  final Map<String, dynamic> allComponentValues;

  const DynamicFormMultiPageWidget({
    super.key,
    required this.page,
    required this.allComponentValues,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[UI] build() called for DynamicFormMultiPageWidget');
    return BlocConsumer<MultiPageFormBloc, MultiPageFormState>(
      listener: (context, state) {
        if (state is MultiPageFormError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        }
        debugPrint('[UI] State changed: ${state.runtimeType}');
        if (state is MultiPageFormSuccess) {
          debugPrint('[UI] Current page index: ${state.currentPageIndex}');
        }
      },
      builder: (context, state) {
        if (state is MultiPageFormLoading || state is MultiPageFormInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MultiPageFormSuccess) {
          return _bodyWidget(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildListViewWidget(
    BuildContext context,
    List<DynamicFormModel> otherComponents,
    MultiPageFormState state,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      itemCount: otherComponents.length,
      itemBuilder: (context, index) {
        final componentModel = otherComponents[index];
        final configJson =
            componentModel.config?.toJson() ?? <String, dynamic>{};
        final oldValue = configJson['value'];
        final newValue = allComponentValues[componentModel.id];
        configJson['value'] = newValue;

        debugPrint(
          '🔍 [MultiPageWidget] ListView Component ${componentModel.id}: oldValue=$oldValue, newValue=$newValue',
        );

        final updatedComponent = DynamicFormModel(
          id: componentModel.id,
          type: componentModel.type,
          order: componentModel.order,
          config: ConfigModel.fromJson(configJson),
          style: componentModel.style,
          inputTypes: componentModel.inputTypes,
          variants: componentModel.variants,
          states: componentModel.states,
          validation: componentModel.validation,
          children: componentModel.children,
        );

        return DynamicFormRenderer(
          component: updatedComponent,
          onFieldChanged: (componentId, value) {
            final newValue = value is Map && value.containsKey('value')
                ? value['value']
                : value;
            context.read<MultiPageFormBloc>().add(
              UpdateComponentValue(componentId, newValue),
            );
          },
          onButtonAction: (action, data) async {
            if (action == ButtonAction.previewForm.value) {
              _handlePreviewFormAction(context, state);
            }
            // Handle submit form action
            if (action == ButtonAction.submitForm.value) {
              debugPrint('[UI] Submit form action triggered from ListView');
              debugPrint(
                '🔄 [Submit] Submit form action triggered from ListView',
              );

              // Save form data
              if (state is MultiPageFormSuccess) {
                debugPrint(
                  '🔄 [Submit] State is MultiPageFormSuccess, calling save method from ListView',
                );
                await _saveFormData(context, state, allComponentValues);
              } else {
                debugPrint(
                  '❌ [Submit] State is not MultiPageFormSuccess from ListView: ${state.runtimeType}',
                );
              }

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

              // Navigate back
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              return;
            }
            // FIX: Handle next_page navigation from ListView button
            if (action == ButtonAction.nextPage.value) {
              String? targetPage = data != null && data['targetPage'] != null
                  ? data['targetPage'] as String?
                  : null;
              if (targetPage == null || targetPage.isEmpty) {
                final validate = updatedComponent.validation?.toJson();
                targetPage = validate?['next_page'] as String?;
              }
              if (targetPage != null && targetPage.isNotEmpty) {
                if (state is MultiPageFormSuccess && state.formModel != null) {
                  final targetIndex = state.formModel!.pages.indexWhere(
                    (p) => p.pageId == targetPage,
                  );
                  if (targetIndex >= 0) {
                    context.read<MultiPageFormBloc>().add(
                      NavigateToPageByIndex(targetIndex),
                    );
                  } else {
                    context.read<MultiPageFormBloc>().add(
                      const NavigateToPage(isNext: true),
                    );
                  }
                } else {
                  context.read<MultiPageFormBloc>().add(
                    const NavigateToPage(isNext: true),
                  );
                }
              } else {
                context.read<MultiPageFormBloc>().add(
                  const NavigateToPage(isNext: true),
                );
              }
              return;
            }
          },
        );
      },
    );
  }

  Widget _buildButtonsRowWidget(
    BuildContext context,
    DynamicFormModel? previousButton,
    DynamicFormModel? nextButton,
    DynamicFormModel? previewButton,
    DynamicFormModel? submitButton,
    List<DynamicFormModel> otherComponents,
    MultiPageFormState state,
  ) {
    debugPrint('🔍 [ButtonsRow] previousButton: ${previousButton?.id}');
    debugPrint('🔍 [ButtonsRow] nextButton: ${nextButton?.id}');
    debugPrint('🔍 [ButtonsRow] previewButton: ${previewButton?.id}');
    debugPrint('🔍 [ButtonsRow] submitButton: ${submitButton?.id}');

    final multiPageBloc = context.read<MultiPageFormBloc>();
    if (previousButton == null &&
        nextButton == null &&
        previewButton == null &&
        submitButton == null) {
      return const SizedBox.shrink();
    }

    bool isNextValid = nextButton == null
        ? true
        : _validateButtonConditions(
            nextButton,
            context,
            showDialogOnError: false,
          );
    bool isPreviousValid = previousButton == null
        ? true
        : _validateButtonConditions(
            previousButton,
            context,
            showDialogOnError: false,
          );
    bool isSubmitValid = submitButton == null
        ? true
        : _validateButtonConditions(
            submitButton,
            context,
            showDialogOnError: false,
          );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          children: [
            if (previousButton != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: isPreviousValid ? 1.0 : 0.5,
                    child: DynamicFormRenderer(
                      component: previousButton,
                      onButtonAction: (action, data) {
                        debugPrint(
                          '[UI] Previous button pressed with action: $action',
                        );
                        if (!_validateButtonConditions(
                          previousButton,
                          context,
                          showDialogOnError: true,
                        )) {
                          debugPrint(
                            '[UI] Previous button validation failed for ${previousButton.id}',
                          );
                          return;
                        }

                        // Handle previous navigation
                        final validate = previousButton.validation?.toJson();
                        final targetPage =
                            validate?['previous_page'] as String?;
                        debugPrint(
                          '[UI] Previous button action: $action, targetPage: $targetPage',
                        );

                        if (targetPage != null) {
                          final targetIndex = state.formModel?.pages.indexWhere(
                            (p) => p.pageId == targetPage,
                          );
                          debugPrint('[UI] Previous targetIndex: $targetIndex');
                          if (targetIndex != null && targetIndex >= 0) {
                            multiPageBloc.add(
                              NavigateToPageByIndex(targetIndex),
                            );
                          } else {
                            debugPrint('[UI] Invalid previous targetIndex');
                          }
                        } else {
                          multiPageBloc.add(
                            const NavigateToPage(isNext: false),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            if (nextButton != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: isNextValid ? 1.0 : 0.5,
                    child: DynamicFormRenderer(
                      component: nextButton,
                      onButtonAction: (action, data) {
                        debugPrint(
                          '[UI] 🎯 Next button pressed with action: $action, data: $data',
                        );
                        if (action == ButtonAction.nextPage.value) {
                          // Get targetPage from data first, then from validation
                          String? targetPage =
                              data != null && data['targetPage'] != null
                              ? data['targetPage'] as String?
                              : null;
                          if (targetPage == null || targetPage.isEmpty) {
                            final validate = nextButton.validation?.toJson();
                            targetPage = validate?['next_page'] as String?;
                          }
                          debugPrint('[UI] 🎯 Next targetPage: $targetPage');
                          if (targetPage != null && targetPage.isNotEmpty) {
                            if (state is MultiPageFormSuccess &&
                                state.formModel != null) {
                              final targetIndex = state.formModel!.pages
                                  .indexWhere((p) => p.pageId == targetPage);
                              debugPrint(
                                '[UI] 🎯 Next targetIndex: $targetIndex for pageId: $targetPage',
                              );
                              if (targetIndex >= 0) {
                                debugPrint(
                                  '[UI] 🚀 Navigating to page index: $targetIndex',
                                );
                                context.read<MultiPageFormBloc>().add(
                                  NavigateToPageByIndex(targetIndex),
                                );
                              } else {
                                debugPrint(
                                  '[UI] ❌ Target page not found: $targetPage',
                                );
                                context.read<MultiPageFormBloc>().add(
                                  const NavigateToPage(isNext: true),
                                );
                              }
                            } else {
                              debugPrint(
                                '[UI] ❌ Form model not available in state',
                              );
                              context.read<MultiPageFormBloc>().add(
                                const NavigateToPage(isNext: true),
                              );
                            }
                          } else {
                            debugPrint(
                              '[UI] 🚀 No specific target page, using sequential navigation',
                            );
                            context.read<MultiPageFormBloc>().add(
                              const NavigateToPage(isNext: true),
                            );
                          }
                          return;
                        }
                        // CRITICAL FIX: Always validate before proceeding
                        if (!_validateButtonConditions(
                          nextButton,
                          context,
                          showDialogOnError: true,
                        )) {
                          debugPrint(
                            '[UI] ❌ Next button validation failed for ${nextButton.id}',
                          );
                          return;
                        }
                        debugPrint(
                          '[UI] ✅ Next button validation passed, proceeding with navigation',
                        );
                        // Fallback logic if not handled above
                        context.read<MultiPageFormBloc>().add(
                          const NavigateToPage(isNext: true),
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (previewButton != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DynamicFormRenderer(
                    component: previewButton,
                    onButtonAction: (action, data) async {
                      debugPrint(
                        '[UI] Preview button action: $action, data: $data',
                      );
                      _handlePreviewFormAction(context, state);
                    },
                  ),
                ),
              ),
            if (submitButton != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: isSubmitValid ? 1.0 : 0.5,
                    child: DynamicFormRenderer(
                      component: submitButton,
                      onButtonAction: (action, data) async {
                        debugPrint(
                          '[UI] Submit button pressed with action: $action, data: $data',
                        );
                        if (action == ButtonAction.submitForm.value) {
                          debugPrint(
                            '🔄 [Submit] Submit form action triggered from bottom buttons row',
                          );

                          // Save form data
                          if (state is MultiPageFormSuccess) {
                            debugPrint(
                              '🔄 [Submit] State is MultiPageFormSuccess, calling save method',
                            );
                            await _saveFormData(
                              context,
                              state,
                              allComponentValues,
                            );
                          } else {
                            debugPrint(
                              '❌ [Submit] State is not MultiPageFormSuccess: ${state.runtimeType}',
                            );
                          }

                          // Show success message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Form submitted and saved successfully!',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }

                          // Navigate back
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveFormData(
    BuildContext context,
    MultiPageFormSuccess state,
    Map<String, dynamic> componentValues,
  ) async {
    debugPrint('🔄 [SaveForm] Starting to save form data...');
    debugPrint(
      '🔄 [SaveForm] Component values count: ${componentValues.length}',
    );
    debugPrint(
      '🔄 [SaveForm] Form model pages count: ${state.formModel?.pages.length}',
    );

    try {
      final savedFormsService = SavedFormsService();

      if (state.formModel != null) {
        // Convert to custom format for multi-page forms
        final formData = {
          'form_id': 'multi_page_form_${DateTime.now().millisecondsSinceEpoch}',
          'pages': state.formModel!.pages.map((page) {
            return {
              'pageId': page.pageId,
              'title': page.title,
              'order': page.order,
              'show_next_button': page.showNextButton,
              'show_previous_button': page.showPreviousButton,
              'show_submit_button': page.showSubmitButton,
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
          'component_values': componentValues,
        };

        debugPrint('🔄 [SaveForm] Calling saveFormWithCustomFormat...');
        await savedFormsService.saveFormWithCustomFormat(
          formId: formData['form_id'] as String,
          name:
              'Multi-Page Form - ${DateTime.now().toString().substring(0, 19)}',
          description:
              'Form with ${state.formModel!.pages.length} pages and ${componentValues.length} filled fields',
          formData: formData,
          originalConfigKey: 'multi_page_form',
        );

        debugPrint(
          '✅ [SaveForm] Form saved successfully with ${componentValues.length} component values',
        );
      } else {
        debugPrint('❌ [SaveForm] Form model is null, cannot save');
      }
    } catch (e) {
      debugPrint('❌ [SaveForm] Error saving form: $e');
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

  Widget _bodyWidget(BuildContext context, MultiPageFormSuccess state) {
    debugPrint(
      '[UI] Building page. Total pages: ${state.formModel?.pages.length}, Current page index: ${state.currentPageIndex}, Current page ID: ${state.formModel?.pages[state.currentPageIndex].pageId}',
    );

    final isLastPage = state.formModel == null
        ? true
        : state.currentPageIndex == state.formModel!.pages.length - 1;

    final showNext = page.showNextButton;
    final showPrevious = page.showPreviousButton;

    // Find navigation/submit buttons by action
    DynamicFormModel? nextButton = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              component.config.action == ButtonAction.nextPage.value,
        )
        .map((component) => _toDynamicFormModel(component))
        .cast<DynamicFormModel?>()
        .firstWhere((b) => b != null, orElse: () => null);
    DynamicFormModel? previousButton = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              component.config.action == ButtonAction.previousPage.value,
        )
        .map((component) => _toDynamicFormModel(component))
        .cast<DynamicFormModel?>()
        .firstWhere((b) => b != null, orElse: () => null);
    // Only show preview button on the last page (no submit button on finish page)
    DynamicFormModel? previewButton = isLastPage
        ? page.components
              .where(
                (component) =>
                    component.type == FormTypeEnum.buttonFormType &&
                    component.config.action == ButtonAction.previewForm.value,
              )
              .map((component) => _toDynamicFormModel(component))
              .cast<DynamicFormModel?>()
              .firstWhere((b) => b != null, orElse: () => null)
        : null;
    // Submit button is not shown on finish page - it will be in preview screen
    DynamicFormModel? submitButton = null;

    debugPrint('🔍 [ButtonDetection] isLastPage: $isLastPage');
    debugPrint('🔍 [ButtonDetection] previewButton: ${previewButton?.id}');
    debugPrint('🔍 [ButtonDetection] submitButton: ${submitButton?.id}');

    final requiredIds = <String>{};
    for (final button in [nextButton]) {
      final validate = button?.config?.validate;
      if (validate != null &&
          validate is Map<String, dynamic> &&
          validate['condition'] is List) {
        for (final cond in validate['condition']) {
          if (cond['is_required'] == true && cond['id_component'] != null) {
            requiredIds.add(cond['id_component']);
          }
        }
      }
    }

    // Filter out navigation/submit/preview buttons from main components
    final otherComponents = page.components
        .where(
          (component) =>
              !(component.type == FormTypeEnum.buttonFormType &&
                  (component.config.action == ButtonAction.submitForm.value ||
                      component.config.action ==
                          ButtonAction.previousPage.value ||
                      component.config.action == ButtonAction.nextPage.value ||
                      component.config.action ==
                          ButtonAction.previewForm.value)),
        )
        .map((component) {
          final model = _toDynamicFormModel(component);
          // Set value for the component
          final oldValue = model.config?.value;
          final newValue = allComponentValues[model.id];
          debugPrint(
            '🔍 [MultiPageWidget] Component ${model.id}: oldValue=$oldValue, newValue=$newValue',
          );
          final updatedConfig = model.config?.copyWith(value: newValue);
          final updatedModel = DynamicFormModel(
            id: model.id,
            type: model.type,
            order: model.order,
            config: updatedConfig,
            style: model.style,
            inputTypes: model.inputTypes,
            variants: model.variants,
            states: model.states,
            validation: model.validation,
            children: model.children,
          );
          return updatedModel;
        })
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          _buildListViewWidget(context, otherComponents, state),
          _buildButtonsRowWidget(
            context,
            showPrevious ? previousButton : null,
            showNext ? nextButton : null,
            previewButton,
            submitButton,
            otherComponents,
            state,
          ),
        ],
      ),
    );
  }

  bool _validateButtonConditions(
    DynamicFormModel button,
    BuildContext context, {
    bool showDialogOnError = true,
  }) {
    final validate = button.validation?.toJson();
    debugPrint(
      '🔍 [ButtonValidation] Validating button  [33m${button.id} [0m: $validate',
    );
    final conditions =
        (validate != null && validate is Map && validate['condition'] is List)
        ? List<Map<String, dynamic>>.from(validate['condition'])
        : [];
    debugPrint('🔍 [ButtonValidation] Conditions: $conditions');

    final List<String> errors = [];
    for (final cond in conditions) {
      final id = cond['id_component'];
      final value = allComponentValues[id];
      debugPrint(
        '🔍 [ButtonValidation] Checking $id: value=$value, condition=$cond',
      );

      if (cond['is_required'] == true &&
          (value == null ||
              (value is bool
                  ? value == false
                  : value.toString().trim().isEmpty))) {
        errors.add(cond['error_message']?.toString() ?? 'Required');
        debugPrint('❌ [ButtonValidation] Required validation failed for $id');
      } else if ((cond['regex'] ?? '').toString().isNotEmpty) {
        final regex = RegExp(cond['regex']);
        if (value != null &&
            value.toString().isNotEmpty &&
            !regex.hasMatch(value.toString())) {
          errors.add(
            cond['regex_error']?.toString() ??
                cond['error_message']?.toString() ??
                'Invalid format',
          );
          debugPrint('❌ [ButtonValidation] Regex validation failed for $id');
        }
      }
    }

    if (errors.isNotEmpty) {
      debugPrint('❌ [ButtonValidation] Errors for ${button.id}: $errors');
      if (showDialogOnError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Validation Errors'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors.map((e) => Text('- $e')).toList(),
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
      return false;
    }

    debugPrint('✅ [ButtonValidation] Button ${button.id} passed validation');
    return true;
  }

  DynamicFormModel _toDynamicFormModel(
    FormComponentMultiPageModel componentModel,
  ) {
    dynamic styleData = componentModel.style;
    if (styleData is StyleStatesModel) {
      styleData = styleData.toJson();
    }

    final validation = componentModel.validation;
    if (validation != null) {
      debugPrint(
        '🔍 [MultiPageWidget] Assigned validation for ${componentModel.id}:  [33m${componentModel.validation} [0m',
      );
    }
    return DynamicFormModel(
      id: componentModel.id,
      type: componentModel.type,
      order: componentModel.order,
      config: componentModel.config,
      style: styleData == null
          ? const StyleModel()
          : (styleData is StyleModel
                ? styleData
                : StyleModel.fromJson(styleData)),
      validation: validation,
      children: const [],
    );
  }

  void _handlePreviewFormAction(
    BuildContext context,
    MultiPageFormState state,
  ) async {
    if (state is MultiPageFormSuccess && state.formModel != null) {
      // Convert FormForMultiPageModel to DynamicFormPageModel
      final dynamicPages = state.formModel!.pages
          .map(
            (page) => DynamicFormPageModel(
              pageId: page.pageId,
              title: page.title,
              order: page.order,
              components: page.components
                  .map(
                    (c) => DynamicFormModel(
                      id: c.id,
                      type: c.type,
                      order: c.order,
                      config: c.config,
                      style: c.style,
                      inputTypes: null,
                      variants: null,
                      states: null,
                      validation: c.validation,
                      children: c.children != null
                          ? c.children!
                                .map(
                                  (child) => DynamicFormModel(
                                    id: child.id,
                                    type: child.type,
                                    order: child.order,
                                    config: child.config,
                                    style: child.style,
                                    inputTypes: null,
                                    variants: null,
                                    states: null,
                                    validation: child.validation,
                                    children: null,
                                  ),
                                )
                                .toList()
                          : null,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => PreviewMultiPageScreen(
            pages: dynamicPages,
            allComponentValues: state.componentValues,
          ),
        ),
      );
    }
  }
}
