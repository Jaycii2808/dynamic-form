import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';

class DynamicRadio extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicRadio({super.key, required this.component});

  @override
  State<DynamicRadio> createState() => _DynamicRadioState();
}

class _DynamicRadioState extends State<DynamicRadio> {
  // Common utility function for mapping icon names to IconData
  IconData? _mapIconNameToIconData(String name) {
    switch (name) {
      case 'mail':
        return Icons.mail;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'error':
        return Icons.error;
      case 'user':
        return Icons.person;
      case 'lock':
        return Icons.lock;
      case 'chevron-down':
        return Icons.keyboard_arrow_down;
      case 'chevron-up':
        return Icons.keyboard_arrow_up;
      case 'globe':
        return Icons.language;
      case 'heart':
        return Icons.favorite;
      case 'search':
        return Icons.search;
      case 'location':
        return Icons.location_on;
      case 'calendar':
        return Icons.calendar_today;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_cart;
      case 'food':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports_soccer;
      case 'movie':
        return Icons.movie;
      case 'book':
        return Icons.book;
      case 'car':
        return Icons.directions_car;
      case 'plane':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'bike':
        return Icons.directions_bike;
      case 'walk':
        return Icons.directions_walk;
      case 'settings':
        return Icons.settings;
      case 'logout':
        return Icons.logout;
      case 'bell':
        return Icons.notifications;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'share':
        return Icons.share;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve styles from component's style and states
    Map<String, dynamic> style = Map<String, dynamic>.from(
      widget.component.style,
    );
    final bool isSelected = widget.component.config['value'] == true;
    final bool isEditable = widget.component.config['editable'] != false;

    // Apply state-specific styles
    String currentState = isSelected ? 'selected' : 'base';
    if (!isEditable) {
      // For disabled items, we don't use states, we just use the styles defined directly on the component.
    } else if (widget.component.states != null &&
        widget.component.states!.containsKey(currentState)) {
      final stateStyle =
          widget.component.states![currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) {
        style.addAll(stateStyle);
      }
    }

    // 2. Extract configuration
    final String? label = widget.component.config['label'];
    final String? hint = widget.component.config['hint'];
    final String? iconName = widget.component.config['icon'];
    final IconData? leadingIconData = iconName != null
        ? _mapIconNameToIconData(iconName)
        : null;
    final String? group = widget.component.config['group'];

    // 3. Define visual properties based on style
    final Color backgroundColor = StyleUtils.parseColor(
      style['backgroundColor'],
    );
    final Color borderColor = StyleUtils.parseColor(style['borderColor']);
    final double borderWidth =
        (style['borderWidth'] as num?)?.toDouble() ?? 1.0;
    final Color iconColor = StyleUtils.parseColor(style['iconColor']);
    final double controlWidth = (style['width'] as num?)?.toDouble() ?? 28;
    final double controlHeight = (style['height'] as num?)?.toDouble() ?? 28;

    final controlBorderRadius = controlWidth / 2; // Always circular for radio

    // 4. Build the toggle control (the radio button itself)
    Widget toggleControl = Container(
      width: controlWidth,
      height: controlHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(controlBorderRadius),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: controlWidth * 0.5,
                height: controlHeight * 0.5,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );

    // 5. Build the label and hint text column
    Widget? labelAndHint;
    if (label != null) {
      labelAndHint = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: style['labelTextSize']?.toDouble() ?? 16,
                color: StyleUtils.parseColor(style['labelColor']),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: StyleUtils.parseColor(style['hintColor']),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
    }

    // 6. Handle tap gestures
    void handleTap() {
      if (!isEditable) return;

      // Logic to unselect other radios in the same group
      if (group != null) {
        // Find all siblings in the same group and unselect them
        context.read<DynamicFormBloc>().add(
          UpdateFormField(componentId: widget.component.id, value: true),
        );
      } else {
        // If no explicit group, treat it as a single radio button (not common)
        setState(() {
          widget.component.config['value'] = true;
        });
        context.read<DynamicFormBloc>().add(
          UpdateFormField(componentId: widget.component.id, value: true),
        );
      }
    }

    // 7. Assemble the final widget
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        key: Key(widget.component.id), // Added Key for consistency
        margin: StyleUtils.parsePadding(style['margin']),
        padding: StyleUtils.parsePadding(style['padding']),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            toggleControl,
            const SizedBox(width: 12),
            if (leadingIconData != null) ...[
              Icon(
                leadingIconData,
                size: 20,
                color: StyleUtils.parseColor(style['iconColor']),
              ),
              const SizedBox(width: 8),
            ],
            if (labelAndHint != null) labelAndHint,
          ],
        ),
      ),
    );
  }
}
