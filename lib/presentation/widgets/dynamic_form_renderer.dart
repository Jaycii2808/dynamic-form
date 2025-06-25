import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_area.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_checkbox.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_dropdown.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_file_uploader.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_radio.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_select.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:textfield_tags/textfield_tags.dart';

// Updated to use enum
IconData? mapIconNameToIconData(String name) {
  return IconTypeEnum.fromString(name).toIconData();
}

class DynamicFormRenderer extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicFormRenderer({super.key, required this.component});

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  // Removed local state related to TextField, Select, Dropdown, Slider, FileUploader
  // These states are now managed within their respective widgets.

  String? _errorText; // Only for TextFieldTags now
  late StringTagController<String> tagController;
  final Set<String> _selectedTags = {};
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Initialize for TextFieldTags only
    tagController = StringTagController<String>();
    final initialTags =
        (widget.component.config['initialTags'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    for (var tag in initialTags) {
      tagController.addTag(tag);
    }
    _selectedTags.addAll(initialTags);
  }

  @override
  void dispose() {
    // Dispose of TextFieldTags controller if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // You might still want to listen to state changes if the renderer
        // needs to react to global form state, e.g., validation results for all fields.
      },
      builder: (context, state) {
        return buildForm();
      },
    );
  }

  Widget buildForm() {
    final component = widget.component;
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return DynamicTextField(
          component: component,
          onComplete: (value) {
            context.read<DynamicFormBloc>().add(
              UpdateFormField(componentId: component.id, value: value),
            );
          },
        );
      case FormTypeEnum.selectFormType:
        return DynamicSelect(component: component);
      case FormTypeEnum.textAreaFormType:
        return DynamicTextArea(
          component: component,
          onComplete: (value) {
            context.read<DynamicFormBloc>().add(
              UpdateFormField(componentId: component.id, value: value),
            );
          },
        );
      case FormTypeEnum.dateTimePickerFormType:
        return DynamicDateTimePicker(
          component: component,
          onComplete: (value) {
            context.read<DynamicFormBloc>().add(
              UpdateFormField(componentId: component.id, value: value),
            );
          },
        );
      case FormTypeEnum.dropdownFormType:
        return DynamicDropdown(component: component);
      case FormTypeEnum.checkboxGroupFormType:
        // CheckboxGroup still needs to iterate children, so it stays here for now
        return _buildCheckboxGroup(component);
      case FormTypeEnum.checkboxFormType:
        return DynamicCheckbox(component: component);
      case FormTypeEnum.radioFormType:
        return DynamicRadio(component: component);
      case FormTypeEnum.radioGroupFormType:
        // RadioGroup still needs to iterate children and manage group state, so it stays here for now
        return _buildRadioGroup(component);
      case FormTypeEnum.sliderFormType:
        return DynamicSlider(component: component);
      case FormTypeEnum.selectorFormType:
        return _buildSelector(component);
      case FormTypeEnum.switchFormType:
        return _buildSwitch(component);
      case FormTypeEnum.textFieldTagsFormType:
        return _buildTextFieldTags(component);
      case FormTypeEnum.fileUploaderFormType:
        return DynamicFileUploader(component: component);
      case FormTypeEnum.buttonFormType:
        return SizedBox.shrink();
      case FormTypeEnum.unknown:
        return _buildDefaultFormType();
    }
  }

  Widget _buildTextFieldTags(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final initialTags =
        (config['initialTags'] as List<dynamic>?)?.cast<String>() ?? [];
    final placeholder = config['placeholder'] ?? 'Enter tags...';

    debugPrint('TextFieldTags: Initial tags are $initialTags');
    debugPrint('TextFieldTags: Selected tags are ${_selectedTags.toList()}');

    // Determine current state
    String currentState = 'base';
    if (_selectedTags.isNotEmpty) currentState = 'success';
    if (_errorText != null) currentState = 'error';
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    if (_showSuggestions) {
      return Container(
        key: Key(component.id),
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
                        border: Border.all(
                          color: StyleUtils.parseColor('#CDD2FD'),
                          width: 10.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
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
                                debugPrint(
                                  'Removed: Tag $tag removed from ${component.id}',
                                );
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
                debugPrint(
                  'Autocomplete: Filtering options for input ${textEditingValue.text}',
                );
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
                debugPrint('Autocomplete: Selected tag $selection');
                if (!_selectedTags.contains(selection)) {
                  setState(() {
                    _selectedTags.add(selection);
                    _errorText = null;
                    debugPrint(
                      'TagAdded: Successfully added tag $selection via autocomplete',
                    );
                  });
                }
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onSubmitted: (value) {
                        debugPrint('OnSubmitted: Submitted value $value');
                        if (value.isNotEmpty &&
                            initialTags.contains(value.trim()) &&
                            !_selectedTags.contains(value.trim())) {
                          textEditingController.clear();
                          setState(() {
                            _selectedTags.add(value.trim());
                            _errorText = null;
                            debugPrint(
                              'TagAdded: Successfully added tag $value',
                            );
                          });
                        } else if (_selectedTags.contains(value.trim())) {
                          setState(() {
                            _errorText = 'Tag already selected';
                            debugPrint(
                              'TagRejected: $value is already selected',
                            );
                          });
                        } else {
                          setState(() {
                            _errorText = 'Tag must match predefined list';
                            debugPrint(
                              'TagRejected: $value does not match predefined tags',
                            );
                          });
                        }
                      },
                      onChanged: (value) {
                        debugPrint('OnChanged: Input changed to $value');
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
                        fillColor: StyleUtils.parseColor(
                          style['backgroundColor'],
                        ),
                        errorText: _errorText,
                      ),
                      style: TextStyle(
                        fontSize: style['fontSize']?.toDouble() ?? 16,
                        color: StyleUtils.parseColor(
                          style['color'] ?? '#000000',
                        ),
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
            debugPrint('Tap: Showing suggestions for ${component.id}');
          });
        },
        child: Container(
          key: Key(component.id),
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
                        border: Border.all(
                          color: StyleUtils.parseColor('#CDD2FD'),
                          width: 10.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
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
                                debugPrint(
                                  'Removed: Tag $tag removed from ${component.id}',
                                );
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

  Widget _buildSwitch(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final selected = config['selected'] ?? false;

    // Apply variant styles
    if (component.variants != null) {
      if (hasLabel && component.variants!.containsKey('withLabel')) {
        final variantStyle =
            component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (!hasLabel && component.variants!.containsKey('withoutLabel')) {
        final variantStyle =
            component.variants!['withoutLabel']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    if (selected) currentState = 'success';

    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Switch colors
    final activeColor = StyleUtils.parseColor(
      style['activeColor'] ?? '#6979F8',
    );
    final inactiveThumbColor = StyleUtils.parseColor(
      style['inactiveThumbColor'] ?? '#CCCCCC',
    );
    final inactiveTrackColor = StyleUtils.parseColor(
      style['inactiveTrackColor'] ?? '#E5E5E5',
    );

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: selected,
            onChanged: (bool value) {
              setState(() {
                component.config['selected'] = value;
              });
              // Notify BLoC about the change
              context.read<DynamicFormBloc>().add(
                UpdateFormField(componentId: component.id, value: value),
              );
            },
            activeColor: activeColor,
            inactiveThumbColor: inactiveThumbColor,
            inactiveTrackColor: inactiveTrackColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (hasLabel)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                config['label'],
                style: TextStyle(
                  fontSize: style['labelTextSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(
                    style['labelColor'] ?? '#6979F8',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelector(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final selected = config['selected'] ?? false;

    // Apply variant styles
    if (component.variants != null) {
      if (hasLabel && component.variants!.containsKey('withLabel')) {
        final variantStyle =
            component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (!hasLabel && component.variants!.containsKey('withoutLabel')) {
        final variantStyle =
            component.variants!['withoutLabel']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    if (selected) currentState = 'success';

    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: GestureDetector(
        onTap: () {
          setState(() {
            component.config['selected'] = !selected;
          });
          // Notify BLoC about the change
          context.read<DynamicFormBloc>().add(
            UpdateFormField(
              componentId: component.id,
              value: component.config['selected'],
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selected ? 'assets/svg/Active.svg' : 'assets/svg/Inactive.svg',
              width: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
              height: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
            ),
            if (hasLabel)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  config['label'],
                  style: TextStyle(
                    fontSize: style['labelTextSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['labelColor']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFormType() {
    final component = widget.component;
    final layout =
        component.config['layout']?.toString().toLowerCase() ?? 'column';
    final childrenWidgets =
        component.children
            ?.map(
              (child) => Padding(
                padding: StyleUtils.parsePadding(child.style['margin']),
                child: DynamicFormRenderer(component: child),
              ),
            )
            .toList() ??
        [];

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      decoration: StyleUtils.buildBoxDecoration(component.style),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.children != null && childrenWidgets.isNotEmpty)
            layout == 'row'
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: childrenWidgets,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: childrenWidgets,
                  ),
        ],
      ),
    );
  }

  Widget _buildCheckboxGroup(DynamicFormModel component) {
    final layout =
        component.config['layout']?.toString().toLowerCase() ?? 'row';
    final groupStyle = Map<String, dynamic>.from(component.style);
    final children = component.children ?? [];

    final widgets = children.map((item) {
      final style = {...groupStyle, ...item.style};
      final isSelected = item.config['value'] == true;
      final isEditable = item.config['editable'] != false;
      final label = item.config['label'] as String?;
      final hint = item.config['hint'] as String?;
      final iconName = item.config['icon'] as String?;

      Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
      Color borderColor = StyleUtils.parseColor(style['borderColor']);
      double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 8;
      Color iconColor = StyleUtils.parseColor(style['iconColor']);
      double width = (style['width'] as num?)?.toDouble() ?? 40;
      double height = (style['height'] as num?)?.toDouble() ?? 40;
      EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);

      // Increase border width if selected to give visual feedback
      if (isSelected) {
        borderColor = StyleUtils.parseColor(style['selectedBorderColor']);
      }

      // Disabled style
      if (!isEditable) {
        bgColor = StyleUtils.parseColor('#e0e0e0');
        borderColor = StyleUtils.parseColor('#e0e0e0');
        iconColor = StyleUtils.parseColor('#bdbdbd');
      }

      Widget? iconWidget;
      if (iconName != null) {
        final iconData = mapIconNameToIconData(iconName);
        if (iconData != null) {
          iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
        }
      }

      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEditable
            ? () {
                setState(() {
                  item.config['value'] = !isSelected;
                });
                // Notify BLoC about the change
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(
                    componentId: item.id,
                    value: item.config['value'],
                  ),
                );
              }
            : null,
        child: Container(
          margin: margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ), // Luôn luôn có border
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (iconWidget != null)
                      iconWidget, // Custom icon always visible
                    if (isSelected)
                      Icon(
                        // Overlay checkmark
                        Icons.check,
                        color: iconColor,
                        size: width * 0.6,
                      ),
                  ],
                ),
              ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isEditable ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      margin: StyleUtils.parsePadding(groupStyle['margin']),
      padding: StyleUtils.parsePadding(groupStyle['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.config['hint'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                component.config['hint'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          layout == 'row'
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: widgets),
                )
              : Column(children: widgets),
        ],
      ),
    );
  }

  Widget _buildRadioGroup(DynamicFormModel component) {
    final layout =
        component.config['layout']?.toString().toLowerCase() ?? 'row';
    final groupStyle = Map<String, dynamic>.from(component.style);
    final children = component.children ?? [];
    // Tìm group name
    final groupName = component.config['group'] as String? ?? component.id;

    final widgets = children.map((item) {
      final style = {...groupStyle, ...item.style};
      final isSelected = item.config['value'] == true;
      final isEditable = item.config['editable'] != false;
      final label = item.config['label'] as String?;
      final hint = item.config['hint'] as String?;
      final iconName = item.config['icon'] as String?;
      final itemGroup = item.config['group'] as String? ?? groupName;

      Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
      Color borderColor = StyleUtils.parseColor(style['borderColor']);
      double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 20;
      double borderWidth = (style['borderWidth'] as num?)?.toDouble() ?? 2;
      Color iconColor = StyleUtils.parseColor(style['iconColor']);
      double width = (style['width'] as num?)?.toDouble() ?? 40;
      double height = (style['height'] as num?)?.toDouble() ?? 40;
      EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);

      // Increase border width if selected to give visual feedback
      if (isSelected) {
        borderWidth += 2;
      }

      // Disabled style
      if (!isEditable) {
        bgColor = StyleUtils.parseColor('#e0e0e0');
        borderColor = StyleUtils.parseColor('#e0e0e0');
        iconColor = StyleUtils.parseColor('#bdbdbd');
      }

      Widget? iconWidget;
      if (iconName != null) {
        final iconData = mapIconNameToIconData(iconName);
        if (iconData != null) {
          iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
        }
      }

      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEditable
            ? () {
                // When a radio button in a group is tapped,
                // send an event to the BLoC to update the selection for the entire group.
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(componentId: item.id, value: true),
                );
              }
            : null,
        child: Container(
          margin: margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: borderWidth),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      iconWidget ??
                      (isSelected
                          ? Container(
                              width: width * 0.5,
                              height: height * 0.5,
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null),
                ),
              ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isEditable ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      margin: StyleUtils.parsePadding(groupStyle['margin']),
      padding: StyleUtils.parsePadding(groupStyle['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.config['hint'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                component.config['hint'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          layout == 'row'
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: widgets),
                )
              : Column(children: widgets),
        ],
      ),
    );
  }
}
