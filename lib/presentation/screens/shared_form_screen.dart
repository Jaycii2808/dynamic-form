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
            title: Text(
              state is SharedFormLoading
                  ? 'Loading...'
                  : 'Shared Form: ${state.formName}',
            ),
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => context.go('/'),
              child: const Icon(Icons.home),
            ),
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
            'Loading shared form...',
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPageHeader(
            currentPage.title,
            state.currentPageIndex,
            pages.length,
          ),
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
                  ),
                );
              },
            ),
          ),
          if (pages.length > 1) _buildNavigationButtons(context, pages, state),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, int currentIndex, int totalPages) {
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
          if (totalPages > 1)
            Text(
              'Page ${currentIndex + 1} of $totalPages',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    List<FormForMultiPageModel> pages,
    SharedFormState state,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (state.currentPageIndex > 0)
            GestureDetector(
              onTap: () =>
                  context.read<SharedFormBloc>().add(const PreviousPageEvent()),
              child: _buildButton(
                'Previous',
                Colors.grey.withValues(alpha: 0.2),
                icon: Icons.arrow_back,
              ),
            )
          else
            const SizedBox(width: 100),
          GestureDetector(
            onTap: () => context.read<SharedFormBloc>().add(
              state.currentPageIndex < pages.length - 1
                  ? const NextPageEvent()
                  : const SubmitFormEvent(),
            ),
            child: _buildButton(
              state.currentPageIndex < pages.length - 1 ? 'Next' : 'Submit',
              state.currentPageIndex < pages.length - 1
                  ? Colors.blue
                  : Colors.green,
              icon: state.currentPageIndex < pages.length - 1
                  ? Icons.arrow_forward
                  : Icons.check,
            ),
          ),
        ],
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
    final values = state.componentValues.values;
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
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmailStatusSection(emailDetails, context),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: values.entries.map((entry) {
                      return _buildValueItem(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (emailDetails.emailSent != true &&
              emailDetails.emailResponse != null &&
              emailDetails.emailResponse!.type == 'network')
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.read<SharedFormBloc>().add(const SubmitFormEvent());
              },
              child: _buildButton('Retry Email', Colors.green),
            ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: _buildButton('Close', Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStatusSection(
    EmailDetailsModel emailDetails,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                emailDetails.emailSent
                    ? 'Email Sent Successfully'
                    : 'Email Status',
                style: TextStyle(
                  color: emailDetails.emailSent ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (emailDetails.recipientEmail != null) ...[
            Text(
              '📧 Recipient: ${emailDetails.recipientName ?? 'Unknown'} (${emailDetails.recipientEmail})',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
          ],
          if (emailDetails.emailSent) ...[
            const Text(
              '✅ Form data has been sent to the form owner.',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
            if (emailDetails.emailResponse != null) ...[
              const SizedBox(height: 4),
              Text(
                '📤 Status: ${emailDetails.emailResponse!.status}',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
              if (emailDetails.emailResponse!.messageId != null) ...[
                const SizedBox(height: 2),
                Text(
                  '🆔 Message ID: ${emailDetails.emailResponse!.messageId}',
                  style: const TextStyle(color: Colors.blue, fontSize: 10),
                ),
              ],
              if (emailDetails.emailResponse!.retryCount != null &&
                  emailDetails.emailResponse!.retryCount! > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '🔄 Retry attempts: ${emailDetails.emailResponse!.retryCount}',
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ],
            ],
          ] else if (emailDetails.emailError != null) ...[
            Text(
              '❌ ${emailDetails.emailError}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            if (emailDetails.emailResponse != null) ...[
              if (emailDetails.emailResponse!.statusCode != null) ...[
                const SizedBox(height: 2),
                Text(
                  '🔍 HTTP ${emailDetails.emailResponse!.statusCode}',
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ],
              if (emailDetails.emailResponse!.retryCount != null) ...[
                const SizedBox(height: 2),
                Text(
                  '🔄 Retry attempts: ${emailDetails.emailResponse!.retryCount}',
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ],
              if (emailDetails.emailResponse!.type != null) ...[
                const SizedBox(height: 2),
                Text(
                  '🔧 Error type: ${emailDetails.emailResponse!.type}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ],
            if (emailDetails.emailResponse != null &&
                emailDetails.emailResponse!.type == 'network') ...[
              const SizedBox(height: 8),
              _buildNetworkErrorSuggestions(),
            ],
          ] else ...[
            const Text(
              '⚠️ No recipient email configured for this form',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildNoEmailSuggestions(),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkErrorSuggestions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Suggestions:',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• Check your internet connection',
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
          Text(
            '• Try again in a few minutes',
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
          Text(
            '• Contact support if issue persists',
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEmailSuggestions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 How to fix:',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• Share the form again with recipient email',
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
          Text(
            '• Contact the form owner to add email',
            style: TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String key, dynamic value) {
    String displayValue = value == null
        ? 'Not filled'
        : value is String
        ? value.isEmpty
              ? 'Not filled'
              : value
        : value is List
        ? value.isEmpty
              ? 'Not filled'
              : value.join(', ')
        : value.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
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
            onTap: () => Navigator.of(context).pop(),
            child: _buildButton('Close', Colors.blue),
          ),
        ],
      ),
    );
  }

  DynamicFormModel _convertToDynamicFormModel(
    FormComponentMultiPageModel component,
  ) {
    return DynamicFormModel(
      id: component.id,
      type: component.type,
      order: component.order,
      config: component.config,
      style: component.style,
      validation: component.validation,
      children: component.children?.map(_convertToDynamicFormModel).toList(),
    );
  }
}
