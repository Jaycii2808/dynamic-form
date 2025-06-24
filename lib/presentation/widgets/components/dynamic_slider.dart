import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSlider extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSlider({super.key, required this.component});

  @override
  State<DynamicSlider> createState() => _DynamicSliderState();
}

class _DynamicSliderState extends State<DynamicSlider> {
  RangeValues? _sliderRangeValues;
  double? _sliderValue;

  @override
  void initState() {
    super.initState();
    final value = widget.component.config['value'];
    final values = widget.component.config['values'];

    if (value is num) {
      _sliderValue = value.toDouble();
    }
    if (values is List) {
      _sliderRangeValues = RangeValues(
        values[0].toDouble(),
        values[1].toDouble(),
      );
    }
  }

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
    final style = Map<String, dynamic>.from(widget.component.style);
    final config = widget.component.config;
    final bool isRange = config['range'] == true;
    final double min = (config['min'] as num?)?.toDouble() ?? 0;
    final double max = (config['max'] as num?)?.toDouble() ?? 100;
    final int? divisions = (config['divisions'] as num?)?.toInt();
    final String prefix = config['prefix']?.toString() ?? '';
    final String? hint = config['hint'] as String?;
    final String? iconName = config['icon'] as String?;
    final String? thumbIconName = config['thumbIcon'] as String?;

    if (widget.component.variants != null) {
      if (hint != null && widget.component.variants!.containsKey('withHint')) {
        final variantStyle =
            widget.component.variants!['withHint']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (iconName != null &&
          widget.component.variants!.containsKey('withIcon')) {
        final variantStyle =
            widget.component.variants!['withIcon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (thumbIconName != null &&
          widget.component.variants!.containsKey('withThumbIcon')) {
        final variantStyle =
            widget.component.variants!['withThumbIcon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    final IconData? thumbIcon = thumbIconName != null
        ? _mapIconNameToIconData(thumbIconName)
        : null;

    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: StyleUtils.parseColor(style['activeColor']),
      inactiveTrackColor: StyleUtils.parseColor(style['inactiveColor']),
      thumbColor: StyleUtils.parseColor(style['thumbColor']),
      overlayColor: StyleUtils.parseColor(
        style['activeColor'],
      ).withValues(alpha: 0.2),
      trackHeight: 6.0,
    );

    final currentRangeValues = _sliderRangeValues ?? RangeValues(min, max);

    final sliderWidget = SliderTheme(
      data: sliderTheme.copyWith(
        rangeThumbShape: _CustomRangeSliderThumbShape(
          thumbRadius: 14,
          valuePrefix: prefix,
          values: currentRangeValues,
          iconColor: StyleUtils.parseColor(style['thumbIconColor']),
          labelColor: StyleUtils.parseColor(style['valueLabelColor']),
          thumbIcon: thumbIcon,
        ),
        thumbShape: _CustomSliderThumbShape(
          thumbRadius: 14,
          valuePrefix: prefix,
          displayValue: _sliderValue ?? min,
          iconColor: StyleUtils.parseColor(style['thumbIconColor']),
          labelColor: StyleUtils.parseColor(style['valueLabelColor']),
          thumbIcon: thumbIcon,
        ),
      ),
      child: isRange
          ? RangeSlider(
              values: currentRangeValues,
              min: min,
              max: max,
              divisions: divisions,
              labels: RangeLabels(
                '$prefix${currentRangeValues.start.round()}',
                '$prefix${currentRangeValues.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _sliderRangeValues = values;
                });
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(
                    componentId: widget.component.id,
                    value: [values.start, values.end],
                  ),
                );
              },
            )
          : Slider(
              value: _sliderValue ?? min,
              min: min,
              max: max,
              divisions: divisions,
              label: '$prefix${_sliderValue?.round()}',
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(
                    componentId: widget.component.id,
                    value: value,
                  ),
                );
              },
            ),
    );

    Widget? iconWidget;
    if (iconName != null) {
      final iconData = _mapIconNameToIconData(iconName);
      if (iconData != null) {
        iconWidget = Icon(
          iconData,
          color: StyleUtils.parseColor(style['iconColor']),
          size: (style['iconSize'] as num?)?.toDouble() ?? 24.0,
        );
      }
    }

    return Container(
      key: Key(widget.component.id),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconWidget != null) ...[iconWidget, const SizedBox(width: 8)],
              Expanded(child: sliderWidget),
            ],
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                hint,
                style: TextStyle(
                  color: StyleUtils.parseColor(style['hintColor']),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final String valuePrefix;
  final double displayValue;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? thumbIcon;

  _CustomSliderThumbShape({
    this.thumbRadius = 14.0,
    this.valuePrefix = '',
    required this.displayValue,
    this.iconColor,
    this.labelColor,
    this.thumbIcon,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    final icon = thumbIcon ?? Icons.check;
    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: thumbRadius * 1.2,
          fontFamily: icon.fontFamily,
          color: iconColor ?? sliderTheme.activeTrackColor,
        ),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );

    final valueLabelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$valuePrefix${displayValue.round()}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: labelColor ?? Colors.white,
        ),
      ),
    );
    valueLabelPainter.layout();
    valueLabelPainter.paint(
      canvas,
      center + Offset(-valueLabelPainter.width / 2, thumbRadius + 4),
    );
  }
}

class _CustomRangeSliderThumbShape extends RangeSliderThumbShape {
  final double thumbRadius;
  final String valuePrefix;
  final RangeValues values;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? thumbIcon;

  _CustomRangeSliderThumbShape({
    this.thumbRadius = 14.0,
    this.valuePrefix = '',
    required this.values,
    this.iconColor,
    this.labelColor,
    this.thumbIcon,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isPressed = false,
    bool isOnTop = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    if (thumb == null) {
      return;
    }
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    final icon = thumbIcon ?? Icons.check;
    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: thumbRadius * 1.2,
          fontFamily: icon.fontFamily,
          color: iconColor ?? sliderTheme.activeTrackColor,
        ),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );

    final double value = thumb == Thumb.start ? values.start : values.end;
    final valueLabelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$valuePrefix${value.round()}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: labelColor ?? Colors.white,
        ),
      ),
    );
    valueLabelPainter.layout();
    valueLabelPainter.paint(
      canvas,
      center + Offset(-valueLabelPainter.width / 2, thumbRadius + 4),
    );
  }
}
