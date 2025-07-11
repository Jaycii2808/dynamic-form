import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/config_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi_model.dart';
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
    return BlocConsumer<MultiPageFormBloc, MultiPageFormState>(
      listener: (context, state) {
        if (state is MultiPageFormError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
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

  Widget _bodyWidget(BuildContext context, MultiPageFormSuccess state) {
    // final isFirstPage = state.currentPageIndex == 0;
    // final isLastPage = state.formModel == null
    //     ? true
    //     : state.currentPageIndex == state.formModel!.pages.length - 1;

    final showNext = page.showNextButton;
    final showPrevious = page.showPreviousButton;
    final showSubmit = false;

    // Find navigation/submit buttons by action
    DynamicFormModel? nextButton = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              component.config[ConfigEnum.action.value] ==
                  ButtonAction.nextPage.value,
        )
        .map((component) => _toDynamicFormModel(component))
        .cast<DynamicFormModel?>()
        .firstWhere((b) => b != null, orElse: () => null);
    DynamicFormModel? previousButton = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              component.config[ConfigEnum.action.value] ==
                  ButtonAction.previousPage.value,
        )
        .map((component) => _toDynamicFormModel(component))
        .cast<DynamicFormModel?>()
        .firstWhere((b) => b != null, orElse: () => null);
    DynamicFormModel? submitButton = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              component.config[ConfigEnum.action.value] ==
                  ButtonAction.submitForm.value,
        )
        .map((component) => _toDynamicFormModel(component))
        .cast<DynamicFormModel?>()
        .firstWhere((b) => b != null, orElse: () => null);
    // Không lấy submitButton ở đây nữa
    DynamicFormModel? previewButton = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              component.config[ConfigEnum.action.value] ==
                  ButtonAction.previewForm.value,
        )
        .map((component) => _toDynamicFormModel(component))
        .cast<DynamicFormModel?>()
        .firstWhere((b) => b != null, orElse: () => null);

    final requiredIds = <String>{};
    for (final button in [nextButton, submitButton]) {
      final validate = button?.validation;
      if (validate != null && validate['condition'] is List) {
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
                  (component.config[ConfigEnum.action.value] ==
                          ButtonAction.submitForm.value ||
                      component.config[ConfigEnum.action.value] ==
                          ButtonAction.previousPage.value ||
                      component.config[ConfigEnum.action.value] ==
                          ButtonAction.nextPage.value ||
                      component.config[ConfigEnum.action.value] ==
                          ButtonAction.previewForm.value)),
        )
        .map((component) {
          final model = _toDynamicFormModel(component);
          // Set is_required flag cho widget con
          model.config['is_required'] = requiredIds.contains(model.id);
          return model;
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
            showSubmit ? submitButton : null,
            previewButton,
            otherComponents,
            state,
          ),
        ],
      ),
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
        componentModel.config[ValueKeyEnum.value.key] =
            allComponentValues[componentModel.id];

        return DynamicFormRenderer(
          component: componentModel,
          onFieldChanged: (componentId, value) {
            final newValue =
                value is Map && value.containsKey(ValueKeyEnum.value.key)
                ? value[ValueKeyEnum.value.key]
                : value;
            context.read<MultiPageFormBloc>().add(
              UpdateComponentValue(componentId, newValue),
            );
          },
          onButtonAction: (action, data) async {
            if (action == ButtonAction.previewForm.value) {
              _handlePreviewFormAction(context, state);
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
    DynamicFormModel? submitButton,
    DynamicFormModel? previewButton,
    List<DynamicFormModel> otherComponents,
    MultiPageFormState state,
  ) {
    final multiPageBloc = context.read<MultiPageFormBloc>();
    if (previousButton == null &&
        nextButton == null &&
        submitButton == null &&
        previewButton == null) {
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
                        if (!_validateButtonConditions(
                          previousButton,
                          context,
                          showDialogOnError: true,
                        )) {
                          return;
                        }

                        final validate = previousButton.validation;
                        final targetPage =
                            validate?['previous_page'] as String?;

                        if (targetPage != null) {
                          final targetIndex = state.formModel?.pages.indexWhere(
                            (p) => p.pageId == targetPage,
                          );
                          if (targetIndex != null && targetIndex >= 0) {
                            multiPageBloc.add(
                              NavigateToPageByIndex(targetIndex),
                            );
                          } else {
                            multiPageBloc.add(
                              const NavigateToPage(isNext: false),
                            );
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
                        if (!_validateButtonConditions(
                          nextButton,
                          context,
                          showDialogOnError: true,
                        )) {
                          return;
                        }
                        multiPageBloc.add(const NavigateToPage(isNext: true));
                      },
                    ),
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
                      onButtonAction: (action, data) {
                        if (!_validateButtonConditions(
                          submitButton,
                          context,
                          showDialogOnError: true,
                        )) {
                          return;
                        }
                        multiPageBloc.add(const SubmitMultiPageForm());
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
                                  .map((comp) => _toDynamicFormModel(comp))
                                  .toList(),
                            ),
                          )
                          .toList();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewMultiPageScreen(
                            pages: dynamicPages,
                            allComponentValues: allComponentValues,
                            onPrevious: () => Navigator.of(context).pop(),
                            onSubmit: () async {
                              multiPageBloc.add(const SubmitMultiPageForm());
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
    );
  }

  bool _validateButtonConditions(
    DynamicFormModel button,
    BuildContext context, {
    bool showDialogOnError = true,
  }) {
    final validate = button.validation;
    final conditions = (validate != null && validate['condition'] is List)
        ? validate['condition'] as List
        : [];
    debugPrint(
      'Validating button: ${button.id}, conditions: ${conditions.length}',
    );
    final List<String> errors = [];
    for (final cond in conditions) {
      final id = cond['id_component'];
      final value = allComponentValues[id];
      debugPrint(
        'Checking condition for component: $id, value: $value, cond: $cond',
      );
      if (cond['is_required'] == true &&
          (value == null ||
              (value is bool
                  ? value == false
                  : value.toString().trim().isEmpty))) {
        errors.add(cond['error_message']?.toString() ?? 'Required');
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
        }
      }
    }
    if (errors.isNotEmpty) {
      debugPrint('Validation errors for button ${button.id}: $errors');
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
    debugPrint('Button ${button.id} passed validation');
    return true;
  }

  DynamicFormModel _toDynamicFormModel(
    FormComponentMultiPageModel componentModel,
  ) {
    return DynamicFormModel(
      id: componentModel.id,
      type: componentModel.type,
      order: componentModel.order,
      config: Map<String, dynamic>.from(componentModel.config),
      style: componentModel.style,
      validation:
          componentModel.validation ?? componentModel.config['validate'],
      children: const [],
    );
  }

  void _handlePreviewFormAction(
    BuildContext context,
    MultiPageFormState state,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Preview Action"),
        content: const Text("Preview logic would be handled here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
