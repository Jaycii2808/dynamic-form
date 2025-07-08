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
      if (componentModel.type == FormTypeEnum.buttonFormType &&
          (componentModel.config[ConfigEnum.action.value] ==
              ButtonAction.previousPage.value ||
              componentModel.config[ConfigEnum.action.value] ==
                  ButtonAction.nextPage.value)) {
        navigateButtons.add(model);
      } else {
        otherComponents.add(model);
      }
    }

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
                          ],
                        );
                      },
                    );
                  } else if (action == ButtonAction.submitForm.value) {
                    bool isValid = true;
                    final allPages = state.formModel?.pages ?? [];
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
                        final value = widget.allComponentValues[comp.id];
                        if (isRequired &&
                            (value == null ||
                                (value is String && value.trim().isEmpty))) {
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Form submitted successfully.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields.'),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        if (previousButton != null || nextButton != null)
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
                      child: DynamicFormRenderer(
                        component: nextButton,
                        onButtonAction: (action, data) {
                          multiPageBloc.add(const NavigateToPage(isNext: true));
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
}
