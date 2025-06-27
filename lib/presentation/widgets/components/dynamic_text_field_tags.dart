import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DynamicTextFieldTags extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextFieldTags({super.key, required this.component});

  @override
  State<DynamicTextFieldTags> createState() => _DynamicTextFieldTagsState();
}

class _DynamicTextFieldTagsState extends State<DynamicTextFieldTags> {
  bool _showSuggestions = false;
  String? _errorText;
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    final initialTags =
        (widget.component.config['initialTags'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    _selectedTags.addAll(initialTags);
  }

  Map<String, dynamic> _resolveStyles(String currentState) {
    final style = Map<String, dynamic>.from(widget.component.style);
    if (widget.component.states != null &&
        widget.component.states!.containsKey(currentState)) {
      final stateStyle =
          widget.component.states![currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }
    return style;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _determineState() {
    if (_selectedTags.isNotEmpty) return 'success';
    if (_errorText != null) return 'error';
    return 'base';
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _errorText = null;
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: widget.component.id,
            value: _selectedTags.toList(),
          ),
        );
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: widget.component.id,
          value: _selectedTags.toList(),
        ),
      );
      // widget.onComplete(_selectedTags.toList());
    });
  }

  Widget _buildTagChip(
    String tag,
    Map<String, dynamic> style, {
    bool allowRemoval = false,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: style['tagTextSize']?.toDouble() ?? 14,
                color: StyleUtils.parseColor(
                  style['tagTextColor'] ?? '#6979F8',
                ),
              ),
            ),
          ),
          if (allowRemoval && !isDisabled) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () => _removeTag(tag),
              child: SvgPicture.asset(
                'assets/svg/Close.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.redAccent,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsInputView(
    Map<String, dynamic> style,
    List<String> initialTags,
    String placeholder,
    bool isDisabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedTags.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selectedTags
                  .map((tag) => _buildTagChip(tag, style))
                  .toList(),
            ),
          ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            final availableTags = initialTags
                .where((tag) => !_selectedTags.contains(tag))
                .toList();
            if (textEditingValue.text.isEmpty) return availableTags;
            return availableTags.where(
              (tag) => tag.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          onSelected: (String selection) {
            _addTag(selection);
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  enabled: !isDisabled,
                  onSubmitted: isDisabled
                      ? null
                      : (value) {
                          final trimmedValue = value.trim();
                          if (trimmedValue.isNotEmpty &&
                              initialTags.contains(trimmedValue) &&
                              !_selectedTags.contains(trimmedValue)) {
                            textEditingController.clear();
                            _addTag(trimmedValue);
                          } else if (_selectedTags.contains(trimmedValue)) {
                            setState(() {
                              _errorText = 'Tag already selected';
                            });
                          } else {
                            setState(() {
                              _errorText = 'Tag must match predefined list';
                            });
                          }
                        },
                  onChanged: (value) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: placeholder,
                    border: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(
                        style['borderRadius'],
                      ),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(
                        style['borderRadius'],
                      ),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(
                        style['borderRadius'],
                      ),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 2.0,
                      ),
                    ),
                    filled: style['backgroundColor'] != null,
                    fillColor: StyleUtils.parseColor(style['backgroundColor']),
                    errorText: _errorText,
                  ),
                  style: TextStyle(
                    fontSize: style['fontSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option),
                        onTap: isDisabled ? null : () => onSelected(option),
                        hoverColor: Colors.grey[100],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => _showSuggestions = false),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsDisplayView(Map<String, dynamic> style, bool isDisabled) {
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _showSuggestions = true;
              });
            },
      child: _selectedTags.isEmpty
          ? const Center(
              child: Text(
                'Click to add tags',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selectedTags
                  .map(
                    (tag) => _buildTagChip(
                      tag,
                      style,
                      allowRemoval: true,
                      isDisabled: isDisabled,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.component.config;
    final initialTags =
        (config['initialTags'] as List<dynamic>?)?.cast<String>() ?? [];
    final placeholder = config['placeholder'] ?? 'Enter tags...';
    final isDisabled = config['disabled'] == true;

    final currentState = _determineState();
    final style = _resolveStyles(currentState);

    return Container(
      key: Key(widget.component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 1.5),
        borderRadius: BorderRadius.circular(14.0),
        color: Colors.white,
      ),
      child: _showSuggestions
          ? _buildTagsInputView(style, initialTags, placeholder, isDisabled)
          : _buildTagsDisplayView(style, isDisabled),
    );
  }
}
