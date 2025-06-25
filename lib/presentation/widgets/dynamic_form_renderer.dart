import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_checkbox.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_date_time_range_picker.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_dropdown.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_file_uploader.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_radio.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_select.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_selector.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_slider.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_switch.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_area.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field.dart';
import 'package:dynamic_form_bi/presentation/widgets/components/dynamic_text_field_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

 // String? _errorText; // Only for TextFieldTags now
  late StringTagController<String> tagController;
  // Select input variables
  // String? _selectedValue;
  // List<String> _selectedValues = []; // For multiple selection
  // bool _isDropdownOpen = false;
  // bool _isTouched = false; // To track if the field has been interacted with
  // //bool _showSuggestions = false;
  // final Set<String> _selectedTags = {};
  // bool _showSuggestions = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize for TextFieldTags only
  //   _focusNode = FocusNode();
  //   _focusNode.addListener(_handleFocusChange);
  //   final value = widget.component.config['value'];
  //   final values = widget.component.config['values'];
  //
  //   if (value is String) {
  //     _controller.text = value;
  //   } else if (value is num) {
  //     _sliderValue = value.toDouble();
  //   } else {
  //     _controller.text = '';
  //   }
  //
  //   if (values is List) {
  //     _sliderRangeValues = RangeValues(
  //       values[0].toDouble(),
  //       values[1].toDouble(),
  //     );
  //   }
  //
  //   _currentDropdownLabel = widget.component.config['label'];
  //   tagController = StringTagController<String>();
  //   final initialTags =
  //       (widget.component.config['initialTags'] as List<dynamic>?)
  //           ?.cast<String>() ??
  //       [];
  //   for (var tag in initialTags) {
  //     tagController.addTag(tag);
  //   }
  //   _selectedTags.addAll(initialTags);
  // }

  @override
  void dispose() {
    // Dispose of TextFieldTags controller if necessary
    super.dispose();
  }

  // void _handleFocusChange() {
  //   setState(() {});
  //   debugPrint(
  //     'FocusNode changed for component ${widget.component.id}: hasFocus=${_focusNode.hasFocus}, value=${_controller.text}',
  //   );
  // }

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
      case FormTypeEnum.dateTimeRangePickerFormType:
        return DynamicDateTimeRangePicker(
          component: component,
          onComplete: (value) {
          },
        );
      case FormTypeEnum.dropdownFormType:
        return DynamicDropdown(component: component);
      case FormTypeEnum.checkboxGroupFormType:
        // CheckboxGroup still needs to iterate children, so it stays here for now
        //return _buildCheckboxGroup(component);
      case FormTypeEnum.checkboxFormType:
        return DynamicCheckbox(component: component);
      case FormTypeEnum.radioFormType:
        return DynamicRadio(component: component);
      case FormTypeEnum.radioGroupFormType:
        // RadioGroup still needs to iterate children and manage group state, so it stays here for now
        //return _buildRadioGroup(component);
      case FormTypeEnum.sliderFormType:
        return DynamicSlider(component: component);
      case FormTypeEnum.selectorFormType:
        //return _buildSelector(component);
        return DynamicSelector(
          component: component,
          onComplete: (value) {
          },
        );
      case FormTypeEnum.switchFormType:
        return DynamicSwitch(
          component: component,
          onComplete: (value) {
          },
        );
      case FormTypeEnum.textFieldTagsFormType:
        return DynamicTextFieldTags(
          component: component,
          onComplete: (value) {
          },
        );
      case FormTypeEnum.fileUploaderFormType:
        return DynamicFileUploader(component: component);
      case FormTypeEnum.buttonFormType:
        return const SizedBox.shrink();
      case FormTypeEnum.unknown:
        return const SizedBox.shrink();
    }
  }






  // Widget _buildDefaultFormType() {
  //   final component = widget.component;
  //   final layout = component.config['layout']?.toString().toLowerCase() ?? 'column';
  //   final childrenWidgets =
  //       component.children
  //           ?.map(
  //             (child) => Padding(
  //               padding: StyleUtils.parsePadding(child.style['margin']),
  //               child: DynamicFormRenderer(component: child),
  //             ),
  //           )
  //           .toList() ??
  //       [];
  //
  //   return Container(
  //     key: Key(component.id),
  //     padding: StyleUtils.parsePadding(component.style['padding']),
  //     margin: StyleUtils.parsePadding(component.style['margin']),
  //     decoration: StyleUtils.buildBoxDecoration(component.style),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         if (component.config['label'] != null)
  //           Padding(
  //             padding: const EdgeInsets.only(bottom: 12),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Container(
  //                   width: 4,
  //                   height: 28,
  //                   color: const Color(0xFF6979F8),
  //                   margin: const EdgeInsets.only(right: 8),
  //                 ),
  //                 Text(
  //                   component.config['label'],
  //                   style: const TextStyle(
  //                     color: Color(0xFF6979F8),
  //                     fontSize: 24,
  //                     fontStyle: FontStyle.italic,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         if (component.children != null && childrenWidgets.isNotEmpty)
  //           layout == 'row'
  //               ? SingleChildScrollView(
  //                   scrollDirection: Axis.horizontal,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: childrenWidgets,
  //                   ),
  //                 )
  //               : Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: childrenWidgets,
  //                 ),
  //       ],
  //     ),
  //               : Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: childrenWidgets,
  //                 ),
  //       ],
  //     ),
  //   );
  // }




//   void showDropdownPanel(
//     BuildContext context,
//     DynamicFormModel component,
//     Rect rect,
//   ) {
//     final items = component.config['items'] as List<dynamic>? ?? [];
//     final style = component.style;
//     final isSearchable = component.config['searchable'] as bool? ?? false;
//     final dropdownWidth =
//         (style['dropdownWidth'] as num?)?.toDouble() ?? rect.width;
//
//     OverlayEntry? overlayEntry;
//     overlayEntry = OverlayEntry(
//       builder: (context) {
//         List<dynamic> filteredItems = List.from(items);
//         String searchQuery = '';
//         final searchController = TextEditingController();
//
//         return StatefulBuilder(
//           builder: (context, setPanelState) {
//             return Stack(
//               children: [
//                 // Full screen GestureDetector to dismiss the dropdown.
//                 Positioned.fill(
//                   child: GestureDetector(
//                     onTap: () => overlayEntry?.remove(),
//                     child: Container(color: Colors.transparent),
//                   ),
//                 ),
//                 // The dropdown panel itself.
//                 Positioned(
//                   top: rect.top,
//                   left: rect.left,
//                   width: dropdownWidth,
//                   child: Material(
//                     elevation: 4.0,
//                     color: StyleUtils.parseColor(
//                       style['dropdownBackgroundColor'],
//                     ),
//                     borderRadius: StyleUtils.parseBorderRadius(
//                       style['borderRadius'],
//                     ),
//                     child: ListView.separated(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       shrinkWrap: true,
//                       itemCount: filteredItems.length + (isSearchable ? 1 : 0),
//                       separatorBuilder: (context, index) {
//                         // This logic handles separators for both searchable and non-searchable lists.
//                         final itemIndex = isSearchable ? index - 1 : index;
//                         if (itemIndex < 0 ||
//                             itemIndex >= filteredItems.length) {
//                           return const SizedBox.shrink();
//                         }
//                         final item = filteredItems[itemIndex];
//                         final nextItem = (itemIndex + 1 < filteredItems.length)
//                             ? filteredItems[itemIndex + 1]
//                             : null;
//                         if (item['type'] == 'divider' ||
//                             nextItem?['type'] == 'divider') {
//                           return const SizedBox.shrink();
//                         }
//                         return const Divider(
//                           color: Colors.transparent,
//                           height: 1,
//                         );
//                       },
//                       itemBuilder: (context, index) {
//                         if (isSearchable && index == 0) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0,
//                               vertical: 8.0,
//                             ),
//                             child: TextField(
//                               controller: searchController,
//                               decoration: InputDecoration(
//                                 hintText: component.config['placeholder'],
//                                 isDense: true,
//                                 suffixIcon: const Icon(Icons.search),
//                               ),
//                               onChanged: (value) {
//                                 setPanelState(() {
//                                   searchQuery = value.toLowerCase();
//                                   filteredItems = items.where((item) {
//                                     final label =
//                                         item['label']
//                                             ?.toString()
//                                             .toLowerCase() ??
//                                         '';
//                                     if (item['type'] == 'divider') return true;
//                                     return label.contains(searchQuery);
//                                   }).toList();
//                                 });
//                               },
//                             ),
//                           );
//                         }
//
//                         final item =
//                             filteredItems[isSearchable ? index - 1 : index];
//                         final itemType = item['type'] as String? ?? 'item';
//
//                         if (itemType == 'divider') {
//                           return Divider(
//                             color: StyleUtils.parseColor(style['dividerColor']),
//                             height: 1,
//                           );
//                         }
//
//                         final label = item['label'] as String? ?? '';
//                         final iconName = item['icon'] as String?;
//                         final avatarUrl = item['avatar'] as String?;
//                         final itemStyle =
//                             item['style'] as Map<String, dynamic>? ?? {};
//
//                         return InkWell(
//                           onTap: () {
//                             // Log the tapped action
//                             debugPrint(
//                               "Dropdown Action Tapped: ID='${item['id']}', Label='${item['label']}'",
//                             );
//
//                             setState(() {
//                               _isTouched = true;
//                               _selectedActionId = item['id'];
//                               _dropdownErrorText = _validateDropdown(
//                                 component,
//                                 _selectedActionId,
//                               );
//
//                               // Update trigger label unless it's a special display type
//                               final bool isIconOnly =
//                                   component.config['icon'] != null &&
//                                   component.config['label'] == null;
//                               final bool hasAvatar =
//                                   component.config['avatar'] != null;
//                               final items =
//                                   component.config['items'] as List<dynamic>? ??
//                                   [];
//                               final selectedItem = items.firstWhere(
//                                 (i) => i['id'] == _selectedActionId,
//                                 orElse: () => null,
//                               );
//
//                               if (!isIconOnly &&
//                                   !hasAvatar &&
//                                   selectedItem != null) {
//                                 _currentDropdownLabel = selectedItem['label'];
//                               }
//                             });
//                             overlayEntry?.remove();
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16.0,
//                               vertical: 12.0,
//                             ),
//                             child: Row(
//                               children: [
//                                 if (avatarUrl != null) ...[
//                                   CircleAvatar(
//                                     backgroundImage: NetworkImage(avatarUrl),
//                                     radius: 16,
//                                   ),
//                                   const SizedBox(width: 12),
//                                 ] else if (iconName != null) ...[
//                                   Icon(
//                                     mapIconNameToIconData(iconName),
//                                     color: StyleUtils.parseColor(
//                                       itemStyle['color'] ?? style['color'],
//                                     ),
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 12),
//                                 ],
//                                 Expanded(
//                                   child: Text(
//                                     label,
//                                     style: TextStyle(
//                                       color: StyleUtils.parseColor(
//                                         itemStyle['color'] ?? style['color'],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildCheckboxGroup(DynamicFormModel component) {
//     final layout =
//         component.config['layout']?.toString().toLowerCase() ?? 'row';
//     final groupStyle = Map<String, dynamic>.from(component.style);
//     final children = component.children ?? [];
//
//     final widgets = children.map((item) {
//       final style = {...groupStyle, ...item.style};
//       final isSelected = item.config['value'] == true;
//       final isEditable = item.config['editable'] != false;
//       final label = item.config['label'] as String?;
//       final hint = item.config['hint'] as String?;
//       final iconName = item.config['icon'] as String?;
//
//       Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
//       Color borderColor = StyleUtils.parseColor(style['borderColor']);
//       double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 8;
//       Color iconColor = StyleUtils.parseColor(style['iconColor']);
//       double width = (style['width'] as num?)?.toDouble() ?? 40;
//       double height = (style['height'] as num?)?.toDouble() ?? 40;
//       EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);
//
//       // Increase border width if selected to give visual feedback
//       if (isSelected) {
//         borderColor = StyleUtils.parseColor(style['selectedBorderColor']);
//       }
//
//       // Disabled style
//       if (!isEditable) {
//         bgColor = StyleUtils.parseColor('#e0e0e0');
//         borderColor = StyleUtils.parseColor('#e0e0e0');
//         iconColor = StyleUtils.parseColor('#bdbdbd');
//       }
//
//       Widget? iconWidget;
//       if (iconName != null) {
//         final iconData = mapIconNameToIconData(iconName);
//         if (iconData != null) {
//           iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
//         }
//       }
//
//       return InkWell(
//         borderRadius: BorderRadius.circular(borderRadius),
//         onTap: isEditable
//             ? () {
//           setState(() {
//             item.config['value'] = !isSelected;
//           });
//           // Notify BLoC about the change
//           context.read<DynamicFormBloc>().add(
//             UpdateFormField(
//               componentId: item.id,
//               value: item.config['value'],
//             ),
//           );
//         }
//             : null,
//         child: Container(
//           margin: margin,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: width,
//                 height: height,
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   border: Border.all(color: borderColor, width: 2), // Luôn luôn có border
//                   borderRadius: BorderRadius.circular(borderRadius),
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     if (iconWidget != null) iconWidget, // Custom icon always visible
//                     if (isSelected)
//                       Icon(
//                         // Overlay checkmark
//                         Icons.check,
//                         color: iconColor,
//                         size: width * 0.6,
//                       ),
//                   ],
//                 ),
//               ),
//               if (label != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     label,
//                     style: TextStyle(
//                       color: isEditable ? Colors.white : Colors.grey,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               if (hint != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 2),
//                   child: Text(
//                     hint,
//                     style: const TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//
//     return Container(
//         margin: StyleUtils.parsePadding(groupStyle['margin']),
//         padding: StyleUtils.parsePadding(groupStyle['padding']),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (component.config['label'] != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 28,
//                         color: const Color(0xFF6979F8),
//                         margin: const EdgeInsets.only(right: 8),
//                       ),
//                       Text(
//                         component.config['label'],
//                         style: const TextStyle(
//                           color: Color(0xFF6979F8),
//                           fontSize: 24,
//                           fontStyle: FontStyle.italic,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
// //           if (component.config['hint'] != null)
// //             Padding(
// //               padding: const EdgeInsets.only(left: 12, bottom: 8),
// //               child: Text(
// //                 component.config['hint'],
// //                 style: const TextStyle(
// //                   color: Colors.grey,
// //                   fontSize: 13,
// //                   fontStyle: FontStyle.italic,
// //                 ),
// //               ),
// //             ),
// //           layout == 'row'
// //               ? SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Row(children: widgets),
// //                 )
// //               : Column(children: widgets),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildRadioGroup(DynamicFormModel component) {
// //     final layout = component.config['layout']?.toString().toLowerCase() ?? 'row';
// //     final groupStyle = Map<String, dynamic>.from(component.style);
// //     final children = component.children ?? [];
// //     // Tìm group name
// //     final groupName = component.config['group'] as String? ?? component.id;
// //
// //     final widgets = children.map((item) {
// //       final style = {...groupStyle, ...item.style};
// //       final isSelected = item.config['value'] == true;
// //       final isEditable = item.config['editable'] != false;
// //       final label = item.config['label'] as String?;
// //       final hint = item.config['hint'] as String?;
// //       final iconName = item.config['icon'] as String?;
// //       final itemGroup = item.config['group'] as String? ?? groupName;
// //
// //       Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
// //       Color borderColor = StyleUtils.parseColor(style['borderColor']);
// //       double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 20;
// //       double borderWidth = (style['borderWidth'] as num?)?.toDouble() ?? 2;
// //       Color iconColor = StyleUtils.parseColor(style['iconColor']);
// //       double width = (style['width'] as num?)?.toDouble() ?? 40;
// //       double height = (style['height'] as num?)?.toDouble() ?? 40;
// //       EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);
// //
// //       // Increase border width if selected to give visual feedback
// //       if (isSelected) {
// //         borderWidth += 2;
// //       }
// //
// //       // Disabled style
// //       if (!isEditable) {
// //         bgColor = StyleUtils.parseColor('#e0e0e0');
// //         borderColor = StyleUtils.parseColor('#e0e0e0');
// //         iconColor = StyleUtils.parseColor('#bdbdbd');
// //       }
// //
// //       Widget? iconWidget;
// //       if (iconName != null) {
// //         final iconData = mapIconNameToIconData(iconName);
// //         if (iconData != null) {
// //           iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
// //         }
// //       }
// //
// //       return InkWell(
// //         borderRadius: BorderRadius.circular(borderRadius),
// //         onTap: isEditable
// //             ? () {
// //                 // When a radio button in a group is tapped,
// //                 // send an event to the BLoC to update the selection for the entire group.
// //                 context.read<DynamicFormBloc>().add(
// //                   UpdateFormField(componentId: item.id, value: true),
// //                 );
// //               }
// //             : null,
// //         child: Container(
// //           margin: margin,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 width: width,
// //                 height: height,
// //                 decoration: BoxDecoration(
// //                   color: bgColor,
// //                   border: Border.all(color: borderColor, width: borderWidth),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Center(
// //                   child:
// //                       iconWidget ??
// //                       (isSelected
// //                           ? Container(
// //                               width: width * 0.5,
// //                               height: height * 0.5,
// //                               decoration: BoxDecoration(
// //                                 color: iconColor,
// //                                 shape: BoxShape.circle,
// //                               ),
// //                             )
// //                           : null),
// //                 ),
// //               ),
// //               if (label != null)
// //                 Padding(
// //                   padding: const EdgeInsets.only(top: 4),
// //                   child: Text(
// //                     label,
// //                     style: TextStyle(
// //                       color: isEditable ? Colors.white : Colors.grey,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               if (hint != null)
// //                 Padding(
// //                   padding: const EdgeInsets.only(top: 2),
// //                   child: Text(
// //                     hint,
// //                     style: const TextStyle(
// //                       color: Colors.grey,
// //                       fontSize: 12,
// //                       fontStyle: FontStyle.italic,
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }).toList();
// //
// //     return Container(
// //       margin: StyleUtils.parsePadding(groupStyle['margin']),
// //       padding: StyleUtils.parsePadding(groupStyle['padding']),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           if (component.config['label'] != null)
// //             Padding(
// //               padding: const EdgeInsets.only(bottom: 4),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 4,
// //                     height: 28,
// //                     color: const Color(0xFF6979F8),
// //                     margin: const EdgeInsets.only(right: 8),
// //                   ),
// //                   Text(
// //                     component.config['label'],
// //                     style: const TextStyle(
// //                       color: Color(0xFF6979F8),
// //                       fontSize: 24,
// //                       fontStyle: FontStyle.italic,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           if (component.config['hint'] != null)
// //             Padding(
// //               padding: const EdgeInsets.only(left: 12, bottom: 8),
// //               child: Text(
// //                 component.config['hint'],
// //                 style: const TextStyle(
// //                   color: Colors.grey,
// //                   fontSize: 13,
// //                   fontStyle: FontStyle.italic,
// //                 ),
// //               ),
// //             ),
// //           layout == 'row'
// //               ? SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Row(children: widgets),
// //                 )
// //               : Column(children: widgets),
// //         ],
// //       ),
// //     );
// //   }
// // }
//             ]
//         )
//     );
//   }
}