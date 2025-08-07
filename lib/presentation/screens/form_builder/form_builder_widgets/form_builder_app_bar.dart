import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

PreferredSizeWidget formBuilderAppBar(
  BuildContext context,
  FormBuilderBloc formBuilderBloc,
) {
  return AppBar(
    title: BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) => _buildTitle(context, state, formBuilderBloc),
    ),
    backgroundColor: const Color(0xFF000000),
    foregroundColor: Colors.white,
    elevation: 1,
    toolbarHeight: 80,
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    ),

    actions: [
      BlocBuilder<FormBuilderBloc, FormBuilderState>(
        builder: (context, state) =>
            _buildActionButtons(context, state, formBuilderBloc),
      ),
    ],
  );
}

Widget _buildTitle(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  final isMultiPage = state.pages.length > 1;
  final currentPageIndex = state.pages.indexWhere(
    (page) => page.pageId == state.currentPageId,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Form Title Row
      Row(
        children: [
          Expanded(
            child: _buildEditableFormTitle(context, state, formBuilderBloc),
          ),
          if (isMultiPage) ...[
            const SizedBox(width: 12),
            _buildPageIndicator(currentPageIndex, state.pages.length),
          ],
        ],
      ),
    ],
  );
}

Widget _buildEditableFormTitle(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return GestureDetector(
    onTap: () => _showEditFormTitleDialog(context, state, formBuilderBloc),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit, color: Colors.blue, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              state.formTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPageIndicator(int currentPageIndex, int totalPages) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '${currentPageIndex + 1}/$totalPages',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[400],
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _buildActionButtons(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  // Check if current page has components
  final currentPage = state.pages.firstWhere(
    (page) => page.pageId == state.currentPageId,
  );
  final hasComponents = currentPage.components.isNotEmpty;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (hasComponents)
        Container(
          margin: const EdgeInsets.only(right: 6, top: 8, bottom: 8),
          child: IconButton(
            onPressed: () => formBuilderBloc.add(const ClearCanvasEvent()),
            icon: const Icon(Icons.cleaning_services, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
            tooltip: 'Clear Current Page',
          ),
        ),
      Container(
        margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        child: IconButton(
          onPressed: () => _handleSubmitForm(context, state, formBuilderBloc),
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.preview, size: 16),
              SizedBox(width: 4),
              Icon(Icons.share, size: 16),
            ],
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.green.shade100,
            foregroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(40, 36),
          ),
          tooltip: 'Preview & Share',
        ),
      ),
    ],
  );
}

void _showEditFormTitleDialog(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  final controller = TextEditingController(text: state.formTitle);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Form Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Form Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                formBuilderBloc.add(UpdateFormTitleEvent(newTitle));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _handleSubmitForm(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  if (state.pages.isEmpty ||
      state.pages.every((page) => page.components.isEmpty)) {
    DialogUtils.showErrorDialog(
      context,
      'Please add at least one component to the form',
    );
    return;
  }
  final formBuilderModel = FormBuilderModel(
    formId: 'form_${DateTime.now().millisecondsSinceEpoch}',
    name: state.formTitle,
    pages: state.pages,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          FormBuilderPreviewScreen(formBuilderModel: formBuilderModel),
    ),
  );
}
