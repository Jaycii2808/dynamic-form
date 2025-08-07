import 'package:dynamic_form_bi/core/enums/hero_tag_form_builder_enum.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget formBuilderFloatingActionButtons(
  BuildContext context,
  FormBuilderBloc formBuilderBloc,
) {
  return BlocBuilder<FormBuilderBloc, FormBuilderState>(
    builder: (context, state) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 10), // Add left padding
            FloatingActionButton.extended(
              heroTag: HeroTagFormBuilderEnum.componentsPanel.value,
              onPressed: () {
                if (state.showButtonComponentsPanel) {
                  formBuilderBloc.add(const ToggleButtonComponentsPanelEvent());
                }
                formBuilderBloc.add(const ToggleComponentsPanelEvent());
              },
              backgroundColor: state.showComponentsPanel
                  ? Colors.blue.shade600
                  : Colors.blue.shade100,
              foregroundColor: state.showComponentsPanel
                  ? Colors.white
                  : Colors.blue,
              elevation: state.showComponentsPanel ? 8 : 4,
              icon: Container(
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
              label: Text(
                state.showComponentsPanel
                    ? 'Hide Components'
                    : 'Show Components',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
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
            FloatingActionButton.extended(
              heroTag: HeroTagFormBuilderEnum.addPage.value,
              onPressed: () => _showAddPageDialog(context, formBuilderBloc),
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Page',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      );
    },
  );
}

void _showAddPageDialog(BuildContext context, FormBuilderBloc formBuilderBloc) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_box,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Page',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Create a new page for your form',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Input field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  color: const Color(0xFF2A2A2A),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter page title...',
                    hintStyle: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.title,
                      color: Colors.blue.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
              ),

              const SizedBox(height: 8),

              // Hint text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.blue.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Examples: Personal Information, Contact Details, Payment Info',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final newTitle = controller.text.trim();
                        if (newTitle.isNotEmpty) {
                          formBuilderBloc.add(AddPageWithTitleEvent(newTitle));
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.blue.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Create Page',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
