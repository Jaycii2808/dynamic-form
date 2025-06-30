// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSlider extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSlider({super.key, required this.component});

  @override
  State<DynamicSlider> createState() => _DynamicSliderState();
}

class _DynamicSliderState extends State<DynamicSlider> {
  double? _slider_value;
  RangeValues? _slider_range_values;
  final FocusNode _focus_node = FocusNode();

  @override
  void initState() {
    super.initState();
    _init_local_state(widget.component);
  }

  @override
  void didUpdateWidget(covariant DynamicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init_local_state(widget.component);
  }

  @override
  void dispose() {
    _focus_node.dispose();
    super.dispose();
  }

  void _init_local_state(DynamicFormModel component) {
    final config = component.config;
    final is_range = config['range'] == true;
    if (is_range) {
      final values = config['values'];
      if (values is List && values.length == 2) {
        _slider_range_values = RangeValues(
          (values[0] as num).toDouble(),
          (values[1] as num).toDouble(),
        );
      }
    } else {
      final value = config['value'];
      if (value is num) {
        _slider_value = value.toDouble();
      }
    }
  }

  void _sync_with_bloc(DynamicFormModel component) {
    final config = component.config;
    final is_range = config['range'] == true;
    if (is_range) {
      final values = config['values'];
      if (values is List && values.length == 2) {
        final range = RangeValues(
          (values[0] as num).toDouble(),
          (values[1] as num).toDouble(),
        );
        if (_slider_range_values == null ||
            _slider_range_values!.start != range.start ||
            _slider_range_values!.end != range.end) {
          setState(() {
            _slider_range_values = range;
          });
        }
      }
    } else {
      final value = config['value'];
      if (value is num && _slider_value != value.toDouble()) {
        setState(() {
          _slider_value = value.toDouble();
        });
      }
    }
  }

  IconData? _map_icon_name_to_icon_data(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;
        _sync_with_bloc(component);
      },
      builder: (context, state) {
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        final style = Map<String, dynamic>.from(component.style);
        final config = component.config;
        final bool is_range = config['range'] == true;
        final double min = (config['min'] as num?)?.toDouble() ?? 0;
        final double max = (config['max'] as num?)?.toDouble() ?? 100;
        final int? divisions = (config['divisions'] as num?)?.toInt();
        final String prefix = config['prefix']?.toString() ?? '';
        final String? hint = config['hint'] as String?;
        final String? icon_name = config['icon'] as String?;
        final String? thumb_icon_name = config['thumb_icon'] as String?;
        final String? error_text = config['error_text'] as String?;
        final bool is_disabled = config['disabled'] == true;

        if (component.variants != null) {
          if (hint != null && component.variants!.containsKey('with_hint')) {
            final variant_style =
                component.variants!['with_hint']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (icon_name != null &&
              component.variants!.containsKey('with_icon')) {
            final variant_style =
                component.variants!['with_icon']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (thumb_icon_name != null &&
              component.variants!.containsKey('with_thumb_icon')) {
            final variant_style =
                component.variants!['with_thumb_icon']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
        }

        final IconData? thumb_icon = thumb_icon_name != null
            ? _map_icon_name_to_icon_data(thumb_icon_name)
            : null;

        final slider_theme = SliderTheme.of(context).copyWith(
          activeTrackColor: StyleUtils.parseColor(style['active_color']),
          inactiveTrackColor: StyleUtils.parseColor(style['inactive_color']),
          thumbColor: StyleUtils.parseColor(style['thumb_color']),
          overlayColor: StyleUtils.parseColor(
            style['active_color'],
          ).withValues(alpha: 0.2),
          trackHeight: 6.0,
        );

        final slider_widget = SliderTheme(
          data: slider_theme.copyWith(
            rangeThumbShape: _CustomRangeSliderThumbShape(
              thumbRadius: 14,
              valuePrefix: prefix,
              values: _slider_range_values ?? RangeValues(min, max),
              iconColor: StyleUtils.parseColor(style['thumb_icon_color']),
              labelColor: StyleUtils.parseColor(style['value_label_color']),
              thumbIcon: thumb_icon,
            ),
            thumbShape: _CustomSliderThumbShape(
              thumbRadius: 14,
              valuePrefix: prefix,
              displayValue: _slider_value ?? min,
              iconColor: StyleUtils.parseColor(style['thumb_icon_color']),
              labelColor: StyleUtils.parseColor(style['value_label_color']),
              thumbIcon: thumb_icon,
            ),
          ),
          child: is_range
              ? RangeSlider(
                  values: _slider_range_values ?? RangeValues(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  labels: RangeLabels(
                    '$prefix${(_slider_range_values?.start ?? min).round()}',
                    '$prefix${(_slider_range_values?.end ?? max).round()}',
                  ),
                  onChanged: is_disabled
                      ? null
                      : (values) {
                          setState(() {
                            _slider_range_values = values;
                          });
                        },
                  onChangeEnd: is_disabled
                      ? null
                      : (values) {
                          context.read<DynamicFormBloc>().add(
                            UpdateFormFieldEvent(
                              componentId: component.id,
                              value: [values.start, values.end],
                            ),
                          );
                        },
                )
              : Slider(
                  value: _slider_value ?? min,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: '$prefix${_slider_value?.round()}',
                  onChanged: is_disabled
                      ? null
                      : (value) {
                          setState(() {
                            _slider_value = value;
                          });
                        },
                  onChangeEnd: is_disabled
                      ? null
                      : (value) {
                          context.read<DynamicFormBloc>().add(
                            UpdateFormFieldEvent(
                              componentId: component.id,
                              value: value,
                            ),
                          );
                        },
                ),
        );

        Widget? icon_widget;
        if (icon_name != null) {
          final icon_data = _map_icon_name_to_icon_data(icon_name);
          if (icon_data != null) {
            icon_widget = Icon(
              icon_data,
              color: StyleUtils.parseColor(style['icon_color']),
              size: (style['icon_size'] as num?)?.toDouble() ?? 24.0,
            );
          }
        }

        return Focus(
          focusNode: _focus_node,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_focus_node);
            },
            child: Container(
              key: Key(component.id),
              margin: StyleUtils.parsePadding(style['margin']),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon_widget != null) ...[
                        icon_widget,
                        const SizedBox(width: 8),
                      ],
                      Expanded(child: slider_widget),
                    ],
                  ),
                  if (hint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        hint,
                        style: TextStyle(
                          color: StyleUtils.parseColor(style['hint_color']),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (error_text != null && error_text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        error_text,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
