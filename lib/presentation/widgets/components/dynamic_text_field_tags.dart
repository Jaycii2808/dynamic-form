// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
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
  bool _show_suggestions = false;
  String? _error_text;
  final Set<String> _selected_tags = {};

  @override
  void initState() {
    super.initState();
    final initial_tags = _get_initial_tags_from_config(widget.component.config);
    _selected_tags.addAll(initial_tags);
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> _get_initial_tags_from_config(Map<String, dynamic> config) {
    // Support both snake_case and camelCase
    final initial_tags_value = config['initial_tags'] ?? config['initialTags'];
    if (initial_tags_value is List<dynamic>) {
      return initial_tags_value.cast<String>();
    }
    return [];
  }

  List<String> _get_available_tags_from_config(Map<String, dynamic> config) {
    // Support both snake_case and camelCase
    final available_tags_value =
        config['available_tags'] ??
        config['availableTags'] ??
        config['initial_tags'] ??
        config['initialTags'];
    if (available_tags_value is List<dynamic>) {
      return available_tags_value.cast<String>();
    }
    return [];
  }

  void _handle_tag_change(List<String> tags, DynamicFormModel component) {
    String new_state = 'base';
    if (tags.isNotEmpty) {
      new_state = 'success';
    }

    debugPrint(
      '🏷️ [${component.id}] Tags changing: ${_selected_tags.toList()} → $tags',
    );

    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
        value: {
          'value': tags,
          'selected_tags': tags,
          'current_state': new_state,
          'error_text': null,
        },
      ),
    );
  }

  void _add_tag(String tag, DynamicFormModel component) {
    if (!_selected_tags.contains(tag)) {
      setState(() {
        _selected_tags.add(tag);
        _error_text = null;
      });
      _handle_tag_change(_selected_tags.toList(), component);
    }
  }

  void _remove_tag(String tag, DynamicFormModel component) {
    setState(() {
      _selected_tags.remove(tag);
    });
    _handle_tag_change(_selected_tags.toList(), component);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        // Get the latest component from BLoC state
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Get dynamic state
        final current_state = component.config['current_state'] ?? 'base';
        final component_tags =
            component.config['selected_tags'] ??
            component.config['value'] ??
            [];
        final component_error = component.config['error_text'];

        // Sync local state with BLoC state
        if (component_tags is List<dynamic>) {
          final tags_list = component_tags.cast<String>();
          if (_selected_tags.toList().toString() != tags_list.toString()) {
            _selected_tags.clear();
            _selected_tags.addAll(tags_list);
          }
        }

        // Update error text from BLoC state
        _error_text = component_error;

        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

        final config = component.config;
        final available_tags = _get_available_tags_from_config(config);
        final placeholder = config['placeholder'] ?? 'Enter tags...';
        final is_disabled = config['disabled'] == true;
        final has_tags = _selected_tags.isNotEmpty;

        debugPrint(
          '🔍 [${component.id}] tags: ${_selected_tags.toList()}, current_state: $current_state, error: ${component_error ?? "none"}',
        );

        // Apply variant styles
        if (component.variants != null) {
          if (has_tags && component.variants!.containsKey('with_tags')) {
            final variant_style =
                component.variants!['with_tags']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) {
              debugPrint(
                '🎨 [${component.id}] Applying with_tags variant: $variant_style',
              );
              style.addAll(variant_style);
            }
          }
          // Backward compatibility with camelCase variants
          if (has_tags && component.variants!.containsKey('withTags')) {
            final variant_style =
                component.variants!['withTags']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
        }

        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) {
            debugPrint(
              '🎨 [${component.id}] Applying $current_state state: $state_style',
            );
            style.addAll(state_style);
          }
        }

        return _build_body(
          style,
          config,
          component,
          current_state,
          available_tags,
          placeholder,
          is_disabled,
        );
      },
    );
  }

  Widget _build_body(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    DynamicFormModel component,
    String current_state,
    List<String> available_tags,
    String placeholder,
    bool is_disabled,
  ) {
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      decoration: BoxDecoration(
        border: Border.all(
          color: StyleUtils.parseColor(
            style['border_color'] ?? style['borderColor'] ?? '#6979F8',
          ),
          width:
              (style['border_width'] ?? style['borderWidth'])?.toDouble() ??
              1.5,
        ),
        borderRadius: StyleUtils.parseBorderRadius(
          style['border_radius'] ?? style['borderRadius'] ?? 14.0,
        ),
        color: StyleUtils.parseColor(
          style['background_color'] ?? style['backgroundColor'],
        ),
      ),
      child: _show_suggestions
          ? _build_tags_input_view(
              style,
              available_tags,
              placeholder,
              is_disabled,
              component,
            )
          : _build_tags_display_view(style, is_disabled),
    );
  }

  Widget _build_tag_chip(
    String tag,
    Map<String, dynamic> style, {
    bool allow_removal = false,
    bool is_disabled = false,
    DynamicFormModel? component,
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
                fontSize:
                    (style['tag_text_size'] ?? style['tagTextSize'])
                        ?.toDouble() ??
                    14,
                color: StyleUtils.parseColor(
                  style['tag_text_color'] ?? style['tagTextColor'] ?? '#6979F8',
                ),
              ),
            ),
          ),
          if (allow_removal && !is_disabled) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: component != null
                  ? () => _remove_tag(tag, component)
                  : null,
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

  Widget _build_tags_input_view(
    Map<String, dynamic> style,
    List<String> available_tags,
    String placeholder,
    bool is_disabled,
    DynamicFormModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected_tags.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selected_tags
                  .map((tag) => _build_tag_chip(tag, style))
                  .toList(),
            ),
          ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue text_editing_value) {
            final available_unselected_tags = available_tags
                .where((tag) => !_selected_tags.contains(tag))
                .toList();
            if (text_editing_value.text.isEmpty)
              return available_unselected_tags;
            return available_unselected_tags.where(
              (tag) => tag.toLowerCase().contains(
                text_editing_value.text.toLowerCase(),
              ),
            );
          },
          onSelected: (String selection) {
            _add_tag(selection, component);
          },
          fieldViewBuilder:
              (
                context,
                text_editing_controller,
                focus_node,
                on_field_submitted,
              ) {
                return TextField(
                  controller: text_editing_controller,
                  focusNode: focus_node,
                  enabled: !is_disabled,
                  onSubmitted: is_disabled
                      ? null
                      : (value) {
                          final trimmed_value = value.trim();
                          if (trimmed_value.isNotEmpty &&
                              available_tags.contains(trimmed_value) &&
                              !_selected_tags.contains(trimmed_value)) {
                            text_editing_controller.clear();
                            _add_tag(trimmed_value, component);
                          } else if (_selected_tags.contains(trimmed_value)) {
                            setState(() {
                              _error_text = 'Tag already selected';
                            });
                          } else {
                            setState(() {
                              _error_text = 'Tag must match predefined list';
                            });
                          }
                        },
                  onChanged: (value) {
                    if (_error_text != null) {
                      setState(() => _error_text = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: placeholder,
                    border: _build_input_border(style, 'base'),
                    enabledBorder: _build_input_border(style, 'enabled'),
                    focusedBorder: _build_input_border(style, 'focused'),
                    errorBorder: _build_input_border(style, 'error'),
                    filled:
                        (style['background_color'] ??
                            style['backgroundColor']) !=
                        null,
                    fillColor: StyleUtils.parseColor(
                      style['background_color'] ?? style['backgroundColor'],
                    ),
                    errorText: _error_text,
                  ),
                  style: TextStyle(
                    fontSize:
                        (style['font_size'] ?? style['fontSize'])?.toDouble() ??
                        16,
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                );
              },
          optionsViewBuilder: (context, on_selected, options) {
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
                        onTap: is_disabled ? null : () => on_selected(option),
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
            onPressed: () => setState(() => _show_suggestions = false),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _build_tags_display_view(
    Map<String, dynamic> style,
    bool is_disabled,
  ) {
    return GestureDetector(
      onTap: is_disabled
          ? null
          : () {
              setState(() {
                _show_suggestions = true;
              });
            },
      child: _selected_tags.isEmpty
          ? const Center(
              child: Text(
                'Click to add tags',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selected_tags
                  .map(
                    (tag) => _build_tag_chip(
                      tag,
                      style,
                      allow_removal: true,
                      is_disabled: is_disabled,
                      component: widget.component,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  OutlineInputBorder _build_input_border(
    Map<String, dynamic> style,
    String state,
  ) {
    final border_radius = StyleUtils.parseBorderRadius(
      style['border_radius'] ?? style['borderRadius'],
    );
    final border_color = StyleUtils.parseColor(
      style['border_color'] ?? style['borderColor'] ?? '#6979F8',
    );
    final border_width =
        (style['border_width'] ?? style['borderWidth'])?.toDouble() ?? 1.0;

    switch (state) {
      case 'focused':
        return OutlineInputBorder(
          borderRadius: border_radius,
          borderSide: BorderSide(color: border_color, width: border_width + 1),
        );
      case 'error':
        return OutlineInputBorder(
          borderRadius: border_radius,
          borderSide: BorderSide(
            color: StyleUtils.parseColor('#F44336'),
            width: 2,
          ),
        );
      default:
        return OutlineInputBorder(
          borderRadius: border_radius,
          borderSide: BorderSide(color: border_color, width: border_width),
        );
    }
  }
}
