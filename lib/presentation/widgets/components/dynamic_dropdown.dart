// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_dropdown/dynamic_dropdown_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_dropdown/dynamic_dropdown_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_dropdown/dynamic_dropdown_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDropdown extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicDropdown({super.key, required this.component});

  @override
  State<DynamicDropdown> createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicDropdownBloc(initialComponent: widget.component),
      child: DynamicDropdownWidget(
        component: widget.component,
      ),
    );
  }
}

class DynamicDropdownWidget extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicDropdownWidget({super.key, required this.component});

  @override
  State<DynamicDropdownWidget> createState() => _DynamicDropdownWidgetState();
}

class _DynamicDropdownWidgetState extends State<DynamicDropdownWidget> {
  final GlobalKey dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<DynamicDropdownBloc>().add(const InitializeDropdownEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update dropdown bloc
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
              '🔄 [Dropdown] External state change detected: ${updatedComponent.config['current_state']}',
            );

            // Update the dropdown bloc with new component state
            context.read<DynamicDropdownBloc>().add(
              UpdateDropdownFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicDropdownBloc, DynamicDropdownState>(
        listenWhen: (previous, current) {
          return (previous is DynamicDropdownLoading &&
                  current is DynamicDropdownSuccess) ||
              (previous is DynamicDropdownSuccess &&
                  current is DynamicDropdownSuccess &&
                  previous.selectionTimestamp != current.selectionTimestamp);
        },
        buildWhen: (previous, current) {
          // Rebuild when state, error, form state, or selection changes
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              previous.component?.config['current_state'] !=
                  current.component?.config['current_state'] ||
              (previous is DynamicDropdownSuccess &&
                  current is DynamicDropdownSuccess &&
                  (previous.currentValue != current.currentValue ||
                      previous.displayLabel != current.displayLabel ||
                      previous.selectionTimestamp !=
                          current.selectionTimestamp));
        },
        listener: (context, state) {
          if (state is DynamicDropdownSuccess) {
            final valueMap = {
              ValueKeyEnum.value.key: state.currentValue,
              'current_state': state.component!.config['current_state'],
              'error_text': state.errorText,
            };

            // Update the main form bloc with new value
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: valueMap,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [Dropdown] Building with state: ${state.runtimeType}, formState: ${state.formState}, errorText: ${state.errorText}',
          );

          if (state is DynamicDropdownLoading ||
              state is DynamicDropdownInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicDropdownError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicDropdownSuccess) {
            debugPrint(
              '🎯 [Dropdown] Success state - formState: ${state.formState}, currentState: ${state.component?.config['current_state']}',
            );
            return _buildDropdown(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDropdown(DynamicDropdownSuccess state) {
    return Focus(
      focusNode: state.focusNode,
      child: MouseRegion(
        child: InkWell(
          key: dropdownKey,
          onTap: state.isDisabled ? null : () => _handleTap(state),
          child: Container(
            padding: StyleUtils.parsePadding(state.computedStyle['padding']),
            margin: StyleUtils.parsePadding(state.computedStyle['margin']),
            decoration: BoxDecoration(
              color: StyleUtils.parseColor(
                state.computedStyle['background_color'],
              ),
              border: Border.all(
                color: StyleUtils.parseColor(
                  state.computedStyle['border_color'],
                ),
                width:
                    (state.computedStyle['border_width'] as num?)?.toDouble() ??
                    1.0,
              ),
              borderRadius: StyleUtils.parseBorderRadius(
                state.computedStyle['border_radius'],
              ),
            ),
            child: state.triggerContent,
          ),
        ),
      ),
    );
  }

  void _handleTap(DynamicDropdownSuccess state) {
    if (state.focusNode != null) {
      FocusScope.of(context).requestFocus(state.focusNode);
    }

    if (state.isDropdownOpen) {
      // Close dropdown if already open
      context.read<DynamicDropdownBloc>().add(const CloseDropdownEvent());
    } else {
      // Calculate position and open dropdown
      final renderBox =
          dropdownKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);

      context.read<DynamicDropdownBloc>().add(
        OpenDropdownEvent(
          position: Rect.fromLTWH(
            offset.dx,
            offset.dy,
            size.width,
            size.height,
          ),
          context: context,
        ),
      );
    }
  }

  // 🎯 Widget now only renders trigger and dispatches events
  // Overlay management moved to Bloc!
}
