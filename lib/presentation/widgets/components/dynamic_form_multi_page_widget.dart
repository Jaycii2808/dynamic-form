import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/form_submission_converter.dart';
import 'package:dynamic_form_bi/data/models/components/component_value_update_model.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/components/field_update_data_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_data_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/validation/button_condition_validation_model.dart';
import 'package:dynamic_form_bi/core/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_state.dart';
import 'package:dynamic_form_bi/presentation/screens/preview_page_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DynamicFormMultiPageWidget extends StatelessWidget {
  final FormForMultiPageModel page;
  final ComponentValuesModel allComponentValues;

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
        final newValue = allComponentValues.values[componentModel.id];
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
            // Create ComponentValueUpdateModel from the value
            ComponentValueUpdateModel updateModel;

            if (value is ComponentValueUpdateModel) {
              updateModel = value;
            } else if (value is FieldUpdateDataModel) {
              // Handle FieldUpdateDataModel format
              updateModel = ComponentValueUpdateModel.create(
                componentId: componentId,
                value: value.value,
                currentState: value.currentState,
                errorText: value.errorText,
                selected: value.selected,
              );
            } else if (value is Map && value.containsKey('value')) {
              // Handle legacy Map format
              updateModel = ComponentValueUpdateModel.create(
                componentId: componentId,
                value: value['value'],
                currentState: value['current_state'],
                errorText: value['error_text'],
                selected: value['selected'],
              );
            } else {
              // Handle simple value
              updateModel = ComponentValueUpdateModel.create(
                componentId: componentId,
                value: value,
              );
            }

            context.read<MultiPageFormBloc>().add(
              UpdateComponentValue(componentId, updateModel),
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
                context.pop();
              }
              return;
            }
            // Handle next_page navigation from ListView button
            if (action == ButtonAction.nextPage.value) {
              String? targetPage = data?.targetPage;
              if (targetPage == null || targetPage.isEmpty) {
                final validation = updatedComponent.validation;
                if (validation is ButtonConditionValidationModel) {
                  targetPage = validation.nextPage;
                }
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
                        final validation = previousButton.validation;
                        String? targetPage;
                        if (validation is ButtonConditionValidationModel) {
                          targetPage = validation.previousPage;
                        }
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
                          String? targetPage = data?.targetPage;
                          if (targetPage == null || targetPage.isEmpty) {
                            final validation = nextButton.validation;
                            if (validation is ButtonConditionValidationModel) {
                              targetPage = validation.nextPage;
                            }
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
                        // Always validate before proceeding
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
                            context.pop();
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
    ComponentValuesModel componentValues,
  ) async {
    debugPrint('🔄 [SaveForm] Starting to save form data...');
    debugPrint(
      '🔄 [SaveForm] Component values count: ${componentValues.length}',
    );
    debugPrint(
      '🔄 [SaveForm] Form model pages count: ${state.formModel?.pages.length}',
    );
    debugPrint('🔄 [SaveForm] Component values: ${componentValues.values}');

    // Create readable submission model for better debugging and email sending
    if (state.formModel != null) {
      final submissionModel = FormSubmissionConverter.convertToSubmissionModel(
        componentValues: componentValues,
        formModel: state.formModel!,
      );

      // Debug print readable format instead of complex IDs
      FormSubmissionConverter.debugPrintSubmission(submissionModel);

      // Print email format for easy copying
      debugPrint('📧 Email Format:');
      debugPrint(submissionModel.toEmailFormat());
      debugPrint('📊 Simple Map Format:');
      debugPrint(submissionModel.toSimpleMap().toString());
    }

    try {
      final savedFormsService = SavedFormsService();

      if (state.formModel != null) {
        // Create updated form model with current component values
        final updatedPages = List<FormForMultiPageModel>.generate(
          state.formModel!.pages.length,
          (pageIndex) {
            final page = state.formModel!.pages[pageIndex];
            final updatedComponents =
                List<FormComponentMultiPageModel>.generate(
                  page.components.length,
                  (componentIndex) {
                    final component = page.components[componentIndex];
                    if (componentValues.hasValue(component.id)) {
                      final updatedConfig = component.config.copyWith(
                        value: componentValues.getValue(component.id),
                      );
                      return component.copyWith(config: updatedConfig);
                    }
                    return component;
                  },
                );

            return page.copyWith(components: updatedComponents);
          },
        );

        final updatedFormModel = state.formModel!.copyWith(pages: updatedPages);

        // Use the new SavedFormDataModel instead of List<Map<String, dynamic>>
        final savedFormData = SavedFormDataBuilder.createFromMultiPageForm(
          formId: 'multi_page_form_${DateTime.now().millisecondsSinceEpoch}',
          pages: updatedFormModel.pages,
          componentValues: componentValues.toJson(),
        );

        debugPrint('🔄 [SaveForm] Calling saveFormWithCustomFormat...');
        debugPrint('🔄 [SaveForm] Saved form data: ${savedFormData.toJson()}');

        await savedFormsService.saveFormWithCustomFormat(
          formId: savedFormData.formId,
          name:
              'Multi-Page Form - ${DateTime.now().toString().substring(0, 19)}',
          description:
              'Form with ${updatedFormModel.pages.length} pages and ${componentValues.length} filled fields',
          formData: savedFormData.toJson(),
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

    // Find navigation/submit buttons by action using explicit loops
    DynamicFormModel? nextButton;
    DynamicFormModel? previousButton;
    DynamicFormModel? previewButton;
    DynamicFormModel? submitButton;

    // Find next button
    for (final component in page.components) {
      if (component.type == FormTypeEnum.buttonFormType &&
          component.config.action == ButtonAction.nextPage.value) {
        nextButton = _toDynamicFormModel(component);
        break;
      }
    }

    // Find previous button
    for (final component in page.components) {
      if (component.type == FormTypeEnum.buttonFormType &&
          component.config.action == ButtonAction.previousPage.value) {
        previousButton = _toDynamicFormModel(component);
        break;
      }
    }

    // Only show preview button on the last page
    if (isLastPage) {
      for (final component in page.components) {
        if (component.type == FormTypeEnum.buttonFormType &&
            component.config.action == ButtonAction.previewForm.value) {
          previewButton = _toDynamicFormModel(component);
          break;
        }
      }
    }

    // Find submit button - only show on the last page
    if (isLastPage) {
      for (final component in page.components) {
        if (component.type == FormTypeEnum.buttonFormType &&
            component.config.action == ButtonAction.submitForm.value) {
          submitButton = _toDynamicFormModel(component);
          break;
        }
      }
    }

    debugPrint('🔍 [ButtonDetection] isLastPage: $isLastPage');
    debugPrint('🔍 [ButtonDetection] previewButton: ${previewButton?.id}');
    debugPrint('🔍 [ButtonDetection] submitButton: ${submitButton?.id}');

    final requiredIds = <String>{};
    for (final button in [nextButton, submitButton]) {
      if (button != null) {
        final validation = button.validation;
        if (validation is ButtonConditionValidationModel) {
          for (final condition in validation.conditions) {
            if (condition.isRequired == true &&
                condition.idComponent.isNotEmpty) {
              requiredIds.add(condition.idComponent);
            }
          }
        }
      }
    }

    // Filter out navigation/submit/preview buttons from main components
    final List<DynamicFormModel> otherComponents = [];
    for (final component in page.components) {
      final isNavigationButton =
          component.type == FormTypeEnum.buttonFormType &&
          (component.config.action == ButtonAction.submitForm.value ||
              component.config.action == ButtonAction.previousPage.value ||
              component.config.action == ButtonAction.nextPage.value ||
              component.config.action == ButtonAction.previewForm.value);

      if (!isNavigationButton) {
        final model = _toDynamicFormModel(component);
        // Set value for the component
        final oldValue = model.config?.value;
        final newValue = allComponentValues.values[model.id];
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
        otherComponents.add(updatedModel);
      }
    }

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
    // Use specific validation model instead of map
    final validation = button.validation;
    debugPrint(
      '🔍 [ButtonValidation] Validating button ${button.id}: $validation',
    );

    // Handle ButtonConditionValidation specifically
    if (validation is ButtonConditionValidationModel) {
      final conditions = validation.conditions;
      debugPrint('🔍 [ButtonValidation] Conditions: $conditions');

      final List<String> errors = [];
      for (final condition in conditions) {
        final id = condition.idComponent;
        final value = allComponentValues.values[id];
        debugPrint(
          '🔍 [ButtonValidation] Checking $id: value=$value, condition=$condition',
        );

        if (condition.isRequired == true &&
            (value == null ||
                (value is bool
                    ? value == false
                    : value.toString().trim().isEmpty))) {
          errors.add(condition.errorMessage?.toString() ?? 'Required');
          debugPrint('❌ [ButtonValidation] Required validation failed for $id');
        } else if ((condition.regex ?? '').toString().isNotEmpty) {
          final regex = RegExp(condition.regex!);
          if (value != null &&
              value.toString().isNotEmpty &&
              !regex.hasMatch(value.toString())) {
            errors.add(
              condition.regexError?.toString() ??
                  condition.errorMessage?.toString() ??
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
                //determines how many error messages are in the errors list
                children: List<Widget>.generate(
                  errors.length,
                  (index) => Text('- ${errors[index]}'),
                ),
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
        return false;
      }

      debugPrint('✅ [ButtonValidation] Button ${button.id} passed validation');
      return true;
    }

    // Fallback for other validation types
    debugPrint(
      '⚠️ [ButtonValidation] Unknown validation type: ${validation.runtimeType}',
    );
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
      // Convert FormForMultiPageModel to DynamicFormPageModel using explicit loops
      final List<DynamicFormPageModel> dynamicPages = [];

      for (final page in state.formModel!.pages) {
        final List<DynamicFormModel> pageComponents = [];

        for (final component in page.components) {
          final List<DynamicFormModel> childComponents = [];

          if (component.children != null) {
            for (final child in component.children!) {
              childComponents.add(
                DynamicFormModel(
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
              );
            }
          }

          // Update component config with current component values
          ConfigModel updatedConfig = component.config;
          if (state.componentValues.hasValue(component.id)) {
            updatedConfig = component.config.copyWith(
              value: state.componentValues.getValue(component.id),
            );
          }

          pageComponents.add(
            DynamicFormModel(
              id: component.id,
              type: component.type,
              order: component.order,
              config: updatedConfig,
              style: component.style,
              inputTypes: null,
              variants: null,
              states: null,
              validation: component.validation,
              children: childComponents,
            ),
          );
        }

        dynamicPages.add(
          DynamicFormPageModel(
            pageId: page.pageId,
            title: page.title,
            order: page.order,
            components: pageComponents,
          ),
        );
      }

      context.push(
        PreviewPageScreen.routeName,
        extra: {
          'pages': dynamicPages,
          'values': state.componentValues,
        },
      );
    }
  }
}
