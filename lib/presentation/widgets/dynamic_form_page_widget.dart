import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/config_enum.dart';
import 'package:dynamic_form_bi/core/enums/remote_button_config_key_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'dart:convert';
import 'package:dynamic_form_bi/presentation/screens/preview_multipage_screen.dart';

class DynamicFormPageWidget extends StatefulWidget {
  final FormForMultiPageModel page;
  final Map<String, dynamic> allComponentValues;

  const DynamicFormPageWidget({
    super.key,
    required this.page,
    required this.allComponentValues,
  });

  @override
  State<DynamicFormPageWidget> createState() => _DynamicFormPageWidgetState();
}

class _DynamicFormPageWidgetState extends State<DynamicFormPageWidget> {
  @override
  Widget build(BuildContext context) {
    final multiPageBloc = context.read<MultiPageFormBloc>();
    final state = multiPageBloc.state;
    final isFirstPage = state.currentPageIndex == 0;
    final isLastPage = state.formModel == null
        ? true
        : state.currentPageIndex == state.formModel!.pages.length - 1;

    final List<DynamicFormModel> navigateButtons = [];
    final List<DynamicFormModel> otherComponents = [];
    for (final componentModel in widget.page.components) {
      final model = DynamicFormModel(
        id: componentModel.id,
        type: componentModel.type,
        order: componentModel.order,
        config: Map<String, dynamic>.from(componentModel.config),
        style: componentModel.style,
        validation: componentModel.validation,
        children: const [],
      );
      final isNavigateButton =
          componentModel.type == FormTypeEnum.buttonFormType &&
          (componentModel.config[ConfigEnum.action.value] ==
                  ButtonAction.previousPage.value ||
              componentModel.config[ConfigEnum.action.value] ==
                  ButtonAction.nextPage.value);
      final isSubmitButton =
          componentModel.type == FormTypeEnum.buttonFormType &&
          componentModel.config[ConfigEnum.action.value] ==
              ButtonAction.submitForm.value;

      if (isNavigateButton) {
        navigateButtons.add(model);
      } else if (!isSubmitButton) {
        otherComponents.add(model);
      }
    }

    // Add required field validation for current page
    final bool isCurrentPageValid = otherComponents.every((comp) {
      final isRequired =
          comp.config['is_required'] == true ||
          (((comp.validation?['required']
                  as Map<String, dynamic>?)?['is_required']) ==
              true);
      final value = widget.allComponentValues[comp.id];
      return !isRequired ||
          (value != null && value.toString().trim().isNotEmpty);
    });

    DynamicFormModel? previousButton =
        navigateButtons
            .where(
              (b) =>
                  b.config[ConfigEnum.action.value] ==
                  ButtonAction.previousPage.value,
            )
            .isNotEmpty
        ? navigateButtons
              .where(
                (b) =>
                    b.config[ConfigEnum.action.value] ==
                    ButtonAction.previousPage.value,
              )
              .first
        : null;
    DynamicFormModel? nextButton =
        navigateButtons
            .where(
              (b) =>
                  b.config[ConfigEnum.action.value] ==
                  ButtonAction.nextPage.value,
            )
            .isNotEmpty
        ? navigateButtons
              .where(
                (b) =>
                    b.config[ConfigEnum.action.value] ==
                    ButtonAction.nextPage.value,
              )
              .first
        : null;
    // Add previewButton for last page
    DynamicFormModel? previewButton;
    if (isLastPage) {
      previewButton = buildPreviewButtonDynamicFormModel();
      // Remove preview button from otherComponents if present (to avoid double render)
      otherComponents.removeWhere(
        (c) =>
            c.config[ConfigEnum.action.value] == ButtonAction.previewForm.value,
      );
      // Remove nextButton if present
      nextButton = null;
    }

    if (previousButton == null && !isFirstPage && widget.page.showPrevious) {
      previousButton = buildPreviousButtonDynamicFormModel();
    }
    if (nextButton == null && !isLastPage) {
      nextButton = buildNextButtonDynamicFormModel();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: otherComponents.length,
            itemBuilder: (context, index) {
              final componentModel = otherComponents[index];
              componentModel.config[ValueKeyEnum.value.key] =
                  widget.allComponentValues[componentModel.id];
              return DynamicFormRenderer(
                component: componentModel,
                onFieldChanged: (componentId, value) {
                  final newValue =
                      value is Map && value.containsKey(ValueKeyEnum.value.key)
                      ? value[ValueKeyEnum.value.key]
                      : value;
                  multiPageBloc.add(
                    UpdateComponentValue(componentId, newValue),
                  );
                },
                onButtonAction: (action, data) async {
                  if (action == ButtonAction.previewForm.value) {
                    final allPages = state.formModel?.pages ?? [];
                    final mappedData = <String, dynamic>{};
                    for (final p in allPages) {
                      for (final comp in p.components) {
                        mappedData[comp.id] =
                            widget.allComponentValues[comp.id];
                      }
                    }
                    // Before showDialog, find the submit button from all pages
                    DynamicFormModel? submitButton;
                    for (final page in allPages) {
                      for (final comp in page.components) {
                        if (comp.type == FormTypeEnum.buttonFormType &&
                            comp.config[ConfigEnum.action.value] ==
                                ButtonAction.submitForm.value) {
                          submitButton = DynamicFormModel(
                            id: comp.id,
                            type: comp.type,
                            order: comp.order,
                            config: Map<String, dynamic>.from(comp.config),
                            style: comp.style,
                            validation: comp.validation,
                            children: null, // Fix type error
                          );
                          break;
                        }
                      }
                      if (submitButton != null) break;
                    }
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Preview Data'),
                          content: SingleChildScrollView(
                            child: Text(mappedData.toString()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                            if (submitButton != null)
                              DynamicFormRenderer(
                                component: submitButton,
                                onButtonAction: (action, data) async {
                                  // Reuse the same logic as the main form
                                  if (action == ButtonAction.submitForm.value) {
                                    bool isValid = true;
                                    for (final page in allPages) {
                                      for (final comp in page.components) {
                                        final isRequired =
                                            comp.config['is_required'] ==
                                                true ||
                                            (((comp.validation?['required']
                                                    as Map<
                                                      String,
                                                      dynamic
                                                    >?)?['is_required']) ==
                                                true);
                                        final value =
                                            widget.allComponentValues[comp.id];
                                        if (isRequired &&
                                            (value == null ||
                                                (value is String &&
                                                    value.trim().isEmpty))) {
                                          isValid = false;
                                          break;
                                        }
                                      }
                                      if (!isValid) break;
                                    }
                                    if (isValid) {
                                      multiPageBloc.add(
                                        const SubmitMultiPageForm(),
                                      );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Form submitted successfully.',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please fill all required fields.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              )
                            else
                              const ElevatedButton(
                                onPressed: null,
                                child: Text('No Save button found'),
                              ),
                          ],
                        );
                      },
                    );
                  }
                },
              );
            },
          ),
        ),
        if (previousButton != null ||
            nextButton != null ||
            previewButton != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (previousButton != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DynamicFormRenderer(
                        component: previousButton,
                        onButtonAction: (action, data) {
                          if (widget.page.showPrevious) {
                            multiPageBloc.add(
                              const NavigateToPage(isNext: false),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                if (nextButton != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: isCurrentPageValid ? 1.0 : 0.5,
                        child: DynamicFormRenderer(
                          component: nextButton,
                          onButtonAction: (action, data) {
                            if (!isCurrentPageValid) {
                              // Find all required fields that are empty
                              final missingFields = otherComponents.where((
                                comp,
                              ) {
                                final isRequired =
                                    comp.config['is_required'] == true ||
                                    (((comp.validation?['required']
                                            as Map<
                                              String,
                                              dynamic
                                            >?)?['is_required']) ==
                                        true);
                                final value =
                                    widget.allComponentValues[comp.id];
                                return isRequired &&
                                    (value == null ||
                                        value.toString().trim().isEmpty);
                              }).toList();
                              final missingLabels = missingFields
                                  .map(
                                    (comp) =>
                                        comp.config['label']?.toString() ??
                                        comp.id,
                                  )
                                  .toList();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Required Fields'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Please fill the following required fields:',
                                      ),
                                      const SizedBox(height: 8),
                                      ...missingLabels
                                          .map((label) => Text('- $label'))
                                          .toList(),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            multiPageBloc.add(
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
                          final allPages = state.formModel?.pages ?? [];
                          List<DynamicFormPageModel> dynamicPages = allPages
                              .map(
                                (page) => DynamicFormPageModel(
                                  pageId: page.pageId,
                                  title: page.title,
                                  order: page.order,
                                  components: page.components
                                      .map(
                                        (comp) => DynamicFormModel(
                                          id: comp.id,
                                          type: comp.type,
                                          order: comp.order,
                                          config: Map<String, dynamic>.from(
                                            comp.config,
                                          ),
                                          style: Map<String, dynamic>.from(
                                            comp.style,
                                          ),
                                          validation: comp.validation,
                                          children:
                                              comp.children
                                                  ?.map(
                                                    (child) => DynamicFormModel(
                                                      id: child.id,
                                                      type: child.type,
                                                      order: child.order,
                                                      config:
                                                          Map<
                                                            String,
                                                            dynamic
                                                          >.from(child.config),
                                                      style:
                                                          Map<
                                                            String,
                                                            dynamic
                                                          >.from(child.style),
                                                      validation:
                                                          child.validation,
                                                      children: [],
                                                    ),
                                                  )
                                                  .toList() ??
                                              [],
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewMultiPageScreen(
                                pages: dynamicPages,
                                allComponentValues: widget.allComponentValues,
                                onPrevious: () => Navigator.of(context).pop(),
                                onSubmit: () async {
                                  bool isValid = true;
                                  for (final page in allPages) {
                                    for (final comp in page.components) {
                                      final isRequired =
                                          comp.config['is_required'] == true ||
                                          (((comp.validation?['required']
                                                  as Map<
                                                    String,
                                                    dynamic
                                                  >?)?['is_required']) ==
                                              true);
                                      final value =
                                          widget.allComponentValues[comp.id];
                                      if (isRequired &&
                                          (value == null ||
                                              (value is String &&
                                                  value.trim().isEmpty))) {
                                        isValid = false;
                                        break;
                                      }
                                    }
                                    if (!isValid) break;
                                  }
                                  if (isValid) {
                                    multiPageBloc.add(
                                      const SubmitMultiPageForm(),
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Form submitted successfully.',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please fill all required fields.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  DynamicFormModel? buildNextButtonDynamicFormModel() {
    final jsonString = RemoteConfigService().getString(
      RemoteButtonConfigKey.nextButton.key,
    );
    if (jsonString.isNotEmpty) {
      return DynamicFormModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  DynamicFormModel? buildPreviousButtonDynamicFormModel() {
    final jsonString = RemoteConfigService().getString(
      RemoteButtonConfigKey.previousButton.key,
    );
    if (jsonString.isNotEmpty) {
      return DynamicFormModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  DynamicFormModel? buildPreviewButtonDynamicFormModel() {
    final jsonString = RemoteConfigService().getString(
      RemoteButtonConfigKey.previewButton.key,
    );
    if (jsonString.isNotEmpty) {
      return DynamicFormModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }
}
