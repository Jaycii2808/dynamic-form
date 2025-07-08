import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/step_progress_widget.dart';

class DynamicFormMultiScreen extends StatefulWidget {
  final String configKey;

  const DynamicFormMultiScreen({super.key, required this.configKey});

  @override
  State<DynamicFormMultiScreen> createState() => _DynamicFormMultiScreenState();
}

class _DynamicFormMultiScreenState extends State<DynamicFormMultiScreen> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MultiPageFormBloc(
            remoteConfigService: RemoteConfigService(),
          )..add(
            LoadMultiPageForm(widget.configKey),
          ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<MultiPageFormBloc, MultiPageFormState>(
        listener: (context, state) {
          if (state is MultiPageFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'An unknown error occurred.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is MultiPageFormSuccess) {
            // Jump to the correct page when currentPageIndex changes
            if (pageController.hasClients &&
                state.formModel != null &&
                state.currentPageIndex < state.formModel!.pages.length &&
                pageController.page?.round() != state.currentPageIndex) {
              pageController.animateToPage(
                state.currentPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        builder: (context, state) {
          if (state is MultiPageFormLoading ||
              state is MultiPageFormInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MultiPageFormSuccess) {
            if (state.formModel == null || state.formModel!.pages.isEmpty) {
              return const Center(child: Text('No pages to display.'));
            }
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StepProgressWidget(
                    title: state.currentPage?.title ?? '',
                    currentStep: state.currentPageIndex + 1, // 1-based
                    totalSteps: state.formModel!.pages.length,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable swipe
                      itemCount: state.formModel!.pages.length,
                      itemBuilder: (context, index) {
                        final page = state.formModel!.pages[index];
                        return DynamicFormPageWidget(
                          key: ValueKey(page.pageId),
                          page: page,
                          allComponentValues: state.componentValues,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is MultiPageFormError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load form: [${state.errorMessage}]',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const Center(child: Text('Initializing...'));
        },
      );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: BlocBuilder<MultiPageFormBloc, MultiPageFormState>(
          builder: (context, state) {
            if (state is MultiPageFormSuccess && state.currentPage != null) {
              return Center(child: Text(state.currentPage!.title));
            }
            return Center(child: Text(state.formModel?.name ?? 'Loading Form...'));
          },
        ),
      );
  }
}
