// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_checkbox/dynamic_checkbox_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicCheckbox extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicCheckbox({super.key, required this.component});

  @override
  State<DynamicCheckbox> createState() => _DynamicCheckboxState();
}

class _DynamicCheckboxState extends State<DynamicCheckbox> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicCheckboxBloc(initialComponent: widget.component),
      child: DynamicCheckboxWidget(
        component: widget.component,
      ),
    );
  }
}

class DynamicCheckboxWidget extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicCheckboxWidget({
    super.key,
    required this.component,
  });

  @override
  State<DynamicCheckboxWidget> createState() => _DynamicCheckboxWidgetState();
}

class _DynamicCheckboxWidgetState extends State<DynamicCheckboxWidget> {
  DynamicCheckboxBloc? _checkboxBloc;
  DynamicFormBloc? _formBloc;

  @override
  void initState() {
    super.initState();
    _checkboxBloc = context.read<DynamicCheckboxBloc>();
    _formBloc = context.read<DynamicFormBloc>();
    _checkboxBloc!.add(const InitializeCheckboxEvent());
  }

  @override
  void dispose() {
    _checkboxBloc = null;
    _formBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update checkbox bloc
        if (formState.page?.components != null) {
          final updatedComponent = formState.page!.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          // Check if component state changed from external source
          if (updatedComponent.config['current_state'] != null &&
              updatedComponent.config['current_state'] !=
                  widget.component.config['current_state']) {
            debugPrint(
              '🔄 [Checkbox] External state change detected: ${updatedComponent.config['current_state']}',
            );

            // Update the checkbox bloc with new component state
            _checkboxBloc?.add(
              UpdateCheckboxFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicCheckboxBloc, DynamicCheckboxState>(
        listenWhen: (previous, current) {
          return previous is DynamicCheckboxLoading &&
              current is DynamicCheckboxSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state, error, or form state changes
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              previous.component?.config['current_state'] !=
                  current.component?.config['current_state'];
        },
        listener: (context, state) {
          if (state is DynamicCheckboxSuccess) {
            final valueMap = {
              ValueKeyEnum.value.key:
                  state.component!.config[ValueKeyEnum.value.key],
              'current_state': state.component!.config['current_state'],
              'error_text': state.errorText,
            };

            // Update the main form bloc with new value
            _formBloc?.add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: valueMap,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [Checkbox] Building with state: ${state.runtimeType}, formState: ${state.formState}, errorText: ${state.errorText}',
          );

          if (state is DynamicCheckboxLoading ||
              state is DynamicCheckboxInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicCheckboxError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicCheckboxSuccess) {
            debugPrint(
              '🎯 [Checkbox] Success state - formState: ${state.formState}, isSelected: ${state.isSelected}',
            );
            return _buildBody(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(DynamicCheckboxSuccess state) {
    final String? label = state.component!.config['label'];
    final String? hint = state.component!.config['hint'];

    Widget toggleControl = Container(
      width: state.controlWidth,
      height: state.controlHeight,
      decoration: BoxDecoration(
        color: state.backgroundColor,
        border: Border.all(color: state.borderColor, width: state.borderWidth),
        borderRadius: BorderRadius.circular(state.controlBorderRadius),
      ),
      child: state.isSelected
          ? Icon(
              Icons.check,
              color: state.iconColor,
              size: state.controlWidth * 0.75,
            )
          : null,
    );

    Widget? labelAndHint;
    if (label != null) {
      labelAndHint = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: state.styleConfig?.labelTextSize?.toDouble() ?? 16,
                color: StyleUtils.parseColor(
                  state.component!.style['label_color'],
                ),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: StyleUtils.parseColor(
                      state.component!.style['hint_color'],
                    ),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
    }

    return Focus(
      focusNode: state.focusNode,
      child: GestureDetector(
        onTap: () => _handleTap(state),
        child: Container(
          key: Key(state.component!.id),
          margin: StyleUtils.parsePadding(state.component!.style['margin']),
          padding: StyleUtils.parsePadding(state.component!.style['padding']),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              toggleControl,
              const SizedBox(width: 12),
              if (state.leadingIconData != null) ...[
                Icon(
                  state.leadingIconData,
                  size: 20,
                  color: StyleUtils.parseColor(
                    state.component!.style['icon_color'],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (labelAndHint != null) labelAndHint,
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(DynamicCheckboxSuccess state) {
    FocusScope.of(context).requestFocus(state.focusNode);
    if (!state.isEditable) return;

    debugPrint(
      '[Checkbox][tap] id=${state.component!.id} valueBefore=${state.isSelected}',
    );
    final newValue = !state.isSelected;

    _checkboxBloc?.add(
      CheckboxValueChangedEvent(value: newValue),
    );

    debugPrint(
      '[Checkbox][tap] id=${state.component!.id} valueAfter=$newValue',
    );
    debugPrint('[Checkbox] Save value: ${state.component!.id} = $newValue');
  }
}
