import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';

class DynamicCheckbox extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicCheckbox({super.key, required this.component});

  @override
  State<DynamicCheckbox> createState() => _DynamicCheckboxState();
}

class _DynamicCheckboxState extends State<DynamicCheckbox> {
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
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        // Lấy component mới nhất từ state (theo id)
        final component =
            (state is DynamicFormState && state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        final bool isSelected = component.config['value'] == true;
        final bool isEditable = component.config['editable'] != false;
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        String currentState = isSelected ? 'selected' : 'base';
        if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }

        final String? label = component.config['label'];
        final String? hint = component.config['hint'];
        final String? iconName = component.config['icon'];
        final IconData? leadingIconData = iconName != null
            ? _mapIconNameToIconData(iconName)
            : null;

        final Color backgroundColor = StyleUtils.parseColor(
          style['backgroundColor'],
        );
        final Color borderColor = StyleUtils.parseColor(style['borderColor']);
        final double borderWidth =
            (style['borderWidth'] as num?)?.toDouble() ?? 1.0;
        final Color iconColor = StyleUtils.parseColor(style['iconColor']);
        final double controlWidth = (style['width'] as num?)?.toDouble() ?? 28;
        final double controlHeight =
            (style['height'] as num?)?.toDouble() ?? 28;
        final controlBorderRadius = (StyleUtils.parseBorderRadius(
          style['borderRadius'],
        ).resolve(TextDirection.ltr).topLeft.x);

        debugPrint(
          '[Checkbox][build] id=${component.id} value=$isSelected state=$currentState',
        );
        debugPrint('[Checkbox][build] style=${style.toString()}');
        debugPrint(
          '[Checkbox][build] iconColor=$iconColor, backgroundColor=$backgroundColor, borderColor=$borderColor',
        );

        Widget toggleControl = Container(
          width: controlWidth,
          height: controlHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(controlBorderRadius),
          ),
          child: isSelected
              ? Icon(Icons.check, color: iconColor, size: controlWidth * 0.75)
              : null,
        );

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

        void handleTap() {
          if (!isEditable) return;
          debugPrint(
            '[Checkbox][tap] id=${component.id} value_before=$isSelected',
          );
          final newValue = !isSelected;
          // Không update trực tiếp component.config nữa
          context.read<DynamicFormBloc>().add(
            UpdateFormField(componentId: component.id, value: newValue),
          );
          debugPrint(
            '[Checkbox][tap] id=${component.id} value_after=$newValue',
          );
          debugPrint('[Checkbox] Save value: ${component.id} = $newValue');
        }

        return GestureDetector(
          onTap: handleTap,
          child: Container(
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
      },
    );
  }
}
