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
  double? sliderValue;
  RangeValues? sliderRangeValues;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    initLocalState(widget.component);
  }

  @override
  void didUpdateWidget(covariant DynamicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    initLocalState(widget.component);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void initLocalState(DynamicFormModel component) {
    final config = component.config;
    final isRange = config['range'] == true;
    if (isRange) {
      final values = config['values'];
      if (values is List && values.length == 2) {
        sliderRangeValues = RangeValues(
          (values[0] as num).toDouble(),
          (values[1] as num).toDouble(),
        );
      }
    } else {
      final value = config['value'];
      if (value is num) {
        sliderValue = value.toDouble();
      }
    }
  }

  void syncWithBloc(DynamicFormModel component) {
    final config = component.config;
    final isRange = config['range'] == true;
    if (isRange) {
      final values = config['values'];
      if (values is List && values.length == 2) {
        final range = RangeValues(
          (values[0] as num).toDouble(),
          (values[1] as num).toDouble(),
        );
        if (sliderRangeValues == null ||
            sliderRangeValues!.start != range.start ||
            sliderRangeValues!.end != range.end) {
          setState(() {
            sliderRangeValues = range;
          });
        }
      }
    } else {
      final value = config['value'];
      if (value is num && sliderValue != value.toDouble()) {
        setState(() {
          sliderValue = value.toDouble();
        });
      }
    }
  }

  IconData? mapIconNameToIconData(String name) {
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
        syncWithBloc(component);
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
        final bool isRange = config['range'] == true;
        final double min = (config['min'] as num?)?.toDouble() ?? 0;
        final double max = (config['max'] as num?)?.toDouble() ?? 100;
        final int? divisions = (config['divisions'] as num?)?.toInt();
        final String prefix = config['prefix']?.toString() ?? '';
        final String? hint = config['hint'] as String?;
        final String? iconName = config['icon'] as String?;
        final String? thumbIconName = config['thumb_icon'] as String?;
        final String? errorText = config['error_text'] as String?;
        final bool isDisabled = config['disabled'] == true;

        if (component.variants != null) {
          if (hint != null && component.variants!.containsKey('with_hint')) {
            final variantStyle =
                component.variants!['with_hint']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (iconName != null &&
              component.variants!.containsKey('with_icon')) {
            final variantStyle =
                component.variants!['with_icon']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (thumbIconName != null &&
              component.variants!.containsKey('with_thumb_icon')) {
            final variantStyle =
                component.variants!['with_thumb_icon']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
        }

        final IconData? thumbIcon = thumbIconName != null
            ? mapIconNameToIconData(thumbIconName)
            : null;

        final sliderTheme = SliderTheme.of(context).copyWith(
          activeTrackColor: StyleUtils.parseColor(style['active_color']),
          inactiveTrackColor: StyleUtils.parseColor(style['inactive_color']),
          thumbColor: StyleUtils.parseColor(style['thumb_color']),
          overlayColor: StyleUtils.parseColor(
            style['active_color'],
          ).withValues(alpha: 0.2),
          trackHeight: 6.0,
        );

        final sliderWidget = SliderTheme(
          data: sliderTheme.copyWith(
            rangeThumbShape: CustomRangeSliderThumbShape(
              thumbRadius: 14,
              valuePrefix: prefix,
              values: sliderRangeValues ?? RangeValues(min, max),
              iconColor: StyleUtils.parseColor(style['thumb_icon_color']),
              labelColor: StyleUtils.parseColor(style['value_label_color']),
              thumbIcon: thumbIcon,
            ),
            thumbShape: CustomSliderThumbShape(
              thumbRadius: 14,
              valuePrefix: prefix,
              displayValue: sliderValue ?? min,
              iconColor: StyleUtils.parseColor(style['thumb_icon_color']),
              labelColor: StyleUtils.parseColor(style['value_label_color']),
              thumbIcon: thumbIcon,
            ),
          ),
          child: isRange
              ? RangeSlider(
                  values: sliderRangeValues ?? RangeValues(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  labels: RangeLabels(
                    '$prefix${(sliderRangeValues?.start ?? min).round()}',
                    '$prefix${(sliderRangeValues?.end ?? max).round()}',
                  ),
                  onChanged: isDisabled
                      ? null
                      : (values) {
                          setState(() {
                            sliderRangeValues = values;
                          });
                        },
                  onChangeEnd: isDisabled
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
                  value: sliderValue ?? min,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: '$prefix${sliderValue?.round()}',
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          setState(() {
                            sliderValue = value;
                          });
                        },
                  onChangeEnd: isDisabled
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

        Widget? iconWidget;
        if (iconName != null) {
          final iconData = mapIconNameToIconData(iconName);
          if (iconData != null) {
            iconWidget = Icon(
              iconData,
              color: StyleUtils.parseColor(style['icon_color']),
              size: (style['icon_size'] as num?)?.toDouble() ?? 24.0,
            );
          }
        }

        return Focus(
          focusNode: focusNode,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            child: Container(
              key: Key(component.id),
              margin: StyleUtils.parsePadding(style['margin']),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (iconWidget != null) ...[
                        iconWidget,
                        const SizedBox(width: 8),
                      ],
                      Expanded(child: sliderWidget),
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
                  if (errorText != null && errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        errorText,
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

class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final String valuePrefix;
  final double displayValue;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? thumbIcon;

  CustomSliderThumbShape({
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

class CustomRangeSliderThumbShape extends RangeSliderThumbShape {
  final double thumbRadius;
  final String valuePrefix;
  final RangeValues values;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? thumbIcon;

  CustomRangeSliderThumbShape({
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
