import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:dynamic_form_bi/presentation/widgets/item_widgets/form_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFormScreen extends StatefulWidget {
  final String configKey;
  final String? title;
  final Function(FormActionDataModel)? onAction;

  const DynamicFormScreen({
    super.key,
    required this.configKey,
    this.title,
    this.onAction,
  });

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  @override
  Widget build(BuildContext context) {
    return _DynamicFormContent(
      configKey: widget.configKey,
      title: widget.title,
      onAction: widget.onAction,
    );
  }
}

class _DynamicFormContent extends StatefulWidget {
  final String configKey;
  final String? title;
  final Function(FormActionDataModel)? onAction;

  const _DynamicFormContent({
    required this.configKey,
    this.title,
    this.onAction,
  });

  @override
  State<_DynamicFormContent> createState() => _DynamicFormContentState();
}

class _DynamicFormContentState extends State<_DynamicFormContent> {
  /// Filter out Save buttons from main form
  /// Save buttons should only appear in preview page
  ///
  List<DynamicFormModel> _getMainFormComponents(DynamicFormPageModel page) {
    final mainComponents = page.components.where((component) {
      final action = component.config?.action;
      return action != ButtonAction.submitForm.value;
    }).toList();
    return mainComponents;
  }

  /// Handle form actions with proper model
  void _handleFormAction(String action, FormActionDataModel? data) {
    debugPrint('🔘 [FormScreen] Action: $action, Data: $data');

    if (data != null) {
      // Handle different action types
      try {
        final buttonAction = ButtonAction.fromString(data.action);
        switch (buttonAction) {
          case ButtonAction.nextPage:
          case ButtonAction.previousPage:
            _handleNavigationAction(data);
            break;
          case ButtonAction.submitForm:
            _handleSubmitAction(data);
            break;
          case ButtonAction.custom:
            _handleCustomAction(data);
            break;
          default:
            _handleDefaultAction(data);
        }
      } catch (e) {
        // Handle unknown action types
        _handleDefaultAction(data);
      }
    }

    // Call the original onAction callback if provided
    widget.onAction?.call(data ?? FormActionDataModel.create(action: action));
  }

  void _handleNavigationAction(FormActionDataModel data) {
    debugPrint(
      '🔘 [FormScreen] Navigation action: ${data.action} to ${data.targetPage}',
    );
    // Handle navigation logic here
  }

  void _handleSubmitAction(FormActionDataModel data) {
    debugPrint('🔘 [FormScreen] Submit action: ${data.formId}');
    // Handle form submission logic here
  }

  void _handleCustomAction(FormActionDataModel data) {
    debugPrint('🔘 [FormScreen] Custom action: ${data.action}');
    // Handle custom action logic here
  }

  void _handleDefaultAction(FormActionDataModel data) {
    debugPrint('🔘 [FormScreen] Default action: ${data.action}');
    // Handle default action logic here
  }

  @override
  void initState() {
    super.initState();

    context.read<DynamicFormBloc>().add(
      LoadDynamicFormPageEvent(configKey: widget.configKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        if (state is DynamicFormError) {
          debugPrint('Error occurred: ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      builder: (context, state) {
        if (state is DynamicFormLoading || state is DynamicFormInitial) {
          return _buildLoadingPage();
        }
        if (state is DynamicFormSuccess) {
          return _buildPage(state.page!);
        } else if (state is DynamicFormError) {
          return _buildErrorPage(state.errorMessage!);
        } else {
          return _buildEmptyPage();
        }
      },
    );
  }

  Widget _buildPage(DynamicFormPageModel page) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              page.title.isNotEmpty
                  ? page.title
                  : (widget.title ?? 'Dynamic Form'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            foregroundColor: Colors.white,
            actions: const [
              // IconButton(
              //   icon: const Icon(Icons.refresh),
              //   onPressed: () async {
              //     context.read<DynamicFormBloc>().add(
              //       RefreshDynamicFormEvent(configKey: widget.configKey),
              //     );
              //   },
              // ),
              // IconButton(
              //   icon: const Icon(Icons.save),
              //   onPressed: () => _showSaveTemplateDialog(page),
              // ),
            ],
          ),
        ),
      ),
      body: FormWrapper(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              _getMainFormComponents(page).length +
                              1, // +1 for the SizedBox at the end
                          itemBuilder: (context, index) {
                            if (index == _getMainFormComponents(page).length) {
                              // Last item is the SizedBox
                              return const SizedBox(height: 32);
                            }
                            final component = _getMainFormComponents(
                              page,
                            )[index];
                            return DynamicFormRenderer(
                              component: component,
                              page: page,
                              onButtonAction: _handleFormAction,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade600,
                      ),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Form...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Config: ${widget.configKey}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fetching from Remote Config',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Dynamic Form'),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No UI Components Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add JSON configuration to Firebase Remote Config\nwith key "${widget.configKey}" to render UI components',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<DynamicFormBloc>().add(
                  LoadDynamicFormPageEvent(configKey: widget.configKey),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPage(String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Dynamic Form'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<DynamicFormBloc>().add(
                  LoadDynamicFormPageEvent(configKey: widget.configKey),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
