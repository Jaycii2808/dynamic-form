import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field_tags/dynamic_text_field_tags_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DynamicTextFieldTags extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicTextFieldTags({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicTextFieldTagsBloc, DynamicTextFieldTagsState>(
      listener: (context, state) {
        final valueMap = {
          ValueKeyEnum.value.key: state.selectedTags,
          ValueKeyEnum.currentState.key:
              state.component!.config[ValueKeyEnum.currentState.key],
          ValueKeyEnum.errorText.key: state.errorText,
        };
        if (state is DynamicTextFieldTagsSuccess) {
          onComplete(valueMap);
        } else if (state is DynamicTextFieldTagsError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicTextFieldTagsLoading ||
            state is DynamicTextFieldTagsInitial) {
          debugPrint('Listener: Handling ${state.runtimeType} state');
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicTextFieldTagsLoading ||
            state is DynamicTextFieldTagsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicTextFieldTagsSuccess) {
          return _buildBody(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    DynamicTextFieldTagsSuccess state,
  ) {
    final style = state.styleConfig!;
    final config = state.inputConfig!;
    final isDisabled = config.disabled;

    return Container(
      key: Key(state.component!.id),
      padding: const EdgeInsets.all(8.0),
      margin: style.margin,
      decoration: BoxDecoration(
        border: Border.all(
          color: StyleUtils.parseColor(
            state.component!.style['border_color'] ?? '#6979F8',
          ),
          width:
              (state.component!.style['border_width'] as num?)?.toDouble() ??
              1.5,
        ),
        borderRadius: StyleUtils.parseBorderRadius(
          state.component!.style['border_radius'] as int?,
        ),
        color: style.fillColor,
      ),
      child: state.isEditing
          ? _buildTagsInputView(context, state)
          : _buildTagsDisplayView(context, state, isDisabled),
    );
  }

  Widget _buildTagsDisplayView(
    BuildContext context,
    DynamicTextFieldTagsSuccess state,
    bool isDisabled,
  ) {
    final textFieldTagsBloc = context.read<DynamicTextFieldTagsBloc>();
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () => textFieldTagsBloc.add(
              const StartEditingTagsEvent(),
            ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        child: state.selectedTags.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  state.inputConfig?.placeholder ?? 'Click to add tags',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            : Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: state.selectedTags
                    .map(
                      (tag) => _buildTagChip(
                        context,
                        tag,
                        state.component!.style,
                        isDisabled,
                        allowRemoval: false,
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildTagsInputView(
    BuildContext context,
    DynamicTextFieldTagsSuccess state,
  ) {
    final textFieldTagsBloc = context.read<DynamicTextFieldTagsBloc>();
    final unselectedTags = state.availableTags
        .where((t) => !state.selectedTags.contains(t))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: state.selectedTags
                  .map(
                    (tag) => _buildTagChip(
                      context,
                      tag,
                      state.component!.style,
                      false,
                    ),
                  )
                  .toList(),
            ),
          ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return unselectedTags;
            }
            return unselectedTags.where(
              (tag) => tag.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          onSelected: (String selection) {
            textFieldTagsBloc.add(
              TagAddedEvent(tag: selection),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  final match = unselectedTags.firstWhere(
                    (tag) => tag.toLowerCase().contains(value.toLowerCase()),
                    orElse: () => '',
                  );
                  if (match.isNotEmpty) {
                    textFieldTagsBloc.add(
                      TagAddedEvent(tag: match),
                    );
                    controller.clear();
                    focusNode.requestFocus();
                  }
                }
              },
              decoration: InputDecoration(
                hintText: state.inputConfig?.placeholder ?? 'Enter tags...',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorText: state.errorText,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              textFieldTagsBloc.add(
                const TagsFinalizedEvent(),
              );
              textFieldTagsBloc.add(
                const DoneEditingTagsEvent(),
              );
            },
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(
    BuildContext context,
    String tag,
    Map<String, dynamic> style,
    bool isDisabled, {
    bool allowRemoval = true,
  }) {
    return Chip(
      label: Text(
        tag,
      ),
      backgroundColor: StyleUtils.parseColor(style['tag_background_color']),
      onDeleted: (allowRemoval && !isDisabled)
          ? () => context.read<DynamicTextFieldTagsBloc>().add(
              TagRemovedEvent(tag: tag),
            )
          : null,
      deleteIcon: SvgPicture.asset(
        'assets/svg/Close.svg',
        width: 14,
        height: 14,
        colorFilter: ColorFilter.mode(
          StyleUtils.parseColor(style['tag_remove_icon_color'] ?? '#F44336'),
          BlendMode.srcIn,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
