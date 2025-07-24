// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/variants/variants_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';

import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_select/dynamic_select_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_select/dynamic_select_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_select/dynamic_select_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSelect extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSelect({super.key, required this.component});

  @override
  State<DynamicSelect> createState() => _DynamicSelectState();
}

class _DynamicSelectState extends State<DynamicSelect> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicSelectBloc(initialComponent: widget.component),
      child: DynamicSelectWidget(
        component: widget.component,
      ),
    );
  }
}

class DynamicSelectWidget extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSelectWidget({
    super.key,
    required this.component,
  });

  @override
  State<DynamicSelectWidget> createState() => _DynamicSelectWidgetState();
}

class _DynamicSelectWidgetState extends State<DynamicSelectWidget> {
  @override
  void initState() {
    super.initState();
    context.read<DynamicSelectBloc>().add(const InitializeSelectEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update select bloc
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
              '🔄 [Select] External state change detected: ${updatedComponent.config['current_state']}',
            );

            // Update the select bloc with new component state
            context.read<DynamicSelectBloc>().add(
              UpdateSelectFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicSelectBloc, DynamicSelectState>(
        listenWhen: (previous, current) {
          return current is DynamicSelectSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state, error, dropdown state, or form state changes
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              (previous is DynamicSelectSuccess &&
                  current is DynamicSelectSuccess &&
                  (previous.isDropdownOpen != current.isDropdownOpen ||
                      previous.selectedValue != current.selectedValue));
        },
        listener: (context, state) {
          if (state is DynamicSelectSuccess) {
            // Update main form with new value
            final valueMap = {
              ValueKeyEnum.value.key: state.selectedValue,
              'current_state': state.formState?.name ?? 'base',
              'error_text': state.errorText,
            };

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
            '🔵 [Select] Building with state: ${state.runtimeType}, formState: ${state.formState}',
          );

          if (state is DynamicSelectLoading || state is DynamicSelectInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicSelectError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicSelectSuccess) {
            debugPrint(
              '🎯 [Select] Success state - formState: ${state.formState}',
            );
            return _buildBody(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DynamicSelectSuccess state) {
    final styleModel = StyleModel.fromJson(state.component!.style.toJson());
    return Container(
      key: Key(state.component!.id),
      margin: StyleUtils.parsePadding(styleModel.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (state.component!.config['label'] != null) _buildLabel(state),

          // Select field
          GestureDetector(
            key: state.selectKey,
            onTap: state.isDisabled ? null : () => _handleSelectTap(state),
            child: _buildSelectField(state),
          ),

          // Helper text
          if (_getHelperText(state) != null) _buildHelperText(state)!,
        ],
      ),
    );
  }

  Widget _buildLabel(DynamicSelectSuccess state) {
    final styleModel = StyleModel.fromJson(state.component!.style.toJson());
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        state.component!.config['label'],
        style: TextStyle(
          fontSize: styleModel.labelTextSize?.toDouble() ?? 14,
          color: StyleUtils.parseColor(styleModel.labelColor),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectField(DynamicSelectSuccess state) {
    final styleModel = StyleModel.fromJson(state.component!.style.toJson());

    return Container(
      padding: StyleUtils.parsePadding(styleModel.padding),
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(styleModel.backgroundColor),
        border: Border.all(
          color: StyleUtils.parseColor(styleModel.borderColor),
          width: 1.0,
        ),
        borderRadius: StyleUtils.parseBorderRadius(styleModel.borderRadius),
      ),
      child: Row(
        children: [
          if (_getPrefixIcon(state) != null) ...[
            _getPrefixIcon(state)!,
            const SizedBox(width: 8),
          ],
          Expanded(child: _buildDisplayContent(state, styleModel)),
          if (_getSuffixIcon(state) != null) ...[
            const SizedBox(width: 8),
            _getSuffixIcon(state)!,
          ],
        ],
      ),
    );
  }

  Widget _buildDisplayContent(
    DynamicSelectSuccess state,
    StyleModel styleModel,
  ) {
    final textStyle = TextStyle(
      fontSize: styleModel.fontSize?.toDouble() ?? 16,
      color: StyleUtils.parseColor(styleModel.color),
      fontStyle: styleModel.fontStyle == 'italic'
          ? FontStyle.italic
          : FontStyle.normal,
    );

    if (state.isMultiple) {
      String displayText = 'Select options';
      if (state.selectedValue is List &&
          (state.selectedValue as List).isNotEmpty) {
        final selectedValues = state.selectedValue as List;
        final selectedLabels = selectedValues.map((value) {
          final option = state.options.firstWhere(
            (opt) => opt['value'] == value,
            orElse: () => {'label': value},
          );
          return option['label'] ?? value;
        }).toList();
        displayText = selectedLabels.join(', ');
      }
      return Text(displayText, style: textStyle);
    } else {
      if (state.selectedValue != null &&
          state.selectedValue.toString().isNotEmpty) {
        final option = state.options.firstWhere(
          (opt) => opt['value'] == state.selectedValue,
          orElse: () => {'label': state.selectedValue},
        );
        final displayText = option['label'] ?? state.selectedValue;

        if (option['avatar'] != null) {
          return Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(option['avatar']),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(displayText, style: textStyle)),
            ],
          );
        } else {
          return Text(displayText, style: textStyle);
        }
      } else {
        return Text(
          state.component!.config['placeholder'] ?? 'Select option',
          style: textStyle.copyWith(
            color: StyleUtils.parseColor(
              styleModel.color,
            ).withValues(alpha: 0.6),
          ),
        );
      }
    }
  }

  Widget? _buildHelperText(DynamicSelectSuccess state) {
    final helperText = _getHelperText(state);
    if (helperText == null || helperText.isEmpty) return null;

    final styleModel = StyleModel.fromJson(state.component!.style.toJson());

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        helperText,
        style: TextStyle(
          fontSize: 12,
          color: StyleUtils.parseColor(styleModel.helperTextColor),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // Helper methods
  Map<String, dynamic> _getAppliedStyle(DynamicSelectSuccess state) {
    // This method can be refactored to return a StyleModel if all merging logic is handled in model or utility
    return state.component!.style.toJson();
  }

  String _getStateKey(ComponentStateEnum? formState) {
    switch (formState) {
      case ComponentStateEnum.error:
        return 'error';
      case ComponentStateEnum.success:
        return 'success';
      case ComponentStateEnum.focused:
        return 'focused';
      default:
        return 'base';
    }
  }

  StyleStatesModel? _getTypedStateStyle(StatesModel? states, String key) {
    switch (key) {
      case 'base':
        return states?.base;
      case 'error':
        return states?.error;
      case 'success':
        return states?.success;
      case 'focused':
        return states?.focused;
      default:
        return null;
    }
  }

  Widget? _getPrefixIcon(DynamicSelectSuccess state) {
    final styleModel = StyleModel.fromJson(state.component!.style.toJson());

    if ((state.component!.config['icon'] != null || styleModel.icon != null) &&
        styleModel.iconPosition != 'right') {
      final iconName =
          (styleModel.icon ?? state.component!.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(styleModel.iconColor);
      final iconSize = (styleModel.iconSize is num)
          ? (styleModel.iconSize as num).toDouble()
          : 20.0;
      final iconData = IconTypeEnum.fromString(iconName).toIconData();
      if (iconData != null) {
        return Icon(iconData, color: iconColor, size: iconSize);
      }
    }
    return null;
  }

  Widget? _getSuffixIcon(DynamicSelectSuccess state) {
    final styleModel = StyleModel.fromJson(state.component!.style.toJson());

    if ((state.component!.config['icon'] != null || styleModel.icon != null) &&
        styleModel.iconPosition == 'right') {
      final iconName =
          (styleModel.icon ?? state.component!.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(styleModel.iconColor);
      final iconSize = (styleModel.iconSize is num)
          ? (styleModel.iconSize as num).toDouble()
          : 20.0;
      final iconData = IconTypeEnum.fromString(iconName).toIconData();
      if (iconData != null) {
        return Icon(iconData, color: iconColor, size: iconSize);
      }
    }
    return null;
  }

  String? _getHelperText(DynamicSelectSuccess state) {
    final styleModel = StyleModel.fromJson(state.component!.style.toJson());
    return styleModel.helperText?.toString();
  }

  // Event handlers
  void _handleSelectTap(DynamicSelectSuccess state) {
    debugPrint('👆 [Select] Field tapped');

    FocusScope.of(context).requestFocus(state.focusNode);

    // Calculate dropdown position
    final RenderBox? renderBox =
        state.selectKey!.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final position = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      size.height,
    );

    if (state.isDropdownOpen) {
      context.read<DynamicSelectBloc>().add(const CloseDropdownEvent());
    } else {
      context.read<DynamicSelectBloc>().add(
        OpenDropdownEvent(position: position, context: context),
      );
    }
  }
}
