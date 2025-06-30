// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDropdown extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicDropdown({super.key, required this.component});

  @override
  State<DynamicDropdown> createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  //bool _is_hovering = false;
  final FocusNode _focus_node = FocusNode();
  final GlobalKey _dropdown_key = GlobalKey();
  OverlayEntry? _overlay_entry;

  @override
  void dispose() {
    _overlay_entry?.remove();
    _focus_node.dispose();
    super.dispose();
  }

  IconData? _map_icon_name_to_icon_data(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  void _show_dropdown_panel(
    BuildContext context,
    DynamicFormModel component,
    Rect rect,
    String? selected_value,
  ) {
    final items = component.config['items'] as List<dynamic>? ?? [];
    final style = component.style;
    final is_searchable = component.config['searchable'] as bool? ?? false;
    final dropdown_width =
        (style['dropdown_width'] as num?)?.toDouble() ?? rect.width;

    _overlay_entry = OverlayEntry(
      builder: (context) {
        List<dynamic> filtered_items = List.from(items);
        String search_query = '';
        final search_controller = TextEditingController();

        return StatefulBuilder(
          builder: (context, set_panel_state) {
            if (is_searchable) {
              filtered_items = items.where((item) {
                final label = item['label']?.toString().toLowerCase() ?? '';
                if (item['type'] == 'divider') return true;
                return label.contains(search_query.toLowerCase());
              }).toList();
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _overlay_entry?.remove();
                      _overlay_entry = null;
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  top: rect.top,
                  left: rect.left,
                  width: dropdown_width,
                  child: Material(
                    elevation: 4.0,
                    color: StyleUtils.parseColor(
                      style['dropdown_background_color'],
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['border_radius'],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount:
                            filtered_items.length + (is_searchable ? 1 : 0),
                        separatorBuilder: (context, index) {
                          final item_index = is_searchable ? index - 1 : index;
                          if (item_index < 0 ||
                              item_index >= filtered_items.length) {
                            return const SizedBox.shrink();
                          }
                          final item = filtered_items[item_index];
                          final next_item =
                              (item_index + 1 < filtered_items.length)
                              ? filtered_items[item_index + 1]
                              : null;
                          if (item['type'] == 'divider' ||
                              next_item?['type'] == 'divider') {
                            return const SizedBox.shrink();
                          }
                          return Divider(
                            color: StyleUtils.parseColor(
                              style['divider_color'],
                            ),
                            height: 1,
                          );
                        },
                        itemBuilder: (context, index) {
                          if (is_searchable && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextField(
                                controller: search_controller,
                                focusNode: _focus_node,
                                decoration: InputDecoration(
                                  hintText: component.config['placeholder'],
                                  isDense: true,
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  set_panel_state(() {
                                    search_query = value;
                                  });
                                  // Do not send event here because this is just temporary search
                                },
                                onSubmitted: (value) {
                                  if (filtered_items.isNotEmpty &&
                                      filtered_items.first['type'] !=
                                          'divider') {
                                    final first_item = filtered_items.first;
                                    final new_value = first_item['id'];
                                    context.read<DynamicFormBloc>().add(
                                      UpdateFormFieldEvent(
                                        componentId: component.id,
                                        value: new_value,
                                      ),
                                    );
                                    debugPrint(
                                      '[Dropdown] ${component.id} value updated: $new_value',
                                    );
                                  } else if (value.isNotEmpty) {
                                    context.read<DynamicFormBloc>().add(
                                      UpdateFormFieldEvent(
                                        componentId: component.id,
                                        value: value,
                                      ),
                                    );
                                    debugPrint(
                                      '[Dropdown] ${component.id} value updated: $value',
                                    );
                                  }
                                  _overlay_entry?.remove();
                                  _overlay_entry = null;
                                },
                              ),
                            );
                          }

                          final item =
                              filtered_items[is_searchable ? index - 1 : index];
                          final item_type = item['type'] as String? ?? 'item';

                          if (item_type == 'divider') {
                            return Divider(
                              color: StyleUtils.parseColor(
                                style['divider_color'],
                              ),
                              height: 1,
                            );
                          }

                          final label = item['label'] as String? ?? '';
                          final value = item['id'] as String? ?? '';
                          final icon_name = item['icon'] as String?;
                          final avatar_url = item['avatar'] as String?;
                          final item_style =
                              item['style'] as Map<String, dynamic>? ?? {};

                          return InkWell(
                            onTap: () {
                              context.read<DynamicFormBloc>().add(
                                UpdateFormFieldEvent(
                                  componentId: component.id,
                                  value: value,
                                ),
                              );
                              debugPrint(
                                '[Dropdown] ${component.id} value updated: $value',
                              );
                              _overlay_entry?.remove();
                              _overlay_entry = null;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  if (avatar_url != null) ...[
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(avatar_url),
                                      radius: 16,
                                    ),
                                    const SizedBox(width: 12),
                                  ] else if (icon_name != null) ...[
                                    Icon(
                                      _map_icon_name_to_icon_data(icon_name),
                                      color: StyleUtils.parseColor(
                                        item_style['color'] ?? style['color'],
                                      ),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: StyleUtils.parseColor(
                                          item_style['color'] ?? style['color'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_overlay_entry!);
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
        final config = component.config;
        final style = Map<String, dynamic>.from(component.style);
        final trigger_avatar = config['avatar'] as String?;
        final trigger_icon = config['icon'] as String?;
        final is_searchable = config['searchable'] as bool? ?? false;
        final placeholder = config['placeholder'] as String? ?? 'Search';
        final value = config['value']?.toString();
        final current_state = config['current_state'] ?? 'base';
        final is_disabled = config['disabled'] == true;

        // Always apply variant with_icon if icon exists
        if ((trigger_icon != null || style['icon'] != null) &&
            component.variants != null &&
            component.variants!.containsKey('with_icon')) {
          final variant_style =
              component.variants!['with_icon']['style']
                  as Map<String, dynamic>?;
          if (variant_style != null) style.addAll(variant_style);
        }

        // Apply variant with_avatar if avatar exists
        if (trigger_avatar != null &&
            component.variants != null &&
            component.variants!.containsKey('with_avatar')) {
          final variant_style =
              component.variants!['with_avatar']['style']
                  as Map<String, dynamic>?;
          if (variant_style != null) style.addAll(variant_style);
        }
        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) style.addAll(state_style);
        }

        // Calculate display label
        String? display_label;
        if (value == null || value.isEmpty) {
          display_label =
              config['label'] ?? config['placeholder'] ?? 'Select an option';
        } else {
          final items = config['items'] as List<dynamic>? ?? [];
          final selected_item = items.firstWhere(
            (item) => item['id'] == value && item['type'] != 'divider',
            orElse: () => null,
          );
          if (selected_item != null) {
            display_label = selected_item['label'] as String? ?? value;
          } else {
            display_label = value;
          }
        }

        Widget trigger_content;
        if (is_searchable) {
          trigger_content = Row(
            children: [
              Expanded(
                child: Text(
                  display_label ?? placeholder,
                  style: TextStyle(
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                ),
              ),
              Icon(
                Icons.search,
                color: StyleUtils.parseColor(style['icon_color'] ?? '#000000'),
              ),
            ],
          );
        } else if (trigger_icon != null &&
            (display_label == null || display_label.isEmpty)) {
          // Icon-only trigger
          trigger_content = Icon(
            _map_icon_name_to_icon_data(trigger_icon),
            color: StyleUtils.parseColor(style['icon_color'] ?? '#000000'),
            size: (style['icon_size'] as num?)?.toDouble() ?? 24.0,
          );
        } else {
          trigger_content = Row(
            children: [
              if (trigger_icon != null) ...[
                Icon(
                  _map_icon_name_to_icon_data(trigger_icon),
                  color: StyleUtils.parseColor(
                    style['icon_color'] ?? '#000000',
                  ),
                  size: (style['icon_size'] as num?)?.toDouble() ?? 18.0,
                ),
                const SizedBox(width: 8),
              ],
              if (trigger_avatar != null) ...[
                CircleAvatar(
                  backgroundImage: NetworkImage(trigger_avatar),
                  radius: 16,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  display_label ?? config['placeholder'] ?? 'Select an option',
                  style: TextStyle(
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                ),
              ),
              Icon(
                _overlay_entry != null && _overlay_entry!.mounted
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: StyleUtils.parseColor(style['color'] ?? '#000000'),
              ),
            ],
          );
        }

        return Focus(
          focusNode: _focus_node,
          child: MouseRegion(
            child: InkWell(
              key: _dropdown_key,
              //focusNode: _focus_node,
              onTap: is_disabled
                  ? null
                  : () {
                      FocusScope.of(context).requestFocus(_focus_node);
                      final render_box =
                          _dropdown_key.currentContext!.findRenderObject()
                              as RenderBox;
                      final size = render_box.size;
                      final offset = render_box.localToGlobal(Offset.zero);
                      _show_dropdown_panel(
                        context,
                        component,
                        Rect.fromLTWH(
                          offset.dx,
                          offset.dy + size.height,
                          size.width,
                          0,
                        ),
                        value,
                      );
                    },
              child: Container(
                padding: StyleUtils.parsePadding(style['padding']),
                margin: StyleUtils.parsePadding(style['margin']),
                decoration: BoxDecoration(
                  color: StyleUtils.parseColor(style['background_color']),
                  border: Border.all(
                    color: StyleUtils.parseColor(style['border_color']),
                    width: (style['border_width'] as num?)?.toDouble() ?? 1.0,
                  ),
                  borderRadius: StyleUtils.parseBorderRadius(
                    style['border_radius'],
                  ),
                ),
                child: trigger_content,
              ),
            ),
          ),
        );
      },
    );
  }
}
