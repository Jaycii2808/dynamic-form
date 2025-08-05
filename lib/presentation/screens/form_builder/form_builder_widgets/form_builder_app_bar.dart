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

      // Page Navigation Row (only show if multi-page)
      if (isMultiPage) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildEditablePageTitle(context, state, formBuilderBloc),
            ),
            const SizedBox(width: 12),
            _buildPageNavigation(
              context,
              state,
              formBuilderBloc,
              currentPageIndex,
            ),
          ],
        ),
      ],
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

Widget _buildEditablePageTitle(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return GestureDetector(
    onTap: () => _showEditPageTitleDialog(context, state, formBuilderBloc),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description, color: Colors.green, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              state.currentPageTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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

Widget _buildPageNavigation(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
  int currentPageIndex,
) {
  final hasPrevious = currentPageIndex > 0;
  final hasNext = currentPageIndex < state.pages.length - 1;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Page Selector
      GestureDetector(
        onTap: () => _showPageSelectorDialog(context, state, formBuilderBloc),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.list, color: Colors.blue, size: 12),
              SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, color: Colors.blue, size: 14),
            ],
          ),
        ),
      ),

      const SizedBox(width: 4),

      // Previous Button
      if (hasPrevious)
        GestureDetector(
          onTap: () {
            final previousPage = state.pages[currentPageIndex - 1];
            formBuilderBloc.add(SwitchPageEvent(previousPage.pageId));
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
              size: 12,
            ),
          ),
        ),

      if (hasPrevious && hasNext) const SizedBox(width: 4),

      // Next Button
      if (hasNext)
        GestureDetector(
          onTap: () {
            final nextPage = state.pages[currentPageIndex + 1];
            formBuilderBloc.add(SwitchPageEvent(nextPage.pageId));
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
              size: 12,
            ),
          ),
        ),
    ],
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

void _showEditPageTitleDialog(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  final controller = TextEditingController(text: state.currentPageTitle);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Page Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Page Title',
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
                formBuilderBloc.add(
                  UpdatePageTitleEvent(
                    pageId: state.currentPageId,
                    title: newTitle,
                  ),
                );
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

void _showPageSelectorDialog(
  BuildContext context,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.view_list, color: Colors.blue),
            SizedBox(width: 8),
            Text('Select Page'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.pages.length,
            itemBuilder: (context, index) {
              final page = state.pages[index];
              final isCurrentPage = page.pageId == state.currentPageId;
              final componentCount = page.components.length;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentPage ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrentPage ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  page.title,
                  style: TextStyle(
                    fontWeight: isCurrentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCurrentPage ? Colors.blue : Colors.black,
                  ),
                ),
                subtitle: componentCount > 0
                    ? Text(
                        '$componentCount component${componentCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    : const Text(
                        'Empty page',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                trailing: isCurrentPage
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  formBuilderBloc.add(SwitchPageEvent(page.pageId));
                  Navigator.of(context).pop();
                },
              );
            },
          ),
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
