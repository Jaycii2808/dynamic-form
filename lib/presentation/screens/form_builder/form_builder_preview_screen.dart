import 'dart:convert';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/multi_screen/preview_multipage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormBuilderPreviewScreen extends StatefulWidget {
  final FormBuilderModel formBuilderModel;

  const FormBuilderPreviewScreen({
    super.key,
    required this.formBuilderModel,
  });

  @override
  State<FormBuilderPreviewScreen> createState() =>
      _FormBuilderPreviewScreenState();
}

class _FormBuilderPreviewScreenState extends State<FormBuilderPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ComponentValuesModel componentValues = ComponentValuesModel.empty();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: _buildBody(),
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
          Tab(text: 'JSON Output', icon: Icon(Icons.code)),
          Tab(text: 'Multi-Page JSON', icon: Icon(Icons.pages)),
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
        _buildJsonOutputTab(),
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

    return PreviewPageScreen(
      pages: dynamicPages,
      allComponentValues: componentValues,
    );
  }

  Widget _buildJsonOutputTab() {
    final jsonOutput = widget.formBuilderModel.toPreviewJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonOutput);

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'JSON Output',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonString),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
              const Text(
                'Multi-Page JSON Export',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyToClipboard(jsonString),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
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
}
