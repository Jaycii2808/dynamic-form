import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';

class SharedOptionsEditorList extends StatefulWidget {
  final List<Option> options;
  final String? focusOptionId;
  final VoidCallback? onFocusHandled;

  final bool navigationFeatureEnabled;

  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index, String label) onLabelChanged;
  final void Function(int index) onRemove;
  final void Function(int index)? onNavigateTap;
  final VoidCallback onAddOption;
  final String Function(Option option)? getNavigationLabel;

  const SharedOptionsEditorList({
    super.key,
    required this.options,
    required this.onReorder,
    required this.onLabelChanged,
    required this.onRemove,
    required this.onAddOption,
    this.onNavigateTap,
    this.navigationFeatureEnabled = false,
    this.focusOptionId,
    this.onFocusHandled,
    this.getNavigationLabel,
  });

  @override
  State<SharedOptionsEditorList> createState() =>
      _SharedOptionsEditorListState();
}

class _SharedOptionsEditorListState extends State<SharedOptionsEditorList> {
  final Map<String, FocusNode> _optionFocusNodes = {};
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  void didUpdateWidget(covariant SharedOptionsEditorList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOptionControllers(widget.options);

    // Handle external focus request
    if (widget.focusOptionId != null) {
      final String targetId = widget.focusOptionId!;
      final Option target = widget.options.firstWhere(
        (o) => o.value == targetId,
        orElse: () => const Option(value: '', label: ''),
      );
      if (target.value.isNotEmpty) {
        final FocusNode focusNode = _getFocusNodeForOption(target.value);
        final TextEditingController controller = _getControllerForOption(
          target.value,
          target.label,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          FocusScope.of(context).requestFocus(focusNode);
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
          widget.onFocusHandled?.call();
        });
      } else {
        widget.onFocusHandled?.call();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _optionControllers.values) {
      controller.dispose();
    }
    for (final node in _optionFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _getFocusNodeForOption(String optionId) {
    return _optionFocusNodes.putIfAbsent(optionId, () => FocusNode());
  }

  TextEditingController _getControllerForOption(String optionId, String label) {
    final controller = _optionControllers.putIfAbsent(
      optionId,
      () => TextEditingController(text: label),
    );
    if (controller.text != label) {
      controller.text = label;
    }
    return controller;
  }

  void _syncOptionControllers(List<Option> options) {
    final existingIds = options.map((o) => o.value).toSet();

    for (final option in options) {
      _getControllerForOption(option.value, option.label);
      _getFocusNodeForOption(option.value);
    }

    final removedIds = _optionControllers.keys
        .where((id) => !existingIds.contains(id))
        .toList();
    for (final id in removedIds) {
      _optionControllers.remove(id)?.dispose();
      _optionFocusNodes.remove(id)?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOptionsList(),
        _buildAddOptionButton(),
      ],
    );
  }

  Widget _buildOptionsList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.options.length,
      onReorder: (oldIndex, newIndex) {
        widget.onReorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final option = widget.options[index];
        return _buildOptionItem(option, index);
      },
    );
  }

  Widget _buildOptionItem(Option option, int index) {
    return Container(
      key: ValueKey(option.value),
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionRow(option, index),
          if (widget.navigationFeatureEnabled)
            _buildNavigationAction(option, index),
        ],
      ),
    );
  }

  Widget _buildOptionRow(Option option, int index) {
    return Row(
      children: [
        _buildDragHandle(),
        _buildOptionNumber(index),
        _buildOptionInput(option, index),
        _buildRemoveButton(index),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 6),
      child: const Icon(
        Icons.drag_handle,
        color: Color(0xFF9CA3AF),
        size: 16,
      ),
    );
  }

  Widget _buildOptionNumber(int index) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 6),
      child: Text(
        '${index + 1}.',
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOptionInput(Option option, int index) {
    return Expanded(
      child: TextField(
        controller: _getControllerForOption(option.value, option.label),
        focusNode: _getFocusNodeForOption(option.value),
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          hintText: 'Option',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => widget.onLabelChanged(index, value),
      ),
    );
  }

  Widget _buildRemoveButton(int index) {
    return GestureDetector(
      onTap: () => widget.onRemove(index),
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(left: 6),
        child: const Icon(
          Icons.close,
          color: Color(0xFF9CA3AF),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildNavigationAction(Option option, int index) {
    final String label =
        widget.getNavigationLabel?.call(option) ?? 'Navigate to page';
    return GestureDetector(
      onTap: () => widget.onNavigateTap?.call(index),
      child: Container(
        margin: const EdgeInsets.only(
          top: 4,
          left: 46,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF374151),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.navigation_outlined,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.edit,
              color: Colors.blue,
              size: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOptionButton() {
    return GestureDetector(
      onTap: widget.onAddOption,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.blue, size: 16),
            SizedBox(width: 6),
            Text(
              'Add option',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
