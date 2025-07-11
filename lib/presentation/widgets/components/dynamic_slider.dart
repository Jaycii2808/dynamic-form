// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_slider/dynamic_slider_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_slider/dynamic_slider_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_slider/dynamic_slider_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSlider extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSlider({super.key, required this.component});

  @override
  State<DynamicSlider> createState() => _DynamicSliderState();
}

class _DynamicSliderState extends State<DynamicSlider> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicSliderBloc(initialComponent: widget.component)
            ..add(const InitializeSliderEvent()),
      child: DynamicSliderWidget(component: widget.component),
    );
  }
}

class DynamicSliderWidget extends StatelessWidget {
  final DynamicFormModel component;

  const DynamicSliderWidget({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update slider bloc
        if (formState.page?.components != null) {
          final updatedComponent = formState.page!.components.firstWhere(
            (c) => c.id == component.id,
            orElse: () => component,
          );

          // Check if component changed from external source
          if (updatedComponent.config['value'] != component.config['value'] ||
              updatedComponent.config['values'] != component.config['values'] ||
              updatedComponent.config['disabled'] !=
                  component.config['disabled'] ||
              updatedComponent.config['error_text'] !=
                  component.config['error_text']) {
            debugPrint(
              '🔄 [Slider] External change detected',
            );

            context.read<DynamicSliderBloc>().add(
              UpdateSliderFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicSliderBloc, DynamicSliderState>(
        listenWhen: (previous, current) {
          return current is DynamicSliderSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state changes or value updates
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              (previous is DynamicSliderSuccess &&
                  current is DynamicSliderSuccess &&
                  (previous.sliderValue != current.sliderValue ||
                      previous.sliderRangeValues != current.sliderRangeValues ||
                      previous.isDisabled != current.isDisabled ||
                      previous.valueTimestamp != current.valueTimestamp));
        },
        listener: (context, state) {
          if (state is DynamicSliderSuccess && !state.isUserSliding) {
            // Update main form with final value
            final dynamic blocValue;
            if (state.isRange && state.sliderRangeValues != null) {
              blocValue = [
                state.sliderRangeValues!.start,
                state.sliderRangeValues!.end,
              ];
            } else {
              blocValue = state.sliderValue;
            }

            // ✅ Send value directly to form BLoC for consistent handling
            // Range sliders send List, single sliders send double
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: blocValue, // Send raw value, let FormBloc handle storage
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [Slider] Building with state: ${state.runtimeType}',
          );

          if (state is DynamicSliderLoading || state is DynamicSliderInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicSliderError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicSliderSuccess) {
            // Trigger theme computation if not yet computed
            if (state.sliderTheme == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<DynamicSliderBloc>().add(
                  ComputeSliderThemeEvent(context: context),
                );
              });
            }

            return _buildBody(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DynamicSliderSuccess state) {
    // Use provided theme or fallback to default with computed colors
    final sliderTheme =
        state.sliderTheme ??
        SliderTheme.of(context).copyWith(
          activeTrackColor: StyleUtils.parseColor(
            state.computedStyle['active_color'],
          ),
          inactiveTrackColor: StyleUtils.parseColor(
            state.computedStyle['inactive_color'],
          ),
          thumbColor: StyleUtils.parseColor(
            state.computedStyle['thumb_color'],
          ),
          overlayColor: StyleUtils.parseColor(
            state.computedStyle['active_color'],
          ).withValues(alpha: 0.2),
          trackHeight: 6.0,
        );

    final sliderWidget = SliderTheme(
      data: sliderTheme.copyWith(
        rangeThumbShape: CustomRangeSliderThumbShape(
          thumbRadius: 14,
          valuePrefix: state.prefix,
          values: state.sliderRangeValues ?? RangeValues(state.min, state.max),
          iconColor: StyleUtils.parseColor(
            state.computedStyle['thumb_icon_color'],
          ),
          labelColor: StyleUtils.parseColor(
            state.computedStyle['value_label_color'],
          ),
          thumbIcon: state.thumbIcon,
        ),
        thumbShape: CustomSliderThumbShape(
          thumbRadius: 14,
          valuePrefix: state.prefix,
          displayValue: state.sliderValue ?? state.min,
          iconColor: StyleUtils.parseColor(
            state.computedStyle['thumb_icon_color'],
          ),
          labelColor: StyleUtils.parseColor(
            state.computedStyle['value_label_color'],
          ),
          thumbIcon: state.thumbIcon,
        ),
      ),
      child: state.isRange
          ? RangeSlider(
              values:
                  state.sliderRangeValues ?? RangeValues(state.min, state.max),
              min: state.min,
              max: state.max,
              divisions: state.divisions,
              labels: RangeLabels(
                '${state.prefix}${(state.sliderRangeValues?.start ?? state.min).round()}',
                '${state.prefix}${(state.sliderRangeValues?.end ?? state.max).round()}',
              ),
              onChangeStart: state.isDisabled
                  ? null
                  : (values) {
                      context.read<DynamicSliderBloc>().add(
                        SliderChangeStartEvent(value: values),
                      );
                    },
              onChanged: state.isDisabled
                  ? null
                  : (values) {
                      context.read<DynamicSliderBloc>().add(
                        SliderValueChangedEvent(value: values),
                      );
                    },
              onChangeEnd: state.isDisabled
                  ? null
                  : (values) {
                      context.read<DynamicSliderBloc>().add(
                        SliderChangeEndEvent(value: values),
                      );
                    },
            )
          : Slider(
              value: state.sliderValue ?? state.min,
              min: state.min,
              max: state.max,
              divisions: state.divisions,
              label: '${state.prefix}${state.sliderValue?.round()}',
              onChangeStart: state.isDisabled
                  ? null
                  : (value) {
                      context.read<DynamicSliderBloc>().add(
                        SliderChangeStartEvent(value: value),
                      );
                    },
              onChanged: state.isDisabled
                  ? null
                  : (value) {
                      context.read<DynamicSliderBloc>().add(
                        SliderValueChangedEvent(value: value),
                      );
                    },
              onChangeEnd: state.isDisabled
                  ? null
                  : (value) {
                      context.read<DynamicSliderBloc>().add(
                        SliderChangeEndEvent(value: value),
                      );
                    },
            ),
    );

    Widget? iconWidget;
    if (state.iconName != null) {
      final iconData = IconTypeEnum.fromString(state.iconName!).toIconData();
      if (iconData != null) {
        iconWidget = Icon(
          iconData,
          color: StyleUtils.parseColor(state.computedStyle['icon_color']),
          size: (state.computedStyle['icon_size'] as num?)?.toDouble() ?? 24.0,
        );
      }
    }

    return Focus(
      focusNode: state.focusNode,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(state.focusNode);
        },
        child: Container(
          key: Key(state.component!.id),
          margin: StyleUtils.parsePadding(state.computedStyle['margin']),
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
              if (state.hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    state.hint!,
                    style: TextStyle(
                      color: StyleUtils.parseColor(
                        state.computedStyle['hint_color'],
                      ),
                      fontSize: 12,
                    ),
                  ),
                ),
              if (state.errorText != null && state.errorText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                  child: Text(
                    state.errorText!,
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
