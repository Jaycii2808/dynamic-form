import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSelectorButton extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicSelectorButton({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicSelectorButtonBloc, DynamicSelectorButtonState>(
      listener: (context, state) {
        final valueMap = {
          ValueKeyEnum.value.key:
              state.component!.config[ValueKeyEnum.value.key],
          'selected': state.component!.config['selected'],
          ValueKeyEnum.currentState.key:
              state.component!.config[ValueKeyEnum.currentState.key],
        };
        if (state is DynamicSelectorButtonSuccess) {
          onComplete(valueMap);
        } else if (state is DynamicSelectorButtonError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicSelectorButtonLoading ||
            state is DynamicSelectorButtonInitial) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config[ValueKeyEnum.value.key]}',
          );
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicSelectorButtonLoading ||
            state is DynamicSelectorButtonInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicSelectorButtonSuccess) {
          return _buildBody(
            context,
            state.styleConfig!,
            state.inputConfig!,
            state.component!,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
  ) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final selected =
        config['selected'] == true || config[ValueKeyEnum.value.key] == true;
    final isDisabled = config['disabled'] == true;
    final currentState =
        FormStateEnum.fromString(inputConfig.currentState) ??
        FormStateEnum.base;

    if (component.states?.containsKey(currentState.value) == true) {
      style.addAll(component.states![currentState.value]['style']);
    }

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                context.read<DynamicSelectorButtonBloc>().add(
                  SelectorButtonToggledEvent(isSelected: !selected),
                );
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: (style['icon_size'] as num?)?.toDouble() ?? 20.0,
              height: (style['icon_size'] as num?)?.toDouble() ?? 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StyleUtils.parseColor(style['background_color']),
                border: Border.all(
                  color: StyleUtils.parseColor(style['border_color']),
                  width: (style['border_width'] as num?)?.toDouble() ?? 2.0,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size:
                          ((style['icon_size'] as num?)?.toDouble() ?? 20.0) *
                          0.6,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (hasLabel)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  config['label'],
                  style: TextStyle(
                    fontSize: style['label_text_size']?.toDouble() ?? 16,
                    //color: StyleUtils.parseColor(style['label_color']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
