import 'dart:convert';
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/config_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/remote_button_config_key_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
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
    final isFirstPage = state.currentPageIndex == 0;
    final isLastPage = state.formModel == null
        ? true
        : state.currentPageIndex == state.formModel!.pages.length - 1;

    final navigateButtons = page.components
        .where(
          (component) =>
              component.type == FormTypeEnum.buttonFormType &&
              (component.config[ConfigEnum.action.value] ==
                      ButtonAction.previousPage.value ||
                  component.config[ConfigEnum.action.value] ==
                      ButtonAction.nextPage.value),
        )
        .map((component) => _toDynamicFormModel(component))
        .toList();

    final otherComponents = page.components
        .where(
          (component) =>
              !(component.type == FormTypeEnum.buttonFormType &&
                  component.config[ConfigEnum.action.value] ==
                      ButtonAction.submitForm.value) &&
              !(component.type == FormTypeEnum.buttonFormType &&
                  (component.config[ConfigEnum.action.value] ==
                          ButtonAction.previousPage.value ||
                      component.config[ConfigEnum.action.value] ==
                          ButtonAction.nextPage.value)),
        )
        .map((component) => _toDynamicFormModel(component))
        .toList();

    final bool isCurrentPageValid = otherComponents.every(
      (comp) => !_isComponentRequired(comp, allComponentValues),
    );

    DynamicFormModel? previousButton = navigateButtons.firstWhere(
      (b) =>
          b.config[ConfigEnum.action.value] == ButtonAction.previousPage.value,
      orElse: () => DynamicFormModel.empty(),
    );
    if (previousButton.id.isEmpty) previousButton = null;

    DynamicFormModel? nextButton = navigateButtons.firstWhere(
      (b) => b.config[ConfigEnum.action.value] == ButtonAction.nextPage.value,
      orElse: () => DynamicFormModel.empty(),
    );
    if (nextButton.id.isEmpty) nextButton = null;

    DynamicFormModel? previewButton;
    if (isLastPage) {
      previewButton = _getRemoteButton(RemoteButtonConfigKey.previewButton);
      otherComponents.removeWhere(
        (c) =>
            c.config[ConfigEnum.action.value] == ButtonAction.previewForm.value,
      );
      nextButton = null;
    }

    if (previousButton == null && !isFirstPage && page.showPrevious) {
      previousButton = _getRemoteButton(RemoteButtonConfigKey.previousButton);
    }
    if (nextButton == null && !isLastPage) {
      nextButton = _getRemoteButton(RemoteButtonConfigKey.nextButton);
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildListViewWidget(context, otherComponents, state),
          _buildButtonsRowWidget(
            context,
            previousButton,
            nextButton,
            previewButton,
            isCurrentPageValid,
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
    DynamicFormModel? previewButton,
    bool isCurrentPageValid,
    List<DynamicFormModel> otherComponents,
    MultiPageFormState state,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: _buildFloatingButtonRowWidget(
          context: context,
          previousButton: previousButton,
          nextButton: nextButton,
          previewButton: previewButton,
          isCurrentPageValid: isCurrentPageValid,
          otherComponents: otherComponents,
          allComponentValues: allComponentValues,
          state: state,
          page: page,
        ),
      ),
    );
  }

  Widget _buildFloatingButtonRowWidget({
    required BuildContext context,
    required DynamicFormModel? previousButton,
    required DynamicFormModel? nextButton,
    required DynamicFormModel? previewButton,
    required bool isCurrentPageValid,
    required List<DynamicFormModel> otherComponents,
    required Map<String, dynamic> allComponentValues,
    required MultiPageFormState state,
    required FormForMultiPageModel page,
  }) {
    final multiPageBloc = context.read<MultiPageFormBloc>();
    if (previousButton == null && nextButton == null && previewButton == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        if (previousButton != null)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: DynamicFormRenderer(
                component: previousButton,
                onButtonAction: (action, data) {
                  if (page.showPrevious) {
                    multiPageBloc.add(const NavigateToPage(isNext: false));
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
                      final missingFields = otherComponents
                          .where(
                            (comp) =>
                                _isComponentRequired(comp, allComponentValues),
                          )
                          .toList();
                      final missingLabels = missingFields
                          .map(
                            (comp) =>
                                comp.config[ValueKeyEnum.label.key]
                                    ?.toString() ??
                                comp.id,
                          )
                          .toList();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Required Fields'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Please fill the following required fields:',
                              ),
                              const SizedBox(height: 8),
                              ...missingLabels.map((label) => Text('- $label')),
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
                      return;
                    }
                    multiPageBloc.add(const NavigateToPage(isNext: true));
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
                          bool isValid = true;
                          // Form validation logic remains here
                          if (isValid) {
                            multiPageBloc.add(const SubmitMultiPageForm());
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
    );
  }

  bool _isComponentRequired(
    DynamicFormModel comp,
    Map<String, dynamic> allValues,
  ) {
    final isRequired = comp.config[ValueKeyEnum.isRequired.key] == true;
    final value = allValues[comp.id];
    return isRequired && (value == null || value.toString().trim().isEmpty);
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
      validation: componentModel.validation,
      children: const [],
    );
  }

  DynamicFormModel? _getRemoteButton(RemoteButtonConfigKey key) {
    final jsonString = RemoteConfigService().getString(key.key);
    if (jsonString.isNotEmpty) {
      return DynamicFormModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  void _handlePreviewFormAction(
    BuildContext context,
    MultiPageFormState state,
  ) async {
    // final allPages = state.formModel?.pages ?? [];
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
