import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/hero_tag_form_builder_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder_preview_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  late FormBuilderBloc formBuilderBloc;

  @override
  void initState() {
    super.initState();
    formBuilderBloc = context.read<FormBuilderBloc>();
    formBuilderBloc.add(const LoadComponentsEvent());

    // Show dialog to name the first page after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFirstPageNameDialog();
    });
  }

  void _showFirstPageNameDialog() {
    final formController = TextEditingController(text: 'Untitled form');
    final pageController = TextEditingController(text: 'Page 1');

    showDialog(
      context: context,
      barrierDismissible: false, // User must enter a name
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Your Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Let\'s start by naming your form and first page:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: formController,
                decoration: const InputDecoration(
                  labelText: 'Form Name',
                  hintText: 'e.g., Customer Feedback, Event Registration',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pageController,
                decoration: const InputDecoration(
                  labelText: 'First Page Title',
                  hintText: 'e.g., Personal Information, Contact Details',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final formName = formController.text.trim();
                final pageName = pageController.text.trim();

                if (formName.isNotEmpty && pageName.isNotEmpty) {
                  formBuilderBloc.add(UpdateFormTitleEvent(formName));
                  formBuilderBloc.add(UpdateFirstPageTitleEvent(pageName));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create Form'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFF000000),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<FormBuilderBloc, FormBuilderState>(
      listener: (context, state) {
        if (state is FormBuilderError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state is FormBuilderLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        //error and success
        if (state is FormBuilderSuccess) {
          return Column(
            children: [
              // Progress bar for multiple pages
              if (state.pages.length > 1) _buildProgressBar(state),
              Expanded(child: _buildMainContent(state)),
            ],
          );
        }
        return const Text('Error');
      },
    );
  }

  Widget _buildProgressBar(FormBuilderState state) {
    final currentPageIndex = state.pages.indexWhere(
      (page) => page.pageId == state.currentPageId,
    );
    final progress = (currentPageIndex + 1) / state.pages.length;

    return Container(
      width: double.infinity,
      height: 4,
      color: Colors.grey[800],
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            FloatingActionButton(
              heroTag: HeroTagFormBuilderEnum.componentsPanel.value,
              onPressed: () {
                // Close button panel if open, then toggle components panel
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
              child: Container(
                decoration: state.showComponentsPanel
                    ? BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      )
                    : null,
                child: Icon(
                  state.showComponentsPanel ? Icons.hide_source : Icons.widgets,
                  size: state.showComponentsPanel ? 24 : 20,
                ),
              ),
            ),
            //implement show list button
            FloatingActionButton(
              heroTag: HeroTagFormBuilderEnum.buttonComponents.value,
              onPressed: () {
                // Close components panel if open, then toggle button components panel
                if (state.showComponentsPanel) {
                  formBuilderBloc.add(const ToggleComponentsPanelEvent());
                }
                formBuilderBloc.add(const LoadButtonComponentsEvent());
                formBuilderBloc.add(const ToggleButtonComponentsPanelEvent());
              },
              backgroundColor: state.showButtonComponentsPanel
                  ? Colors.green.shade600
                  : Colors.blue.shade100,
              foregroundColor: state.showButtonComponentsPanel
                  ? Colors.white
                  : Colors.blue,
              elevation: state.showButtonComponentsPanel ? 8 : 4,
              child: Container(
                decoration: state.showButtonComponentsPanel
                    ? BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      )
                    : null,
                child: Icon(
                  Icons.next_week_outlined,
                  size: state.showButtonComponentsPanel ? 24 : 20,
                ),
              ),
            ),
            // Add page button
            FloatingActionButton(
              heroTag: HeroTagFormBuilderEnum.addPage.value,
              onPressed: () {
                _showAddPageDialog();
              },
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green,
              child: const Icon(
                Icons.add,
              ),
            ),
            // Remove page button (only show if more than 1 page)
            if (state.pages.length > 1)
              FloatingActionButton(
                heroTag: HeroTagFormBuilderEnum.removePage.value,
                onPressed: () {
                  formBuilderBloc.add(RemovePageEvent(state.currentPageId));
                },
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
                child: const Icon(
                  Icons.remove,
                ),
              ),
            // Pages overview button (only show if more than 1 page)
            if (state.pages.length > 1)
              FloatingActionButton(
                heroTag: HeroTagFormBuilderEnum.pagesOverview.value,
                onPressed: () {
                  _showPagesOverviewDialog(state);
                },
                backgroundColor: Colors.purple.shade100,
                foregroundColor: Colors.purple,
                child: const Icon(
                  Icons.view_list,
                ),
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: BlocBuilder<FormBuilderBloc, FormBuilderState>(
        builder: (context, state) {
          return _buildEditableTitle(state);
        },
      ),
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 80, // Increase height for column layout
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(32, 32),
          ),
        ),
      ),
      actions: [
        BlocBuilder<FormBuilderBloc, FormBuilderState>(
          builder: (context, state) {
            return Row(
              spacing: 6,
              children: [
                if (state.canvasComponents.isNotEmpty)
                  _buildCompactClearButton(),
                _buildCompactPreviewButton(state),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactClearButton() {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 8, bottom: 8),
      child: IconButton(
        onPressed: () => formBuilderBloc.add(const ClearCanvasEvent()),
        icon: const Icon(Icons.clear, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(32, 32),
        ),
        tooltip: 'Clear Canvas',
      ),
    );
  }

  Widget _buildCompactPreviewButton(FormBuilderState state) {
    return Container(
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      child: IconButton(
        onPressed: () => _handleSubmitForm(state),
        icon: const Icon(Icons.preview, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(32, 32),
        ),
        tooltip: 'Preview Form',
      ),
    );
  }

  Widget _buildEditableTitle(FormBuilderState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Form title row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditFormTitleDialog(state),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
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
              ),
            ),
            const SizedBox(width: 12),
            // Page navigation
            if (state.pages.length > 1) _buildPageNavigation(state),
          ],
        ),
        const SizedBox(height: 8),
        // Page title row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditPageTitleDialog(state),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description,
                        color: Colors.green,
                        size: 14,
                      ),
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
              ),
            ),
            const SizedBox(width: 12),
            // Page info badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Page ${state.pages.indexWhere((page) => page.pageId == state.currentPageId) + 1} of ${state.pages.length}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditFormTitleDialog(FormBuilderState state) {
    final TextEditingController controller = TextEditingController(
      text: state.formTitle,
    );

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

  void _showEditPageTitleDialog(FormBuilderState state) {
    final TextEditingController controller = TextEditingController(
      text: state.currentPageTitle,
    );

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

  void _showAddPageDialog() {
    final TextEditingController controller = TextEditingController();

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

  Widget _buildPageNavigation(FormBuilderState state) {
    final currentPageIndex = state.pages.indexWhere(
      (page) => page.pageId == state.currentPageId,
    );
    final hasPrevious = currentPageIndex > 0;
    final hasNext = currentPageIndex < state.pages.length - 1;

    return Row(
      spacing: 8,
      children: [
        // Page info and selector
        GestureDetector(
          onTap: () => _showPageSelectorDialog(state),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.description,
                  color: Colors.blue,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${currentPageIndex + 1} of ${state.pages.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Previous page button
        if (hasPrevious)
          GestureDetector(
            onTap: () {
              final previousPage = state.pages[currentPageIndex - 1];
              formBuilderBloc.add(SwitchPageEvent(previousPage.pageId));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.blue,
                size: 16,
              ),
            ),
          ),
        // Next page button
        if (hasNext)
          GestureDetector(
            onTap: () {
              final nextPage = state.pages[currentPageIndex + 1];
              formBuilderBloc.add(SwitchPageEvent(nextPage.pageId));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  void _showPageSelectorDialog(FormBuilderState state) {
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
                          color: isCurrentPage
                              ? Colors.white
                              : Colors.grey[600],
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Page ${index + 1}'),
                      if (componentCount > 0)
                        Text(
                          '$componentCount component${componentCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
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

  void _handleSubmitForm(FormBuilderState state) {
    if (state.pages.isEmpty ||
        state.pages.every((page) => page.components.isEmpty)) {
      DialogUtils.showErrorDialog(
        context,
        'Please add at least one component to the form',
      );
      return;
    }

    // Create FormBuilderModel from current state with all pages
    final formBuilderModel = FormBuilderModel(
      formId: 'form_${DateTime.now().millisecondsSinceEpoch}',
      name: state.formTitle,
      pages: state.pages,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Navigate to preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormBuilderPreviewScreen(
          formBuilderModel: formBuilderModel,
        ),
      ),
    );
  }

  Widget _buildMainContent(FormBuilderState state) {
    return Stack(
      children: [
        // Main form canvas - takes full width
        _buildFormCanvas(state),
        // Floating components panel
        if (state.showComponentsPanel) _buildFloatingComponentsPanel(state),
        // Floating button components panel
        if (state.showButtonComponentsPanel)
          _buildFloatingButtonComponentsPanel(state),
      ],
    );
  }

  Widget _buildFloatingComponentsPanel(FormBuilderState state) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 0,
      top: 0,
      bottom: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildComponentsPanelHeader(),
            Expanded(
              child: state.availableComponents.isEmpty
                  ? _buildEmptyComponentsList()
                  : _buildComponentsList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtonComponentsPanel(FormBuilderState state) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: state.showComponentsPanel ? 300 : 0,
      top: 0,
      bottom: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: Colors.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildButtonComponentsPanelHeader(),
            Expanded(
              child: state.availableButtonComponents.isEmpty
                  ? _buildEmptyButtonComponentsList()
                  : _buildButtonComponentsList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCanvas(FormBuilderState state) {
    return Container(
      color: const Color(0xFF000000),
      child: Column(
        children: [
          // Page info header
          if (state.pages.length > 1) _buildPageInfoHeader(state),
          Expanded(
            child: state.canvasComponents.isEmpty
                ? _buildEmptyCanvas()
                : _buildCanvasWithComponents(state),
          ),
        ],
      ),
    );
  }

  Widget _buildPageInfoHeader(FormBuilderState state) {
    final currentPageIndex = state.pages.indexWhere(
      (page) => page.pageId == state.currentPageId,
    );
    final currentPage = state.pages[currentPageIndex];
    final componentCount = currentPage.components.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Page ${currentPageIndex + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentPage.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$componentCount component${componentCount != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCanvas() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildEmptyCanvasText(),
          const SizedBox(height: 32),
          ..._buildEmptyDropZones(),
        ],
      ),
    );
  }

  Widget _buildEmptyCanvasText() {
    return Text(
      'Drag components from the right panel\nto build your form',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
        height: 1.5,
      ),
    );
  }

  List<Widget> _buildEmptyDropZones() {
    return List.generate(5, (index) => _buildDropZone(index));
  }

  Widget _buildDropZone(int index) {
    return DragTarget<DynamicFormModel>(
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDragOver ? Colors.blue : Colors.grey[400]!,
              width: isDragOver ? 3 : 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isDragOver
                ? Colors.blue.withValues(alpha: 0.1)
                : const Color(0xFF000000),
          ),
          child: _buildDropZoneContent(isDragOver),
        );
      },
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) =>
          formBuilderBloc.add(AddComponentEvent(details.data)),
    );
  }

  Widget _buildDropZoneContent(bool isDragOver) {
    return GestureDetector(
      onTap: () {
        formBuilderBloc.add(
          const ToggleComponentsPanelEvent(),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDragOver ? Icons.check_circle : Icons.add_circle_outline,
              size: 32,
              color: isDragOver ? Colors.blue : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              isDragOver ? 'Drop here!' : 'Drop component here',
              style: TextStyle(
                fontSize: 14,
                color: isDragOver ? Colors.blue : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasWithComponents(FormBuilderState state) {
    return ListView.builder(
      itemCount: state.canvasComponents.length + 1, // +1 for drop zone at end
      itemBuilder: (context, index) {
        if (index == state.canvasComponents.length) {
          return _buildDropZone(index);
        }
        return _buildCanvasItem(state.canvasComponents[index], index);
      },
    );
  }

  Widget _buildCanvasItem(DynamicFormModel component, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              child: _buildComponentWidget(component),
            ),
          ),
          _buildComponentActions(index),
        ],
      ),
    );
  }

  Widget _buildComponentWidget(DynamicFormModel component) {
    return ReusedWidget.buildFormComponent(
      component: component,
      onComponentValueChange: (componentId, value) => formBuilderBloc.add(
        UpdateComponentValueEvent(
          componentId: componentId,
          value: value,
        ),
      ),
    );
  }

  Widget _buildComponentActions(int index) {
    return PopupMenuButton<ComponentActionEnum>(
      onSelected: (value) => formBuilderBloc.add(
        HandleComponentActionEvent(
          action: value,
          index: index,
        ),
      ),
      itemBuilder: (context) => _buildActionMenuItems(),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: const Icon(Icons.more_vert, color: Colors.grey),
      ),
    );
  }

  List<PopupMenuEntry<ComponentActionEnum>> _buildActionMenuItems() {
    return [
      _buildActionMenuItem(
        ComponentActionEnum.moveUp,
        Icons.arrow_upward,
        'Move Up',
        Colors.blue,
      ),
      _buildActionMenuItem(
        ComponentActionEnum.moveDown,
        Icons.arrow_downward,
        'Move Down',
        Colors.blue,
      ),
      _buildActionMenuItem(
        ComponentActionEnum.delete,
        Icons.delete,
        'Delete',
        Colors.red,
      ),
    ];
  }

  PopupMenuItem<ComponentActionEnum> _buildActionMenuItem(
    ComponentActionEnum action,
    IconData icon,
    String text,
    Color color,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildComponentsPanelHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
          left: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.widgets, color: Colors.blue, size: 16),
            const SizedBox(width: 4),
            const Flexible(
              child: Text(
                'Form Components',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => formBuilderBloc.add(
                const ToggleComponentsPanelEvent(),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonComponentsPanelHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
          left: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.widgets, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            const Flexible(
              child: Text(
                'Button Components',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => formBuilderBloc.add(
                const ToggleButtonComponentsPanelEvent(),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyComponentsList() {
    return const Center(
      child: Text(
        'No components available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyButtonComponentsList() {
    return const Center(
      child: Text(
        'No button components available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildComponentsList(FormBuilderState state) {
    return ListView.builder(
      itemCount: state.availableComponents.length,
      itemBuilder: (context, index) {
        return _buildDraggableComponent(state.availableComponents[index]);
      },
    );
  }

  Widget _buildButtonComponentsList(FormBuilderState state) {
    return ListView.builder(
      itemCount: state.availableButtonComponents.length,
      itemBuilder: (context, index) {
        return _buildDraggableButtonComponent(
          state.availableButtonComponents[index],
        );
      },
    );
  }

  Widget _buildDraggableComponent(DynamicFormModel component) {
    return LongPressDraggable<DynamicFormModel>(
      data: component,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => formBuilderBloc.add(StartDragEvent(component)),
      onDragEnd: (details) => formBuilderBloc.add(EndDragEvent(component)),
      feedback: _buildDragFeedback(component),
      childWhenDragging: _buildComponentListItemDragging(component),
      child: _buildComponentListItem(component),
    );
  }

  Widget _buildDraggableButtonComponent(DynamicFormModel component) {
    return LongPressDraggable<DynamicFormModel>(
      data: component,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => formBuilderBloc.add(StartDragEvent(component)),
      onDragEnd: (details) => formBuilderBloc.add(EndDragEvent(component)),
      feedback: _buildDragFeedback(component),
      childWhenDragging: _buildComponentListItemDragging(component),
      child: _buildComponentListItem(component),
    );
  }

  Widget _buildComponentListItem(DynamicFormModel component) {
    return GestureDetector(
      onTap: () => formBuilderBloc.add(AddComponentEvent(component)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF000000).withValues(alpha: 0.8),
        ),
        child: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Component header with icon and title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildComponentIcon(),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      component.labelFormBuilder ?? "Component",
                      style: const TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  _buildDragHandle(),
                ],
              ),
              const SizedBox(height: 8),
              // Component preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: _buildComponentPreview(component),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentListItemDragging(DynamicFormModel component) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF000000),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Component header with icon and title
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildComponentIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.labelFormBuilder ?? "Component",
                    style: const TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                _buildDragHandle(),
              ],
            ),
            const SizedBox(height: 8),
            // Component preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: _buildComponentPreview(component),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentIcon() {
    return const Icon(
      Icons.widgets,
      color: Colors.blue,
      size: 10,
    );
  }

  Widget _buildDragHandle() {
    return Icon(
      Icons.drag_handle,
      color: Colors.grey[400],
      size: 16,
    );
  }

  Widget _buildDragFeedback(DynamicFormModel component) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Component header
              Row(
                children: [
                  const Icon(Icons.widgets, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      component.labelFormBuilder ?? "Component",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Component preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: _buildComponentPreview(component),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentPreview(DynamicFormModel component) {
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return _buildTextFieldPreview(component);
      case FormTypeEnum.textAreaFormType:
        return _buildTextAreaPreview(component);
      case FormTypeEnum.switchFormType:
        return _buildSwitchPreview(component);
      case FormTypeEnum.selectorButtonFormType:
        return _buildSelectorButtonPreview(component);
      case FormTypeEnum.dateTimePickerFormType:
        return _buildDateTimePickerPreview(component);
      case FormTypeEnum.dateTimeRangePickerFormType:
        return _buildDateTimeRangePickerPreview(component);
      case FormTypeEnum.buttonFormType:
        return _buildButtonPreview(component);
      default:
        return _buildDefaultPreview(component);
    }
  }

  Widget _buildTextFieldPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Row(
              children: [
                if (component.config?.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.mail,
                    color: Colors.grey[400],
                    size: 10,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    component.config?.placeholder ?? 'Text Field',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaPreview(DynamicFormModel component) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                component.config?.placeholder ?? 'Text Area',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPreview(DynamicFormModel component) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: const Center(
        child: Text(
          'Component',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.toggle_on,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.config!.label!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButtonPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                if (component.config?.label != null) ...[
                  Expanded(
                    child: Text(
                      component.config!.label!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickerPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.config?.placeholder ?? 'Select Date',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRangePickerPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                const Icon(
                  Icons.date_range,
                  color: Colors.blue,
                  size: 12,
                ),
                Expanded(
                  child: Text(
                    component.config?.placeholder ?? 'Select Date Range',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.send,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                if (component.config?.label != null) ...[
                  Expanded(
                    child: Text(
                      component.config!.label!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPagesOverviewDialog(FormBuilderState state) {
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
                    isCurrentPage
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isCurrentPage ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    page.title,
                    style: TextStyle(
                      fontWeight: isCurrentPage
                          ? FontWeight.bold
                          : FontWeight.normal,
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
}
