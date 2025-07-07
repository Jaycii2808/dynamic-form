// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';

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

  // ✅ Flag to prevent BLoC sync while user is sliding
  bool _isUserSliding = false;

  // ✅ State variables for computed values - move logic from builder to listener
  late DynamicFormModel _currentComponent;
  Map<String, dynamic> _style = {};
  bool _isRange = false;
  double _min = 0;
  double _max = 100;
  int? _divisions;
  String _prefix = '';
  String? _hint;
  String? _iconName;
  String? _thumbIconName;
  String? _errorText;
  bool _isDisabled = false;
  IconData? _thumbIcon;
  SliderThemeData? _sliderTheme;

  @override
  void initState() {
    super.initState();
    _currentComponent = widget.component;
    initLocalState(widget.component);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Call _computeValues here where context is available for Theme access
    _computeValues();
  }

  @override
  void didUpdateWidget(covariant DynamicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if component changed
    if (widget.component != oldWidget.component) {
      _currentComponent = widget.component;
      _computeValues();
      initLocalState(widget.component);
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  /// ✅ Compute all values from component - called in listener
  void _computeValues() {
    _style = Map<String, dynamic>.from(_currentComponent.style);
    final config = _currentComponent.config;

    _isRange = config['range'] == true;
    _min = (config['min'] as num?)?.toDouble() ?? 0;
    _max = (config['max'] as num?)?.toDouble() ?? 100;
    _divisions = (config['divisions'] as num?)?.toInt();
    _prefix = config['prefix']?.toString() ?? '';
    _hint = config['hint'] as String?;
    _iconName = config['icon'] as String?;
    _thumbIconName = config['thumb_icon'] as String?;
    _errorText = config['error_text'] as String?;
    _isDisabled = config['disabled'] == true;

    // Apply variants to style
    if (_currentComponent.variants != null) {
      if (_hint != null &&
          _currentComponent.variants!.containsKey('with_hint')) {
        final variantStyle =
            _currentComponent.variants!['with_hint']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
      if (_iconName != null &&
          _currentComponent.variants!.containsKey('with_icon')) {
        final variantStyle =
            _currentComponent.variants!['with_icon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
      if (_thumbIconName != null &&
          _currentComponent.variants!.containsKey('with_thumb_icon')) {
        final variantStyle =
            _currentComponent.variants!['with_thumb_icon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
    }

    // Compute thumb icon
    _thumbIcon = _thumbIconName != null
        ? mapIconNameToIconData(_thumbIconName!)
        : null;

    // Compute slider theme
    _sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: StyleUtils.parseColor(_style['active_color']),
      inactiveTrackColor: StyleUtils.parseColor(_style['inactive_color']),
      thumbColor: StyleUtils.parseColor(_style['thumb_color']),
      overlayColor: StyleUtils.parseColor(
        _style['active_color'],
      ).withValues(alpha: 0.2),
      trackHeight: 6.0,
    );
  }

  /// ✅ Send value to BLoC - only called when user finishes sliding
  void _sendValueToBloc(dynamic value) {
    // ✅ Convert RangeValues to array format for BLoC
    final blocValue = value is RangeValues ? [value.start, value.end] : value;

    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: widget.component.id,
        value: blocValue,
      ),
    );
  }

  /// ✅ Immediate UI update - keep UI responsive
  void _updateSliderValue(dynamic value) {
    setState(() {
      if (value is RangeValues) {
        sliderRangeValues = value;
      } else if (value is double) {
        sliderValue = value;
      }
    });
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
    // ✅ Don't sync while user is actively sliding
    if (_isUserSliding) return;

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
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // ✅ ALL LOGIC HERE - như text field pattern
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Only update if component actually changed
        if (updatedComponent != _currentComponent ||
            updatedComponent.config['value'] !=
                _currentComponent.config['value'] ||
            updatedComponent.config['values'] !=
                _currentComponent.config['values'] ||
            updatedComponent.config['error_text'] !=
                _currentComponent.config['error_text'] ||
            updatedComponent.config['disabled'] !=
                _currentComponent.config['disabled']) {
          setState(() {
            _currentComponent = updatedComponent;
            _computeValues();
          });
        }

        syncWithBloc(updatedComponent);
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when visual properties change
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          return prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'] ||
              prevComponent?.config['error_text'] !=
                  currComponent?.config['error_text'] ||
              prevComponent?.config['icon'] != currComponent?.config['icon'] ||
              prevComponent?.config['hint'] != currComponent?.config['hint'];
        },
        builder: (context, state) {
          // ✅ Builder chỉ render UI với computed values từ listener
          if (_sliderTheme == null) return const SizedBox.shrink();

          final sliderWidget = SliderTheme(
            data: _sliderTheme!.copyWith(
              rangeThumbShape: CustomRangeSliderThumbShape(
                thumbRadius: 14,
                valuePrefix: _prefix,
                values: sliderRangeValues ?? RangeValues(_min, _max),
                iconColor: StyleUtils.parseColor(_style['thumb_icon_color']),
                labelColor: StyleUtils.parseColor(_style['value_label_color']),
                thumbIcon: _thumbIcon,
              ),
              thumbShape: CustomSliderThumbShape(
                thumbRadius: 14,
                valuePrefix: _prefix,
                displayValue: sliderValue ?? _min,
                iconColor: StyleUtils.parseColor(_style['thumb_icon_color']),
                labelColor: StyleUtils.parseColor(_style['value_label_color']),
                thumbIcon: _thumbIcon,
              ),
            ),
            child: _isRange
                ? RangeSlider(
                    values: sliderRangeValues ?? RangeValues(_min, _max),
                    min: _min,
                    max: _max,
                    divisions: _divisions,
                    labels: RangeLabels(
                      '$_prefix${(sliderRangeValues?.start ?? _min).round()}',
                      '$_prefix${(sliderRangeValues?.end ?? _max).round()}',
                    ),
                    onChangeStart: _isDisabled
                        ? null
                        : (values) {
                            _isUserSliding = true;
                          },
                    onChanged: _isDisabled
                        ? null
                        : (values) {
                            _updateSliderValue(values);
                          },
                    onChangeEnd: _isDisabled
                        ? null
                        : (values) {
                            _isUserSliding = false;
                            _sendValueToBloc(values);
                          },
                  )
                : Slider(
                    value: sliderValue ?? _min,
                    min: _min,
                    max: _max,
                    divisions: _divisions,
                    label: '$_prefix${sliderValue?.round()}',
                    onChangeStart: _isDisabled
                        ? null
                        : (value) {
                            _isUserSliding = true;
                          },
                    onChanged: _isDisabled
                        ? null
                        : (value) {
                            _updateSliderValue(value);
                          },
                    onChangeEnd: _isDisabled
                        ? null
                        : (value) {
                            _isUserSliding = false;
                            _sendValueToBloc(value);
                          },
                  ),
          );

          Widget? iconWidget;
          if (_iconName != null) {
            final iconData = mapIconNameToIconData(_iconName!);
            if (iconData != null) {
              iconWidget = Icon(
                iconData,
                color: StyleUtils.parseColor(_style['icon_color']),
                size: (_style['icon_size'] as num?)?.toDouble() ?? 24.0,
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
                key: Key(_currentComponent.id),
                margin: StyleUtils.parsePadding(_style['margin']),
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
                    if (_hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          _hint!,
                          style: TextStyle(
                            color: StyleUtils.parseColor(_style['hint_color']),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (_errorText != null && _errorText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
