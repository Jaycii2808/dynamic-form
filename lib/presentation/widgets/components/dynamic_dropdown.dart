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
  final FocusNode focusNode = FocusNode();
  final GlobalKey dropdownKey = GlobalKey();
  OverlayEntry? overlayEntry;

  @override
  void dispose() {
    overlayEntry?.remove();
    focusNode.dispose();
    super.dispose();
  }

  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  void showDropdownPanel(
    BuildContext context,
    DynamicFormModel component,
    Rect rect,
    String? selectedValue,
  ) {
    final items = component.config['items'] as List<dynamic>? ?? [];
    final style = component.style;
    final isSearchable = component.config['searchable'] as bool? ?? false;
    final dropdownWidth =
        (style['dropdown_width'] as num?)?.toDouble() ?? rect.width;

    overlayEntry = OverlayEntry(
      builder: (context) {
        List<dynamic> filteredItems = List.from(items);
        String searchQuery = '';
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setPanelState) {
            if (isSearchable) {
              filteredItems = items.where((item) {
                final label = item['label']?.toString().toLowerCase() ?? '';
                if (item['type'] == 'divider') return true;
                return label.contains(searchQuery.toLowerCase());
              }).toList();
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      overlayEntry?.remove();
                      overlayEntry = null;
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  top: rect.bottom + 4,
                  left: rect.left,
                  width: dropdownWidth,
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
                            filteredItems.length + (isSearchable ? 1 : 0),
                        separatorBuilder: (context, index) {
                          final itemIndex = isSearchable ? index - 1 : index;
                          if (itemIndex < 0 ||
                              itemIndex >= filteredItems.length) {
                            return const SizedBox.shrink();
                          }
                          final item = filteredItems[itemIndex];
                          final nextItem =
                              (itemIndex + 1 < filteredItems.length)
                              ? filteredItems[itemIndex + 1]
                              : null;
                          if (item['type'] == 'divider' ||
                              nextItem?['type'] == 'divider') {
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
                          if (isSearchable && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextField(
                                controller: searchController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: component.config['placeholder'],
                                  isDense: true,
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setPanelState(() {
                                    searchQuery = value;
                                  });
                                },
                                onSubmitted: (value) {
                                  if (filteredItems.isNotEmpty &&
                                      filteredItems.first['type'] !=
                                          'divider') {
                                    final firstItem = filteredItems.first;
                                    final newValue = firstItem['id'];
                                    context.read<DynamicFormBloc>().add(
                                      UpdateFormFieldEvent(
                                        componentId: component.id,
                                        value: newValue,
                                      ),
                                    );
                                    debugPrint(
                                      '[Dropdown] ${component.id} value updated: $newValue',
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
                                  overlayEntry?.remove();
                                  overlayEntry = null;
                                },
                              ),
                            );
                          }

                          final item =
                              filteredItems[isSearchable ? index - 1 : index];
                          final itemType = item['type'] as String? ?? 'item';

                          if (itemType == 'divider') {
                            return Divider(
                              color: StyleUtils.parseColor(
                                style['divider_color'],
                              ),
                              height: 1,
                            );
                          }

                          final label = item['label'] as String? ?? '';
                          final value = item['id'] as String? ?? '';
                          final iconName = item['icon'] as String?;
                          final avatarUrl = item['avatar'] as String?;
                          final itemStyle =
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
                              overlayEntry?.remove();
                              overlayEntry = null;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  if (avatarUrl != null) ...[
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(avatarUrl),
                                      radius: 16,
                                    ),
                                    const SizedBox(width: 12),
                                  ] else if (iconName != null) ...[
                                    Icon(
                                      mapIconNameToIconData(iconName),
                                      color: StyleUtils.parseColor(
                                        itemStyle['color'] ?? style['color'],
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
                                          itemStyle['color'] ?? style['color'],
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
    Overlay.of(context).insert(overlayEntry!);
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
        final triggerAvatar = config['avatar'] as String?;
        final triggerIcon = config['icon'] as String?;
        final isSearchable = config['searchable'] as bool? ?? false;
        final placeholder = config['placeholder'] as String? ?? 'Search';
        final value = config['value']?.toString();
        final currentState = config['current_state'] ?? 'base';
        final isDisabled = config['disabled'] == true;

        // Always apply variant with_icon if icon exists
        if ((triggerIcon != null || style['icon'] != null) &&
            component.variants != null &&
            component.variants!.containsKey('with_icon')) {
          final variantStyle =
              component.variants!['with_icon']['style']
                  as Map<String, dynamic>?;
          if (variantStyle != null) style.addAll(variantStyle);
        }

        // Apply variant with_avatar if avatar exists
        if (triggerAvatar != null &&
            component.variants != null &&
            component.variants!.containsKey('with_avatar')) {
          final variantStyle =
              component.variants!['with_avatar']['style']
                  as Map<String, dynamic>?;
          if (variantStyle != null) style.addAll(variantStyle);
        }
        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }

        // Calculate display label
        String? displayLabel;
        if (value == null || value.isEmpty) {
          displayLabel =
              config['label'] ?? config['placeholder'] ?? 'Select an option';
        } else {
          final items = config['items'] as List<dynamic>? ?? [];
          final selectedItem = items.firstWhere(
            (item) => item['id'] == value && item['type'] != 'divider',
            orElse: () => null,
          );
          if (selectedItem != null) {
            displayLabel = selectedItem['label'] as String? ?? value;
          } else {
            displayLabel = value;
          }
        }

        Widget triggerContent;
        if (isSearchable) {
          triggerContent = Row(
            children: [
              Expanded(
                child: Text(
                  displayLabel ?? placeholder,
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
        } else if (triggerIcon != null &&
            (displayLabel == null || displayLabel.isEmpty)) {
          // Icon-only trigger
          triggerContent = Icon(
            mapIconNameToIconData(triggerIcon),
            color: StyleUtils.parseColor(style['icon_color'] ?? '#000000'),
            size: (style['icon_size'] as num?)?.toDouble() ?? 24.0,
          );
        } else {
          triggerContent = Row(
            children: [
              if (triggerIcon != null) ...[
                Icon(
                  mapIconNameToIconData(triggerIcon),
                  color: StyleUtils.parseColor(
                    style['icon_color'] ?? '#000000',
                  ),
                  size: (style['icon_size'] as num?)?.toDouble() ?? 18.0,
                ),
                const SizedBox(width: 8),
              ],
              if (triggerAvatar != null) ...[
                CircleAvatar(
                  backgroundImage: NetworkImage(triggerAvatar),
                  radius: 16,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  displayLabel ?? config['placeholder'] ?? 'Select an option',
                  style: TextStyle(
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                ),
              ),
              Icon(
                overlayEntry != null && overlayEntry!.mounted
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: StyleUtils.parseColor(style['color'] ?? '#000000'),
              ),
            ],
          );
        }

        return Focus(
          focusNode: focusNode,
          child: MouseRegion(
            child: InkWell(
              key: dropdownKey,
              //focusNode: _focus_node,
              onTap: isDisabled
                  ? null
                  : () {
                      FocusScope.of(context).requestFocus(focusNode);
                      final renderBox =
                          dropdownKey.currentContext!.findRenderObject()
                              as RenderBox;
                      final size = renderBox.size;
                      final offset = renderBox.localToGlobal(Offset.zero);
                      showDropdownPanel(
                        context,
                        component,
                        Rect.fromLTWH(
                          offset.dx,
                          offset.dy,
                          size.width,
                          size.height,
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
                child: triggerContent,
              ),
            ),
          ),
        );
      },
    );
  }
}
