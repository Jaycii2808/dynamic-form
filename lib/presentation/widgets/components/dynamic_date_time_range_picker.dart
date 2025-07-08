import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/custom_date_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DynamicDateTimeRangePicker extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicDateTimeRangePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicDateTimeRangePickerBloc,
        DynamicDateTimeRangePickerState>(
      listener: (context, state) {
        if (state is DynamicDateTimeRangePickerSuccess) {
          final valueMap = {
            ValueKeyEnum.value.key:
            state.component!.config[ValueKeyEnum.value.key],
            ValueKeyEnum.currentState.key:
            state.component!.config[ValueKeyEnum.currentState.key],
            ValueKeyEnum.errorText.key: state.errorText,
          };
          onComplete(valueMap);
        } else if (state is DynamicDateTimeRangePickerError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state is DynamicDateTimeRangePickerLoading ||
            state is DynamicDateTimeRangePickerInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicDateTimeRangePickerSuccess) {
          return _buildBody(
            state.styleConfig!,
            state.inputConfig!,
            state.component!,
            state.textController!,
            state.focusNode!,
            state.errorText,
            context,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
      StyleConfig styleConfig,
      InputConfig inputConfig,
      DynamicFormModel component,
      TextEditingController textController,
      FocusNode focusNode,
      String? errorText,
      BuildContext context,
      ) {
    final combinedStyle = Map<String, dynamic>.from(component.style);
    if (component.variants?.containsKey('range') == true) {
      combinedStyle.addAll(component.variants!['range']['style']);
    }

    final currentState = FormStateEnum.fromString(inputConfig.currentState) ?? FormStateEnum.base;
    if (component.states?.containsKey(currentState.value) == true) {
      combinedStyle.addAll(component.states![currentState.value]['style']);
    }

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(combinedStyle['padding']),
      margin: StyleUtils.parsePadding(combinedStyle['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inputConfig.label != null && inputConfig.label!.isNotEmpty)
            _buildLabelText(label: inputConfig.label!, style: combinedStyle),
          _buildDatePickerTextField(
            context: context,
            controller: textController,
            focusNode: focusNode,
            errorText: errorText,
            hintText:
            inputConfig.placeholder ?? 'MMM d,yyyy - MMM d,yyyy',
            style: combinedStyle,
            onTap: inputConfig.disabled
                ? () {}
                : () => _showDateRangePickerDialog(context, component),
          ),
        ],
      ),
    );
  }

  void _showDateRangePickerDialog(
      BuildContext context, DynamicFormModel component) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          final value = component.config['value'];
          DateTimeRange? initialRange;
          if (value is Map<String, dynamic>) {
            try {
              initialRange = DateTimeRange(
                start: DateFormat("MMM d,yyyy").parse(value['start']),
                end: DateFormat("MMM d,yyyy").parse(value['end']),
              );
            } catch(e) {
              debugPrint("Error parsing initial date range for dialog: $e");
            }
          }
          return CustomDateRangePickerDialog(
            initialDateRange: initialRange,
            onConfirm: (selectedRange) {
              if (selectedRange != null) {
                context
                    .read<DynamicDateTimeRangePickerBloc>()
                    .add(DateTimeRangePickedEvent(value: selectedRange));
              }
            },
            style: component.style,
          );
        }
    );
  }

  Widget _buildLabelText({
    required String label,
    required Map<String, dynamic> style,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: TextStyle(
          fontSize: (style['label_text_size'] as num?)?.toDouble() ?? 16,
          color: StyleUtils.parseColor(style['label_color'] ?? '#333333'),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDatePickerTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    String? hintText,
    required Map<String, dynamic> style,
    required VoidCallback onTap,
  }) {
    final borderColor = StyleUtils.parseColor(style['border_color'] ?? '#CCCCCC');
    final focusedBorderColor = StyleUtils.parseColor(style['focused_border_color'] ?? style['icon_color'] ?? '#6979F8');
    final errorBorderColor = Colors.red;
    final borderRadius = (style['border_radius'] as num?)?.toDouble() ?? 8.0;
    final borderWidth = (style['border_width'] as num?)?.toDouble() ?? 1.0;
    final textColor = StyleUtils.parseColor(style['color'] ?? '#333333');
    final fillColor = StyleUtils.parseColor(style['background_color'] ?? '#FFFFFF');
    final iconColor = StyleUtils.parseColor(style['icon_color'] ?? style['color'] ?? '#6979F8');
    final iconSize = (style['icon_size'] as num?)?.toDouble() ?? 20.0;
    final fontSize = (style['font_size'] as num?)?.toDouble() ?? 14.0;
    final contentVerticalPadding = (style['content_vertical_padding'] as num?)?.toDouble() ?? 16.0;
    final contentHorizontalPadding = (style['content_horizontal_padding'] as num?)?.toDouble() ?? 16.0;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (_) => focusNode.unfocus(),
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/svg/SelectDate.svg',
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: iconSize,
            height: iconSize,
          ),
        ),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: borderWidth + 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorBorderColor, width: borderWidth),
        ),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: contentVerticalPadding,
          horizontal: contentHorizontalPadding,
        ),
        filled: style['background_color'] != null,
        fillColor: fillColor,
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontStyle: style['font_style'] == 'italic' ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}