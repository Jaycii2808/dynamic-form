import 'dart:convert';

import 'package:dynamic_form_bi/core/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_state.dart';
import 'package:dynamic_form_bi/presentation/screens/preview_page_screen.dart';
import 'package:dynamic_form_bi/presentation/screens/shared_form_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/item_widgets/email_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

class FormBuilderPreviewScreen extends StatefulWidget {
  static const String routeName = '/form-builder-preview';
  final FormBuilderModel formBuilderModel;
  final bool isEditing;
  final String? editingFormId;

  const FormBuilderPreviewScreen({
    super.key,
    required this.formBuilderModel,
    this.isEditing = false,
    this.editingFormId,
  });

  @override
  State<FormBuilderPreviewScreen> createState() =>
      _FormBuilderPreviewScreenState();
}

class _FormBuilderPreviewScreenState extends State<FormBuilderPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ComponentValuesModel componentValues = ComponentValuesModel.empty();
  bool _saveOrUpdateInProgress =
      false; // Track save/update flow to scope UI feedback

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocListener<UserFormsBloc, UserFormsState>(
        listener: (context, state) {
          if (!_saveOrUpdateInProgress) return;

          if (state is UserFormsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            if (mounted) {
              setState(() {
                _saveOrUpdateInProgress = false;
              });
            }
          } else if (state is UserFormsSuccess) {
            final bool isEditing = widget.isEditing;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? 'Form updated successfully!'
                      : 'Form saved successfully! You can find it in My Forms.',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            if (mounted) {
              setState(() {
                _saveOrUpdateInProgress = false;
              });
            }
          }
        },
        child: Stack(
          children: [
            _buildBody(),
            BlocBuilder<UserFormsBloc, UserFormsState>(
              buildWhen: (prev, curr) =>
                  _saveOrUpdateInProgress && prev.isLoading != curr.isLoading,
              builder: (context, state) {
                if (state.isLoading && _saveOrUpdateInProgress) {
                  return _buildFullScreenLoadingOverlay();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Preview: ${widget.formBuilderModel.name}'),
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Form Preview', icon: Icon(Icons.visibility)),
          Tab(text: 'JSON', icon: Icon(Icons.pages)),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFormPreviewTab(),
        _buildMultiPageJsonOutputTab(),
      ],
    );
  }

  Widget _buildFormPreviewTab() {
    // Convert FormBuilderModel pages to DynamicFormPageModel format
    final dynamicPages = widget.formBuilderModel.pages.map((page) {
      return DynamicFormPageModel(
        pageId: page.pageId,
        title: page.title,
        order: page.order,
        components: page.components,
      );
    }).toList();

    return Stack(
      children: [
        PreviewPageScreen(
          pages: dynamicPages,
          allComponentValues: componentValues,
        ),
        // Floating action buttons
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save Form button
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: FloatingActionButton.extended(
                  heroTag: 'save_form_button_${widget.formBuilderModel.formId}',
                  onPressed: () => _saveUserForm(),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Form'),
                ),
              ),
              // Share Form button
              FloatingActionButton.extended(
                heroTag: 'share_form_button_${widget.formBuilderModel.formId}',
                onPressed: () => _openActualDynamicForm(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Share Form'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Save user form to Firebase
  void _saveUserForm() async {
    // Guard: mark flow in-progress and dispatch event; UI feedback handled by BlocListener
    if (mounted) {
      setState(() {
        _saveOrUpdateInProgress = true;
      });
    }

    final userFormsBloc = context.read<UserFormsBloc>();
    final bool isEditing = widget.isEditing;
    final String resolvedId =
        (widget.editingFormId != null && widget.editingFormId!.isNotEmpty)
        ? widget.editingFormId!
        : widget.formBuilderModel.formId;

    if (isEditing) {
      userFormsBloc.add(
        UpdateUserFormEvent(
          formId: resolvedId,
          formBuilderModel: widget.formBuilderModel.copyWith(
            formId: resolvedId,
          ),
          userId: 'user001',
        ),
      );
    } else {
      userFormsBloc.add(
        SaveUserFormEvent(
          formBuilderModel: widget.formBuilderModel,
          userId: 'user001',
        ),
      );
    }
  }

  // Open actual dynamic form multiscreen with current data
  void _openActualDynamicForm() async {
    try {
      // Show email input dialog first
      final emailData = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const EmailInputDialog(),
      );

      if (emailData == null) {
        // User cancelled the dialog
        return;
      }
      // Use dedicated dialog context to safely close later
      BuildContext? loadingDialogContext;
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            loadingDialogContext = dialogContext;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }
      // Show loading dialog

      // Convert current form to JSON
      final jsonOutput = widget.formBuilderModel.toExportMultiPageJson();
      final formName = widget.formBuilderModel.name;

      // Logging removed; use Bloc Observer
      // Save to Firestore and get form ID
      final firestoreService = FirestoreFormService();
      final formId = await firestoreService.saveSharedForm(
        formData: jsonOutput,
        formName: formName,
        recipientEmail: emailData['email'],
        recipientName: emailData['name'],
      );

      // Generate shareable link
      final shareableLink = firestoreService.generateFormShareLink(formId);
      // Close only the loading dialog if still mounted
      if (loadingDialogContext != null && loadingDialogContext!.mounted) {
        loadingDialogContext!.pop();
        loadingDialogContext = null;
      }

      // Show success dialog with options
      _showShareSuccessDialog(shareableLink, formId, jsonOutput);
    } catch (e) {
      // Best-effort: try to close any loading dialog by traversing navigator
      // Prefer local dialog context pattern elsewhere to avoid this fallback
      if (mounted) {
        // Logging removed; use Bloc Observer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving form: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showShareSuccessDialog(
    String shareableLink,
    String formId,
    Map<String, dynamic> jsonOutput,
  ) {
    showDialog(
      context: context,
      builder: (context) => Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Form Shared Successfully!',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your form is now shareable:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shareableLink,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _copyLinkToClipboard(shareableLink),
                      child: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Form ID: $formId',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          actions: [
            Row(
              spacing: 15,
              //space betwween
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _copyLinkToClipboard(shareableLink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Copy Link',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openBrowserLink(shareableLink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Open in Browser',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Add button to navigate directly to shared form
            GestureDetector(
              onTap: () {
                context.pop(); // Close dialog
                _navigateToSharedForm(formId);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Open Form in App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLinkToClipboard(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openBrowserLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $link';
      }
    } catch (e) {
      // Logging removed; use Bloc Observer
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMultiPageJsonOutputTab() {
    final jsonOutput = widget.formBuilderModel.toExportMultiPageJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonOutput);

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pages, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'JSON Export',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Export to Firebase Remote Config button
              GestureDetector(
                onTap: () => _exportToFirebaseRemoteConfig(jsonString),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_upload, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text(
                        'Export',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonString),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text(
                        'Copy',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: const Text(
              'Auto-generated navigation with next_page/previous_page',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Export to Firebase Remote Config with parameter naming
  void _exportToFirebaseRemoteConfig(String jsonString) {
    final TextEditingController parameterNameController =
        TextEditingController();

    // Suggest a default parameter name
    final defaultName =
        'form_${widget.formBuilderModel.name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    parameterNameController.text = defaultName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Export to Firebase Remote Config',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter parameter name for Firebase Remote Config:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: parameterNameController,
              decoration: const InputDecoration(
                labelText: 'Parameter Name',
                hintText: 'e.g., my_form_config',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Note: You need to manually add this parameter to Firebase Console Remote Config with the copied JSON value.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          GestureDetector(
            onTap: () {
              final parameterName = parameterNameController.text.trim();
              if (parameterName.isNotEmpty) {
                context.pop();
                _performFirebaseExport(parameterName, jsonString);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a parameter name'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Export',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Perform the actual Firebase export process
  void _performFirebaseExport(String parameterName, String jsonString) {
    // Copy JSON to clipboard
    _copyToClipboard(jsonString);

    // Show instructions dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Flexible(
              child: Text('Firebase Export Instructions'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parameter Name: $parameterName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Steps to complete the export:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Go to Firebase Console → Remote Config'),
            const Text('2. Click "Add parameter"'),
            Text('3. Set Parameter key: $parameterName'),
            const Text('4. Paste the JSON (already copied to clipboard)'),
            const Text('5. Click "Publish changes"'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'JSON has been copied to clipboard!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Navigate to the shared form screen
  void _navigateToSharedForm(String formId) {
    context.replaceNamed(
      SharedFormScreen.routeName,
      pathParameters: {'formId': formId},
    );
  }

  // Helper: full-screen loading overlay
  Widget _buildFullScreenLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
