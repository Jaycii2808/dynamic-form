import 'package:dynamic_form_bi/core/enums/hero_tag_form_builder_enum.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget formBuilderFloatingActionButtons(BuildContext context, FormBuilderBloc formBuilderBloc) {
  return BlocBuilder<FormBuilderBloc, FormBuilderState>(
    builder: (context, state) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          FloatingActionButton(
            heroTag: HeroTagFormBuilderEnum.componentsPanel.value,
            onPressed: () {
              if (state.showButtonComponentsPanel) {
                formBuilderBloc.add(const ToggleButtonComponentsPanelEvent());
              }
              formBuilderBloc.add(const ToggleComponentsPanelEvent());
            },
            backgroundColor: state.showComponentsPanel ? Colors.blue.shade600 : Colors.blue.shade100,
            foregroundColor: state.showComponentsPanel ? Colors.white : Colors.blue,
            elevation: state.showComponentsPanel ? 8 : 4,
            child: Container(
              decoration: state.showComponentsPanel
                  ? BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(28),
              )
                  : null,
              child: Icon(
                state.showComponentsPanel ? Icons.hide_source : Icons.widgets,
                size: state.showComponentsPanel ? 24 : 20,
              ),
            ),
          ),
          // FloatingActionButton(
          //   heroTag: HeroTagFormBuilderEnum.buttonComponents.value,
          //   onPressed: () {
          //     if (state.showComponentsPanel) {
          //       formBuilderBloc.add(const ToggleComponentsPanelEvent());
          //     }
          //     formBuilderBloc.add(const LoadButtonComponentsEvent());
          //     formBuilderBloc.add(const ToggleButtonComponentsPanelEvent());
          //   },
          //   backgroundColor: state.showButtonComponentsPanel
          //       ? Colors.green.shade600
          //       : Colors.blue.shade100,
          //   foregroundColor: state.showButtonComponentsPanel ? Colors.white : Colors.blue,
          //   elevation: state.showButtonComponentsPanel ? 8 : 4,
          //   child: Container(
          //     decoration: state.showButtonComponentsPanel
          //         ? BoxDecoration(
          //       border: Border.all(color: Colors.white, width: 2),
          //       borderRadius: BorderRadius.circular(28),
          //     )
          //         : null,
          //     child: Icon(
          //       Icons.next_week_outlined,
          //       size: state.showButtonComponentsPanel ? 24 : 20,
          //     ),
          //   ),
          // ),
          FloatingActionButton(
            heroTag: HeroTagFormBuilderEnum.addPage.value,
            onPressed: () => _showAddPageDialog(context, formBuilderBloc),
            backgroundColor: Colors.green.shade100,
            foregroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          if (state.pages.length > 1)
            FloatingActionButton(
              heroTag: HeroTagFormBuilderEnum.removePage.value,
              onPressed: () => formBuilderBloc.add(RemovePageEvent(state.currentPageId)),
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              child: const Icon(Icons.remove),
            ),
          if (state.pages.length > 1)
            FloatingActionButton(
              heroTag: HeroTagFormBuilderEnum.pagesOverview.value,
              onPressed: () => _showPagesOverviewDialog(context, state, formBuilderBloc),
              backgroundColor: Colors.purple.shade100,
              foregroundColor: Colors.purple,
              child: const Icon(Icons.view_list),
            ),
        ],
      );
    },
  );
}

void _showAddPageDialog(BuildContext context, FormBuilderBloc formBuilderBloc) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a title for your new page:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Page Title',
                hintText: 'e.g., Personal Information, Contact Details',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (value) {
                final newTitle = value.trim();
                if (newTitle.isNotEmpty) {
                  formBuilderBloc.add(AddPageWithTitleEvent(newTitle));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                formBuilderBloc.add(AddPageWithTitleEvent(newTitle));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create Page'),
          ),
        ],
      );
    },
  );
}

void _showPagesOverviewDialog(
    BuildContext context, FormBuilderState state, FormBuilderBloc formBuilderBloc) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pages Overview'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.pages.length,
            itemBuilder: (context, index) {
              final page = state.pages[index];
              final isCurrentPage = page.pageId == state.currentPageId;
              return ListTile(
                leading: Icon(
                  isCurrentPage ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isCurrentPage ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  page.title,
                  style: TextStyle(
                    fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text('Page ${index + 1}'),
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