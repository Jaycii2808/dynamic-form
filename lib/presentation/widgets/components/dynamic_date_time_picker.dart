import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimePicker extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic value) onComplete;

  const DynamicDateTimePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });
  @override
  State<DynamicDateTimePicker> createState() {
    return _DynamicDateTimePickerState();
  }

}

class _DynamicDateTimePickerState extends State<DynamicDateTimePicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.component.config['value'] ?? '';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      final newValue = _controller.text;
      if (newValue != widget.component.config['value']) {
        widget.component.config['value'] = newValue;
        context.read<DynamicFormBloc>().add(UpdateFormField(
          componentId: widget.component.id,
          value: newValue,
        ));
        widget.onComplete(newValue);
      }
      debugPrint('FocusNode changed for component ${widget.component.id}: hasFocus=${_focusNode.hasFocus}, value=${_controller.text}');
    }
    setState(() {});
  }

  Map<String, dynamic> _resolveStyles() {
    final style = Map<String, dynamic>.from(widget.component.style);
    if (widget.component.variants != null) {
      if (widget.component.config['value'] != null && widget.component.variants!.containsKey('withValue')) {
        final variantStyle = widget.component.variants!['withValue']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }
    final currentState = _determineState();
    if (widget.component.states != null && widget.component.states!.containsKey(currentState)) {
      final stateStyle = widget.component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }
    return style;
  }

  String _determineState() {
    final value = _controller.text;
    if (value.isEmpty) return 'base';
    final validationError = validateForm(widget.component, value);
    return validationError != null ? 'error' : 'success';
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyles();
    //final currentState = _determineState();

    return Container(
      key: Key(widget.component.id),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      margin: StyleUtils.parsePadding(style['margin']),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.component.config['placeholder'] ?? 'Select date/time',
          border: OutlineInputBorder(
            borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
            borderSide: BorderSide(
              color: StyleUtils.parseColor(style['borderColor']),
              width: style['borderWidth']?.toDouble() ?? 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
            borderSide: BorderSide(
              color: StyleUtils.parseColor(style['borderColor']),
              width: style['borderWidth']?.toDouble() ?? 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
            borderSide: BorderSide(
              color: StyleUtils.parseColor(style['borderColor']),
              width: style['borderWidth']?.toDouble() ?? 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorText: _errorText,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          filled: style['backgroundColor'] != null,
          fillColor: StyleUtils.parseColor(style['backgroundColor']),
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (context.mounted){
            if (pickedDate != null) {

              final pickedTime = await showTimePicker(

                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                final dateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                _controller.text = dateTime.toString();
                widget.onComplete(dateTime.toString());
                if (context.mounted){
                  context.read<DynamicFormBloc>().add(UpdateFormField(
                    componentId: widget.component.id,
                    value: dateTime.toString(),
                  )
                  );
                }

              }
            }
          }

        },
        onChanged: (value) {
          setState(() {
            _errorText = validateForm(widget.component, value);
          });
        },
      ),
    );
  }
}