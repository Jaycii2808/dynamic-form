import 'package:dynamic_form_bi/core/services/email_service.dart';
import 'package:dynamic_form_bi/core/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/email/email_details_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/shared_form/shared_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/shared_form/shared_form_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/shared_form/shared_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SharedFormScreen extends StatelessWidget {
  static const String routePath = '/forms/:formId';
  static const String routeName = '/forms';
  final String formId;

  const SharedFormScreen({
    super.key,
    required this.formId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SharedFormBloc(
              firestoreService: FirestoreFormService(),
              emailService: EmailService(),
            )
            ..add(const InitializeEmailServiceEvent())
            ..add(LoadSharedFormEvent(formId)),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocConsumer<SharedFormBloc, SharedFormState>(
          listener: (context, state) {
            if (state is SharedFormSuccess && state.emailDetails != null) {
              _showSubmittedValuesDialog(context, state);
            } else if (state is SharedFormError) {
              _showErrorDialog(context, state.errorMessage);
            } else if (state is SharedFormValidationError) {
              _showValidationErrorDialog(context, state);
              // Return to previous state after showing dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<SharedFormBloc>().add(
                  const ReturnToPreviousStateEvent(),
                );
              });
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<SharedFormBloc, SharedFormState>(
        builder: (context, state) {
          return AppBar(
            title: state is SharedFormLoading
                ? const Text('Loading...')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.formName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Dyna Forms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SharedFormState state) {
    if (state is SharedFormLoading) {
      return _buildLoading();
    }

    if (state is SharedFormError) {
      return _buildError(context, state.errorMessage);
    }

    if (state.formData == null) {
      return _buildEmpty();
    }

    final pages = state.formData!.pages;
    return _buildInputMode(context, pages, state);
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String errorMessage) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<SharedFormBloc>().add(
                LoadSharedFormEvent(formId),
              ),
              child: _buildButton('Retry', Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No form data available',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildInputMode(
    BuildContext context,
    List<FormForMultiPageModel> pages,
    SharedFormState state,
  ) {
    if (pages.isEmpty) {
      return const Center(
        child: Text(
          'No form pages found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final currentPage = pages[state.currentPageIndex];
    final isSubmitPage = state.currentPageIndex == pages.length - 1;

    // Debug widget to show form structure
    debugPrint('🔍 [SharedFormScreen] Current page: ${currentPage.title}');
    debugPrint('🔍 [SharedFormScreen] Page ID: ${currentPage.pageId}');
    debugPrint('🔍 [SharedFormScreen] Is submit page: $isSubmitPage');
    debugPrint(
      '🔍 [SharedFormScreen] Components count: ${currentPage.components.length}',
    );

    for (int i = 0; i < currentPage.components.length; i++) {
      final component = currentPage.components[i];
      debugPrint(
        '🔍 [SharedFormScreen] Component $i: ${component.id} - ${component.type}',
      );
      debugPrint(
        '🔍 [SharedFormScreen] Component $i config: ${component.config.toJson()}',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPageHeader(
            currentPage.title,
            state.currentPageIndex,
            pages.length,
          ),

          // Show submit page content or form components
          if (isSubmitPage)
            _buildSubmitPage(context, state)
          else
            Expanded(
              child: ListView.builder(
                itemCount: currentPage.components.length,
                itemBuilder: (context, index) {
                  final component = currentPage.components[index];
                  final value = state.componentValues.values[component.id];
                  final updatedConfig = component.config.copyWith(value: value);
                  final updatedComponent = component.copyWith(
                    config: updatedConfig,
                  );
                  final dynamicComponent = _convertToDynamicFormModel(
                    updatedComponent,
                  );

                  debugPrint(
                    '🔍 [SharedFormScreen] Component ${index + 1}: ${component.id}',
                  );
                  debugPrint(
                    '🔍 [SharedFormScreen] Component type: ${component.type}',
                  );
                  debugPrint(
                    '🔍 [SharedFormScreen] Component config: ${component.config.toJson()}',
                  );
                  debugPrint(
                    '🔍 [SharedFormScreen] Dynamic component config: ${dynamicComponent.config?.toJson()}',
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: DynamicFormRenderer(
                      component: dynamicComponent,
                      onFieldChanged: (id, value) => context
                          .read<SharedFormBloc>()
                          .add(FieldChangedEvent(id, value)),
                      onButtonAction: (action, data) => context
                          .read<SharedFormBloc>()
                          .add(ButtonActionEvent(action, data)),
                      isSharedForm: true,
                      currentPageId:
                          currentPage.pageId, // Pass the current page ID
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, int currentIndex, int totalPages) {
    final isSubmitPage = title == 'Submit Form';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (totalPages > 1 && !isSubmitPage)
            Text(
              'Page ${currentIndex + 1} of ${totalPages - 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          if (isSubmitPage)
            const Text(
              'Final Step',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitPage(BuildContext context, SharedFormState state) {
    return Expanded(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Do you want to submit?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'The form will be sent to admin',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.read<SharedFormBloc>().add(
                      const PreviousPageEvent(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Submit button
                  GestureDetector(
                    onTap: () => context.read<SharedFormBloc>().add(
                      const SubmitFormEvent(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ],
      ),
    );
  }

  void _showSubmittedValuesDialog(BuildContext context, SharedFormState state) {
    final emailDetails = state.emailDetails!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Form Submitted Successfully!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSimplifiedEmailStatus(emailDetails, context),
            ],
          ),
        ),
        actions: [
          if (emailDetails.emailSent != true &&
              emailDetails.emailResponse != null &&
              emailDetails.emailResponse!.type == 'network')
            GestureDetector(
              onTap: () {
                context.pop();
                context.read<SharedFormBloc>().add(const SubmitFormEvent());
              },
              child: _buildButton('Retry Email', Colors.green),
            ),
          GestureDetector(
            onTap: () => context.pop(),
            child: _buildButton('Close', Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedEmailStatus(
    EmailDetailsModel emailDetails,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emailDetails.emailSent
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: emailDetails.emailSent
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                emailDetails.emailSent ? Icons.check_circle : Icons.error,
                color: emailDetails.emailSent ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emailDetails.emailSent
                      ? 'Email Sent Successfully'
                      : 'Email Failed to Send',
                  style: TextStyle(
                    color: emailDetails.emailSent ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (emailDetails.recipientEmail != null) ...[
            Text(
              '📧 ${emailDetails.recipientName ?? 'Unknown'} (${emailDetails.recipientEmail})',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],
          if (emailDetails.emailSent) ...[
            const Text(
              '✅ Form data has been sent to the form owner.',
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ] else if (emailDetails.emailError != null) ...[
            Text(
              '❌ ${emailDetails.emailError}',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            if (emailDetails.emailResponse?.type == 'network') ...[
              const SizedBox(height: 8),
              const Text(
                '💡 Check your internet connection and try again.',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ] else ...[
            const Text(
              '⚠️ No recipient email configured for this form',
              style: TextStyle(color: Colors.orange, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.pop(),
            child: _buildButton('Close', Colors.blue),
          ),
        ],
      ),
    );
  }

  void _showValidationErrorDialog(
    BuildContext context,
    SharedFormValidationError state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Required Fields Missing',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please fill in the following required fields:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...state.missingFields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        field,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => context.pop(),
            child: _buildButton('OK', Colors.blue),
          ),
        ],
      ),
    );
  }

  DynamicFormModel _convertToDynamicFormModel(
    FormComponentMultiPageModel component,
  ) {
    debugPrint('🔄 [SharedFormScreen] Converting component: ${component.id}');
    debugPrint('🔄 [SharedFormScreen] Component type: ${component.type}');
    debugPrint(
      '🔄 [SharedFormScreen] Component config: ${component.config.toJson()}',
    );

    final dynamicComponent = DynamicFormModel(
      id: component.id,
      type: component.type,
      labelFormBuilder: component.config.label, // Add labelFormBuilder
      order: component.order,
      config: component.config,
      style: component.style,
      validation: component.validation,
      children: component.children?.map(_convertToDynamicFormModel).toList(),
    );

    debugPrint(
      '🔄 [SharedFormScreen] Converted to DynamicFormModel: ${dynamicComponent.id}',
    );
    debugPrint(
      '🔄 [SharedFormScreen] Dynamic component config: ${dynamicComponent.config?.toJson()}',
    );

    return dynamicComponent;
  }
}
