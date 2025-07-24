import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
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
    return BlocConsumer<
      DynamicDateTimeRangePickerBloc,
      DynamicDateTimeRangePickerState
    >(
      listener: (context, state) {
        final valueMap = {
          ValueKeyEnum.value.key:
              state.component!.config[ValueKeyEnum.value.key],
          ValueKeyEnum.currentState.key:
              state.component!.config[ValueKeyEnum.currentState.key],
          ValueKeyEnum.errorText.key: state.errorText,
        };
        if (state is DynamicDateTimeRangePickerSuccess) {
          onComplete(valueMap);
        } else if (state is DynamicDateTimeRangePickerError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicDateTimeRangePickerLoading ||
            state is DynamicDateTimeRangePickerInitial) {
          debugPrint('Listener: Handling ${state.runtimeType} state');
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicDateTimeRangePickerLoading ||
            state is DynamicDateTimeRangePickerInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicDateTimeRangePickerSuccess) {
          return _buildBody(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    DynamicDateTimeRangePickerSuccess state,
  ) {
    final styleMap = state.combinedStyle ?? <String, dynamic>{};
    final styleModel = StyleModel.fromJson(styleMap);
    return Container(
      key: Key(state.component!.id),
      padding: StyleUtils.parsePadding(styleModel.padding),
      margin: StyleUtils.parsePadding(styleModel.margin),
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(styleModel.backgroundColor),
        border: Border.all(
          color: StyleUtils.parseColor(styleModel.borderColor ?? '#CCCCCC'),
          width: styleModel.borderWidth ?? 1.0,
        ),
        borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.inputConfig!.label != null &&
              state.inputConfig!.label!.isNotEmpty)
            _buildLabelText(
              label: state.inputConfig!.label!,
              style: styleMap,
            ),
          _buildDatePickerTextField(
            context: context,
            controller: state.textController!,
            focusNode: state.focusNode!,
            errorText: state.errorText,
            hintText:
                state.inputConfig!.placeholder ?? 'MMM d,yyyy - MMM d,yyyy',
            style: styleMap,
            onTap: state.inputConfig!.disabled
                ? () {}
                : () => _showDateRangePickerDialog(context, state.component!),
          ),
        ],
      ),
    );
  }

  void _showDateRangePickerDialog(
    BuildContext context,
    DynamicFormModel component,
  ) {
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
          } catch (e) {
            debugPrint("Error parsing initial date range for dialog: $e");
          }
        }
        return CustomDateRangePickerDialog(
          initialDateRange: initialRange,
          onConfirm: (selectedRange) {
            if (selectedRange != null) {
              context.read<DynamicDateTimeRangePickerBloc>().add(
                DateTimeRangePickedEvent(value: selectedRange),
              );
            }
          },
          style: component.style.toJson(),
        );
      },
    );
  }

  Widget _buildLabelText({
    required String label,
    required Map<String, dynamic> style,
  }) {
    final bool isRequired = component.config['is_required'] == true;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: (style['label_text_size'] as num?)?.toDouble() ?? 16,
              color: StyleUtils.parseColor(style['label_color'] ?? '#333333'),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
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
    final borderColor = StyleUtils.parseColor(
      style['border_color'] ?? '#CCCCCC',
    );
    final focusedBorderColor = StyleUtils.parseColor(
      style['focused_border_color'] ?? style['icon_color'] ?? '#6979F8',
    );
    final errorBorderColor = Colors.red;
    final borderRadius = (style['border_radius'] as num?)?.toDouble() ?? 8.0;
    final borderWidth = (style['border_width'] as num?)?.toDouble() ?? 1.0;
    final textColor = StyleUtils.parseColor(style['color'] ?? '#333333');
    final fillColor = StyleUtils.parseColor(
      style['background_color'] ?? '#FFFFFF',
    );
    final iconColor = StyleUtils.parseColor(
      style['icon_color'] ?? style['color'] ?? '#6979F8',
    );
    final iconSize = (style['icon_size'] as num?)?.toDouble() ?? 20.0;
    final fontSize = (style['font_size'] as num?)?.toDouble() ?? 14.0;
    final contentVerticalPadding =
        (style['content_vertical_padding'] as num?)?.toDouble() ?? 16.0;
    final contentHorizontalPadding =
        (style['content_horizontal_padding'] as num?)?.toDouble() ?? 16.0;

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
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: borderWidth + 1,
          ),
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
        fontStyle: style['font_style'] == 'italic'
            ? FontStyle.italic
            : FontStyle.normal,
      ),
    );
  }
}
