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
  double? _sliderValue;
  RangeValues? _sliderRangeValues;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLocalState(widget.component);
  }

  @override
  void didUpdateWidget(covariant DynamicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initLocalState(widget.component);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _initLocalState(DynamicFormModel component) {
    final config = component.config;
    final isRange = config['range'] == true;
    if (isRange) {
      final values = config['values'];
      if (values is List && values.length == 2) {
        _sliderRangeValues = RangeValues(
          (values[0] as num).toDouble(),
          (values[1] as num).toDouble(),
        );
      }
    } else {
      final value = config['value'];
      if (value is num) {
        _sliderValue = value.toDouble();
      }
    }
  }

  void _syncWithBloc(DynamicFormModel component) {
    final config = component.config;
    final isRange = config['range'] == true;
    if (isRange) {
      final values = config['values'];
      if (values is List && values.length == 2) {
        final range = RangeValues(
          (values[0] as num).toDouble(),
          (values[1] as num).toDouble(),
        );
        if (_sliderRangeValues == null ||
            _sliderRangeValues!.start != range.start ||
            _sliderRangeValues!.end != range.end) {
          setState(() {
            _sliderRangeValues = range;
          });
        }
      }
    } else {
      final value = config['value'];
      if (value is num && _sliderValue != value.toDouble()) {
        setState(() {
          _sliderValue = value.toDouble();
        });
      }
    }
  }

  IconData? _mapIconNameToIconData(String name) {
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
        _syncWithBloc(component);
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
        final String? thumbIconName = config['thumbIcon'] as String?;
        final String? errorText = config['errorText'] as String?;
        final bool isDisabled = config['disabled'] == true;

        if (component.variants != null) {
          if (hint != null && component.variants!.containsKey('withHint')) {
            final variantStyle =
                component.variants!['withHint']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (iconName != null && component.variants!.containsKey('withIcon')) {
            final variantStyle =
                component.variants!['withIcon']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (thumbIconName != null &&
              component.variants!.containsKey('withThumbIcon')) {
            final variantStyle =
                component.variants!['withThumbIcon']['style']
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

        final sliderWidget = SliderTheme(
          data: sliderTheme.copyWith(
            rangeThumbShape: _CustomRangeSliderThumbShape(
              thumbRadius: 14,
              valuePrefix: prefix,
              values: _sliderRangeValues ?? RangeValues(min, max),
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
                  values: _sliderRangeValues ?? RangeValues(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  labels: RangeLabels(
                    '$prefix${(_sliderRangeValues?.start ?? min).round()}',
                    '$prefix${(_sliderRangeValues?.end ?? max).round()}',
                  ),
                  onChanged: isDisabled
                      ? null
                      : (values) {
                          setState(() {
                            _sliderRangeValues = values;
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
                  value: _sliderValue ?? min,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: '$prefix${_sliderValue?.round()}',
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          setState(() {
                            _sliderValue = value;
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
          final iconData = _mapIconNameToIconData(iconName);
          if (iconData != null) {
            iconWidget = Icon(
              iconData,
              color: StyleUtils.parseColor(style['iconColor']),
              size: (style['iconSize'] as num?)?.toDouble() ?? 24.0,
            );
          }
        }

        return Focus(
          focusNode: _focusNode,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_focusNode);
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
                          color: StyleUtils.parseColor(style['hintColor']),
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
