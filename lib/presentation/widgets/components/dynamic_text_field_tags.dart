import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DynamicTextFieldTags extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic value) onComplete;

  const DynamicTextFieldTags({super.key, required this.component, required this.onComplete});

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
    final initialTags = (widget.component.config['initialTags'] as List<dynamic>?)?.cast<String>() ?? [];
    _selectedTags.addAll(initialTags);
  }

  @override
  Widget build(BuildContext context) {
    final style = Map<String, dynamic>.from(widget.component.style);
    final config = widget.component.config;
    final initialTags = (config['initialTags'] as List<dynamic>?)?.cast<String>() ?? [];
    final placeholder = config['placeholder'] ?? 'Enter tags...';

    // Determine current state
    String currentState = 'base';
    if (_selectedTags.isNotEmpty) currentState = 'success';
    if (_errorText != null) currentState = 'error';
    if (widget.component.states != null && widget.component.states!.containsKey(currentState)) {
      final stateStyle = widget.component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    if (_showSuggestions) {
      return Container(
        key: Key(widget.component.id),
        padding: StyleUtils.parsePadding(style['padding']),
        margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 1.5),
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedTags.map((tag) {
                    return Container(
                      decoration: BoxDecoration(
                        color: StyleUtils.parseColor('#CDD2FD'),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: StyleUtils.parseColor('#CDD2FD'), width: 10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 14,
                                color: StyleUtils.parseColor('#6979F8'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTags.remove(tag);
                                context.read<DynamicFormBloc>().add(
                                  UpdateFormFieldEvent(
                                    componentId: widget.component.id,
                                    value: _selectedTags.toList(),
                                  ),
                                );
                                widget.onComplete(_selectedTags.toList());
                              });
                            },
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final availableTags = initialTags.where((tag) => !_selectedTags.contains(tag)).toList();
                if (textEditingValue.text.isEmpty) return availableTags;
                return availableTags.where(
                      (tag) => tag.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                );
              },
              onSelected: (String selection) {
                if (!_selectedTags.contains(selection)) {
                  setState(() {
                    _selectedTags.add(selection);
                    _errorText = null;
                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: widget.component.id,
                        value: _selectedTags.toList(),
                      ),
                    );
                    widget.onComplete(_selectedTags.toList());
                  });
                }
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (value) {
                    if (value.isNotEmpty && initialTags.contains(value.trim()) && !_selectedTags.contains(value.trim())) {
                      textEditingController.clear();
                      setState(() {
                        _selectedTags.add(value.trim());
                        _errorText = null;
                        context.read<DynamicFormBloc>().add(
                          UpdateFormFieldEvent(
                            componentId: widget.component.id,
                            value: _selectedTags.toList(),
                          ),
                        );
                        widget.onComplete(_selectedTags.toList());
                      });
                    } else if (_selectedTags.contains(value.trim())) {
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
                      borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
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
                            onTap: () => onSelected(option),
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
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _showSuggestions = true;
          });
        },
        child: Container(
          key: Key(widget.component.id),
          padding: StyleUtils.parsePadding(style['padding']),
          margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 1.5),
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
          ),
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
            children: _selectedTags.map((tag) {
              return Container(
                decoration: BoxDecoration(
                  color: StyleUtils.parseColor('#CDD2FD'),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: StyleUtils.parseColor('#CDD2FD'), width: 10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 16,
                        color: StyleUtils.parseColor('#6979F8'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTags.remove(tag);
                          context.read<DynamicFormBloc>().add(
                            UpdateFormFieldEvent(
                              componentId: widget.component.id,
                              value: _selectedTags.toList(),
                            ),
                          );
                          widget.onComplete(_selectedTags.toList());
                        });
                      },
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
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}