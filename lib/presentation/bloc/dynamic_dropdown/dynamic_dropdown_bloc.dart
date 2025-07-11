import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_dropdown/dynamic_dropdown_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_dropdown/dynamic_dropdown_state.dart';
import 'package:flutter/material.dart';

class DynamicDropdownBloc
    extends Bloc<DynamicDropdownEvent, DynamicDropdownState> {
  final DynamicFormModel initialComponent;
  late FocusNode focusNode;
  late FocusNode searchFocusNode;

  DynamicDropdownBloc({required this.initialComponent})
    : super(const DynamicDropdownInitial()) {
    focusNode = FocusNode();
    searchFocusNode = FocusNode();

    on<InitializeDropdownEvent>(_onInitialize);
    on<DropdownValueChangedEvent>(_onValueChanged);
    on<ToggleDropdownEvent>(_onToggleDropdown);
    on<OpenDropdownEvent>(_onOpenDropdown);
    on<CloseDropdownEvent>(_onCloseDropdown);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<UpdateDropdownFromExternalEvent>(_onUpdateFromExternal);
  }

  @override
  Future<void> close() {
    focusNode.dispose();
    searchFocusNode.dispose();
    // Dispose search controller and cleanup overlay if it exists
    if (state is DynamicDropdownSuccess) {
      final currentState = state as DynamicDropdownSuccess;
      currentState.searchController?.dispose();

      // Safely remove overlay on bloc disposal
      if (currentState.overlayEntry != null) {
        try {
          currentState.overlayEntry!.remove();
          debugPrint('🧹 [DropdownBloc] Overlay cleaned up on bloc disposal');
        } catch (e) {
          debugPrint('⚠️ [DropdownBloc] Overlay cleanup error: $e');
        }
      }
    }
    return super.close();
  }

  Future<void> _onInitialize(
    InitializeDropdownEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    try {
      emit(
        DynamicDropdownLoading(
          component: initialComponent,
        ),
      );

      final styleConfig = StyleConfig.fromJson(initialComponent.style);
      final inputConfig = InputConfig.fromJson(initialComponent.config);

      // Compute all values like in original _computeValues()
      final computedValues = _computeValues(initialComponent);

      // Compute form state
      final formState = _computeFormState(
        initialComponent,
        computedValues['value'],
      );

      // Compute validation error
      final errorText = _validateDropdown(
        initialComponent,
        computedValues['value'],
      );

      // Create search controller if dropdown is searchable
      final searchController = computedValues['isSearchable'] as bool
          ? TextEditingController()
          : null;

      debugPrint(
        '🟢 [DropdownBloc] Initialized: ${initialComponent.id}, value: ${computedValues['value']}, state: $formState',
      );

      emit(
        DynamicDropdownSuccess(
          component: initialComponent,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          focusNode: focusNode,
          searchFocusNode: searchFocusNode,
          currentValue: computedValues['value'],
          currentState: computedValues['currentState'],
          isDisabled: computedValues['isDisabled'],
          isSearchable: computedValues['isSearchable'],
          placeholder: computedValues['placeholder'],
          triggerIcon: computedValues['triggerIcon'],
          triggerAvatar: computedValues['triggerAvatar'],
          computedStyle: computedValues['style'],
          displayLabel: computedValues['displayLabel'],
          triggerContent: computedValues['triggerContent'],
          items: computedValues['items'],
          filteredItems: computedValues['items'], // Initially all items
          searchQuery: '',
          isDropdownOpen: false,
          searchController: searchController,
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] Initialization error: $e');
      emit(
        DynamicDropdownError(
          errorMessage: 'Failed to initialize dropdown: ${e.toString()}',
          component: initialComponent,
        ),
      );
    }
  }

  Future<void> _onValueChanged(
    DropdownValueChangedEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicDropdownSuccess) return;

    try {
      final updatedComponent = _updateComponentValue(
        currentState.component!,
        event.value,
      );

      final formState = _computeFormState(updatedComponent, event.value);
      final errorText = _validateDropdown(updatedComponent, event.value);

      // Recompute all values with new component
      final computedValues = _computeValues(updatedComponent);

      // Update trigger content to reflect dropdown closed state
      final triggerContent = _computeTriggerContent(
        computedValues['displayLabel'],
        computedValues['placeholder'],
        computedValues['triggerIcon'],
        computedValues['triggerAvatar'],
        computedValues['isSearchable'],
        computedValues['style'],
        false, // Dropdown closes after selection
      );

      debugPrint(
        '🔄 [DropdownBloc] Value changed: ${updatedComponent.id} = ${event.value}',
      );

      // Close dropdown after selection by updating state directly
      // Remove overlay if it exists
      if (currentState.overlayEntry != null && currentState.isDropdownOpen) {
        try {
          currentState.overlayEntry!.remove();
          debugPrint('📁 [DropdownBloc] Overlay removed on value change');
        } catch (overlayError) {
          debugPrint('⚠️ [DropdownBloc] Overlay remove error: $overlayError');
        }
      }

      emit(
        currentState.copyWith(
          component: updatedComponent,
          currentValue: event.value,
          currentState: computedValues['currentState'],
          isDisabled: computedValues['isDisabled'],
          displayLabel: computedValues['displayLabel'],
          triggerContent: triggerContent,
          formState: formState,
          errorText: errorText,
          isDropdownOpen: false, // Close dropdown after selection
          overlayEntry: null, // Clear overlay reference
          searchQuery: '', // Reset search
          filteredItems: computedValues['items'], // Reset filter
          selectionTimestamp:
              DateTime.now().millisecondsSinceEpoch, // Force update
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] Value change error: $e');
      emit(
        DynamicDropdownError(
          errorMessage: 'Failed to update value: ${e.toString()}',
          component: currentState.component,
          formState: currentState.formState,
          errorText: currentState.errorText,
        ),
      );
    }
  }

  Future<void> _onToggleDropdown(
    ToggleDropdownEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicDropdownSuccess) return;

    try {
      // Update trigger content with new dropdown state for arrow icon
      final triggerContent = _computeTriggerContent(
        currentState.displayLabel,
        currentState.placeholder,
        currentState.triggerIcon,
        currentState.triggerAvatar,
        currentState.isSearchable,
        currentState.computedStyle,
        event.isOpen,
      );

      emit(
        currentState.copyWith(
          isDropdownOpen: event.isOpen,
          triggerContent: triggerContent,
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] Toggle error: $e');
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicDropdownSuccess) return;

    try {
      // Filter items based on search query (same logic as in original)
      List<dynamic> filteredItems = currentState.items;
      if (currentState.isSearchable) {
        filteredItems = currentState.items.where((item) {
          final label = item['label']?.toString().toLowerCase() ?? '';
          if (item['type'] == 'divider') return true;
          return label.contains(event.query.toLowerCase());
        }).toList();
      }

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredItems: filteredItems,
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] Search error: $e');
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateDropdownFromExternalEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicDropdownSuccess) return;

    try {
      final styleConfig = StyleConfig.fromJson(event.component.style);
      final inputConfig = InputConfig.fromJson(event.component.config);

      final formState = _computeFormState(
        event.component,
        event.component.config[ValueKeyEnum.value.key]?.toString(),
      );
      final errorText = _validateDropdown(
        event.component,
        event.component.config[ValueKeyEnum.value.key]?.toString(),
      );

      // Recompute all values with updated component
      final computedValues = _computeValues(event.component);

      // Preserve current dropdown open state
      final triggerContent = _computeTriggerContent(
        computedValues['displayLabel'],
        computedValues['placeholder'],
        computedValues['triggerIcon'],
        computedValues['triggerAvatar'],
        computedValues['isSearchable'],
        computedValues['style'],
        currentState.isDropdownOpen,
      );

      debugPrint(
        '🔄 [DropdownBloc] External update: ${event.component.id}, value: ${computedValues['value']}',
      );

      emit(
        currentState.copyWith(
          component: event.component,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          currentValue: computedValues['value'],
          currentState: computedValues['currentState'],
          isDisabled: computedValues['isDisabled'],
          isSearchable: computedValues['isSearchable'],
          placeholder: computedValues['placeholder'],
          triggerIcon: computedValues['triggerIcon'],
          triggerAvatar: computedValues['triggerAvatar'],
          computedStyle: computedValues['style'],
          displayLabel: computedValues['displayLabel'],
          triggerContent: triggerContent,
          items: computedValues['items'],
          filteredItems: computedValues['items'], // Reset filtered items
          searchQuery: '', // Reset search query
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] External update error: $e');
      emit(
        DynamicDropdownError(
          errorMessage: 'Failed to update from external: ${e.toString()}',
          component: event.component,
        ),
      );
    }
  }

  Future<void> _onOpenDropdown(
    OpenDropdownEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicDropdownSuccess) return;

    try {
      // Create search controller if it doesn't exist
      final searchController =
          currentState.searchController ?? TextEditingController();

      // Create overlay entry with position and context
      final overlayEntry = _createOverlayEntry(
        event.position,
        currentState,
        searchController,
        event.context,
      );

      // Update trigger content with dropdown open state
      final triggerContent = _computeTriggerContent(
        currentState.displayLabel,
        currentState.placeholder,
        currentState.triggerIcon,
        currentState.triggerAvatar,
        currentState.isSearchable,
        currentState.computedStyle,
        true, // Dropdown is opening
      );

      debugPrint(
        '📂 [DropdownBloc] Opening dropdown at position: ${event.position}',
      );

      emit(
        currentState.copyWith(
          isDropdownOpen: true,
          dropdownPosition: event.position,
          overlayEntry: overlayEntry,
          searchController: searchController,
          triggerContent: triggerContent,
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] Open dropdown error: $e');
    }
  }

  Future<void> _onCloseDropdown(
    CloseDropdownEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicDropdownSuccess) return;

    try {
      // Only remove overlay if it exists and is not already removed
      if (currentState.overlayEntry != null && currentState.isDropdownOpen) {
        try {
          currentState.overlayEntry!.remove();
          debugPrint('📁 [DropdownBloc] Overlay removed successfully');
        } catch (overlayError) {
          debugPrint(
            '⚠️ [DropdownBloc] Overlay already removed: $overlayError',
          );
        }
      }

      // Update trigger content with dropdown closed state
      final triggerContent = _computeTriggerContent(
        currentState.displayLabel,
        currentState.placeholder,
        currentState.triggerIcon,
        currentState.triggerAvatar,
        currentState.isSearchable,
        currentState.computedStyle,
        false, // Dropdown is closing
      );

      debugPrint('📁 [DropdownBloc] Closing dropdown');

      emit(
        currentState.copyWith(
          isDropdownOpen: false,
          dropdownPosition: null,
          overlayEntry: null,
          triggerContent: triggerContent,
          searchQuery: '', // Reset search when closing
          filteredItems: currentState.items, // Reset filter
        ),
      );
    } catch (e) {
      debugPrint('❌ [DropdownBloc] Close dropdown error: $e');
    }
  }

  // ========== HELPER METHODS - moved from widget ==========

  DynamicFormModel _updateComponentValue(
    DynamicFormModel component,
    String newValue,
  ) {
    final updatedConfig = Map<String, dynamic>.from(component.config);
    updatedConfig[ValueKeyEnum.value.key] = newValue;

    return DynamicFormModel(
      id: component.id,
      type: component.type,
      config: updatedConfig,
      style: component.style,
      variants: component.variants,
      states: component.states,
      validation: component.validation,
      inputTypes: component.inputTypes,
      order: component.order,
    );
  }

  FormStateEnum _computeFormState(DynamicFormModel component, String? value) {
    // Same logic as other components - value exists = success
    if (value != null && value.isNotEmpty) {
      return FormStateEnum.success;
    }
    return FormStateEnum.base;
  }

  String? _validateDropdown(DynamicFormModel component, String? value) {
    return ValidationUtils.validateForm(component, value ?? '');
  }

  // Main computation method - combines all original logic
  Map<String, dynamic> _computeValues(DynamicFormModel component) {
    final config = component.config;

    // Basic values (from original _computeValues)
    final triggerAvatar = config['avatar'] as String?;
    final triggerIcon = config['icon'] as String?;
    final isSearchable = config['searchable'] as bool? ?? false;
    final placeholder = config['placeholder'] as String? ?? 'Search';
    final value = config['value']?.toString();
    final currentState = config['current_state'] ?? 'base';
    final isDisabled = config['disabled'] == true;
    final items = config['items'] as List<dynamic>? ?? [];

    // Compute styles (from original _computeStyles)
    final style = _computeStyles(
      component,
      triggerIcon,
      triggerAvatar,
      currentState,
    );

    // Compute display label (from original _computeDisplayLabel)
    final displayLabel = _computeDisplayLabel(config, value, items);

    // Compute trigger content (from original _computeTriggerContent)
    final triggerContent = _computeTriggerContent(
      displayLabel,
      placeholder,
      triggerIcon,
      triggerAvatar,
      isSearchable,
      style,
      false, // Default to closed state
    );

    return {
      'value': value,
      'currentState': currentState,
      'isDisabled': isDisabled,
      'isSearchable': isSearchable,
      'placeholder': placeholder,
      'triggerIcon': triggerIcon,
      'triggerAvatar': triggerAvatar,
      'style': style,
      'displayLabel': displayLabel,
      'triggerContent': triggerContent,
      'items': items,
    };
  }

  Map<String, dynamic> _computeStyles(
    DynamicFormModel component,
    String? triggerIcon,
    String? triggerAvatar,
    String currentState,
  ) {
    // Exact same logic as original _computeStyles
    Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

    // Always apply variant with_icon if icon exists
    if ((triggerIcon != null || style['icon'] != null) &&
        component.variants != null &&
        component.variants!.containsKey('with_icon')) {
      final variantStyle =
          component.variants!['with_icon']['style'] as Map<String, dynamic>?;
      if (variantStyle != null) style.addAll(variantStyle);
    }

    // Apply variant with_avatar if avatar exists
    if (triggerAvatar != null &&
        component.variants != null &&
        component.variants!.containsKey('with_avatar')) {
      final variantStyle =
          component.variants!['with_avatar']['style'] as Map<String, dynamic>?;
      if (variantStyle != null) style.addAll(variantStyle);
    }

    // Apply state style if available
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    return style;
  }

  String? _computeDisplayLabel(
    Map<String, dynamic> config,
    String? value,
    List<dynamic> items,
  ) {
    // Exact same logic as original _computeDisplayLabel
    if (value == null || value.isEmpty) {
      return config['label'] ?? config['placeholder'] ?? 'Select an option';
    } else {
      final selectedItem = items.firstWhere(
        (item) => item['id'] == value && item['type'] != 'divider',
        orElse: () => null,
      );
      if (selectedItem != null) {
        return selectedItem['label'] as String? ?? value;
      } else {
        return value;
      }
    }
  }

  Widget _computeTriggerContent(
    String? displayLabel,
    String placeholder,
    String? triggerIcon,
    String? triggerAvatar,
    bool isSearchable,
    Map<String, dynamic> style,
    bool isDropdownOpen,
  ) {
    // Exact same logic as original _computeTriggerContent but with dropdown state
    if (isSearchable) {
      return Row(
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
      return Icon(
        _mapIconNameToIconData(triggerIcon),
        color: StyleUtils.parseColor(style['icon_color'] ?? '#000000'),
        size: (style['icon_size'] as num?)?.toDouble() ?? 24.0,
      );
    } else {
      return Row(
        children: [
          if (triggerIcon != null) ...[
            Icon(
              _mapIconNameToIconData(triggerIcon),
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
              displayLabel ?? placeholder,
              style: TextStyle(
                color: StyleUtils.parseColor(style['color'] ?? '#000000'),
              ),
            ),
          ),
          Icon(
            isDropdownOpen
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: StyleUtils.parseColor(style['color'] ?? '#000000'),
          ),
        ],
      );
    }
  }

  IconData? _mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  OverlayEntry _createOverlayEntry(
    Rect position,
    DynamicDropdownSuccess state,
    TextEditingController searchController,
    BuildContext context,
  ) {
    final dropdownWidth =
        (state.computedStyle['dropdown_width'] as num?)?.toDouble() ??
        position.width;

    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return BlocBuilder<DynamicDropdownBloc, DynamicDropdownState>(
          bloc: this,
          buildWhen: (previous, current) {
            return previous is DynamicDropdownSuccess &&
                current is DynamicDropdownSuccess &&
                (previous.searchQuery != current.searchQuery ||
                    previous.filteredItems.length !=
                        current.filteredItems.length);
          },
          builder: (context, dropdownState) {
            if (dropdownState is! DynamicDropdownSuccess) {
              return const SizedBox.shrink();
            }

            // Sync search controller with bloc state
            if (searchController.text != dropdownState.searchQuery) {
              searchController.text = dropdownState.searchQuery;
              searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: searchController.text.length),
              );
            }

            final filteredItems = dropdownState.filteredItems;

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      add(const CloseDropdownEvent());
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  top: position.bottom + 4,
                  left: position.left,
                  width: dropdownWidth,
                  child: Material(
                    elevation: 4.0,
                    color: StyleUtils.parseColor(
                      state.computedStyle['dropdown_background_color'],
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      state.computedStyle['border_radius'],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount:
                            filteredItems.length + (state.isSearchable ? 1 : 0),
                        separatorBuilder: (context, index) {
                          final itemIndex = state.isSearchable
                              ? index - 1
                              : index;
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
                              state.computedStyle['divider_color'],
                            ),
                            height: 1,
                          );
                        },
                        itemBuilder: (context, index) {
                          if (state.isSearchable && index == 0) {
                            return _buildSearchField(
                              state,
                              searchController,
                              filteredItems,
                            );
                          }

                          final item =
                              filteredItems[state.isSearchable
                                  ? index - 1
                                  : index];
                          return _buildDropdownItem(item, state);
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

    // Insert overlay immediately after creation
    Overlay.of(context).insert(overlayEntry);

    return overlayEntry;
  }

  Widget _buildSearchField(
    DynamicDropdownSuccess state,
    TextEditingController searchController,
    List<dynamic> filteredItems,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: TextField(
        controller: searchController,
        focusNode: state.searchFocusNode,
        decoration: InputDecoration(
          hintText: state.placeholder,
          isDense: true,
          suffixIcon: const Icon(Icons.search),
        ),
        onChanged: (value) {
          add(SearchQueryChangedEvent(query: value));
        },
        onSubmitted: (value) {
          String? selectedValue;
          if (filteredItems.isNotEmpty &&
              filteredItems.first['type'] != 'divider') {
            selectedValue = filteredItems.first['id'];
          } else if (value.isNotEmpty) {
            selectedValue = value;
          }

          if (selectedValue != null) {
            add(DropdownValueChangedEvent(value: selectedValue));
            debugPrint(
              '[Dropdown] ${state.component!.id} value updated: $selectedValue',
            );
          }
        },
      ),
    );
  }

  Widget _buildDropdownItem(
    dynamic item,
    DynamicDropdownSuccess state,
  ) {
    final itemType = item['type'] as String? ?? 'item';

    if (itemType == 'divider') {
      return Divider(
        color: StyleUtils.parseColor(
          state.computedStyle['divider_color'],
        ),
        height: 1,
      );
    }

    final label = item['label'] as String? ?? '';
    final value = item['id'] as String? ?? '';
    final iconName = item['icon'] as String?;
    final avatarUrl = item['avatar'] as String?;
    final itemStyle = item['style'] as Map<String, dynamic>? ?? {};

    return InkWell(
      onTap: () {
        add(DropdownValueChangedEvent(value: value));
        debugPrint(
          '[Dropdown] ${state.component!.id} value updated: $value',
        );
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
                _mapIconNameToIconData(iconName),
                color: StyleUtils.parseColor(
                  itemStyle['color'] ?? state.computedStyle['color'],
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
                    itemStyle['color'] ?? state.computedStyle['color'],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
