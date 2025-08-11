import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_short_answer/dynamic_short_answer_bloc.dart';
import 'package:dynamic_form_bi/core/utils/short_answer_validation_utils.dart';

class DynamicShortAnswer extends StatefulWidget {
  final DynamicFormModel component;
  final Function(String)? onComplete;

  const DynamicShortAnswer({
    super.key,
    required this.component,
    this.onComplete,
  });

  @override
  State<DynamicShortAnswer> createState() => _DynamicShortAnswerState();
}

class _DynamicShortAnswerState extends State<DynamicShortAnswer> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.component.config?.value?.toString() ?? '',
    );
    _focusNode = FocusNode();

    // Initialize BLoC
    context.read<DynamicShortAnswerBloc>().add(
      InitializeDynamicShortAnswerEvent(component: widget.component),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicShortAnswerBloc, DynamicShortAnswerState>(
      listener: _buildBlocListener,
      builder: (context, state) {
        if (state is DynamicShortAnswerSuccess) {
          return _buildSuccessState(state);
        } else if (state is DynamicShortAnswerLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DynamicShortAnswerError) {
          return Center(child: Text('Error: ${state.errorMessage}'));
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _buildBlocListener(
    BuildContext context,
    DynamicShortAnswerState state,
  ) {
    if (state is DynamicShortAnswerSuccess) {
      // Update controller if value changes externally
      if (_textController.text != state.currentValue) {
        _textController.text = state.currentValue ?? '';
      }
    }
  }

  Widget _buildSuccessState(DynamicShortAnswerSuccess state) {
    final config = widget.component.config;
    final style = widget.component.style;
    final label = config?.label ?? '';
    final placeholder = config?.placeholder ?? 'Enter your answer';
    final isRequired = config?.isRequired ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: style.textColor ?? Colors.white,
                  fontSize: style.fontSize ?? 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          keyboardType: _getKeyboardType(),
          onChanged: (value) {
            context.read<DynamicShortAnswerBloc>().add(
              UpdateValueEvent(value),
            );
            widget.onComplete?.call(value);
          },
          style: TextStyle(
            color: style.textColor ?? Colors.white,
            fontSize: style.fontSize ?? 16,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: (style.textColor ?? Colors.white).withValues(alpha: 0.5),
              fontSize: style.fontSize ?? 16,
            ),
            filled: true,
            fillColor: style.backgroundColor ?? const Color(0xFF374151),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(style.borderRadius ?? 8),
              borderSide: BorderSide(
                color: _getBorderColor(state),
                width: style.borderWidth ?? 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(style.borderRadius ?? 8),
              borderSide: BorderSide(
                color: _getBorderColor(state),
                width: style.borderWidth ?? 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(style.borderRadius ?? 8),
              borderSide: BorderSide(
                color: Colors.blue,
                width: style.borderWidth ?? 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(style.borderRadius ?? 8),
              borderSide: BorderSide(
                color: Colors.red,
                width: style.borderWidth ?? 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: style.contentHorizontalPadding ?? 12,
              vertical: style.contentVerticalPadding ?? 12,
            ),
          ),
        ),
        if (state.errorText != null && state.errorText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            state.errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor(DynamicShortAnswerSuccess state) {
    if (state.errorText != null && state.errorText!.isNotEmpty) {
      return Colors.red;
    }
    if (state.currentValue != null && state.currentValue!.isNotEmpty) {
      return Colors.green;
    }
    return widget.component.style.borderColor ?? const Color(0xFF4B5563);
  }

  TextInputType _getKeyboardType() {
    return ShortAnswerValidationUtils.getKeyboardTypeForShortAnswer(
      widget.component,
    );
  }
}
