import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_canvas.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_components_panel.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_button_components_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget formBuilderBody(BuildContext context, FormBuilderBloc formBuilderBloc) {
  return BlocConsumer<FormBuilderBloc, FormBuilderState>(
    listener: (context, state) {
      if (state is FormBuilderError) {
        DialogUtils.showErrorDialog(context, state.errorMessage!);
      }
    },
    builder: (context, state) {
      if (state is FormBuilderLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is FormBuilderSuccess) {
        return Column(
          children: [
            if (state.pages.length > 1) _buildProgressBar(state),
            Expanded(child: _buildMainContent(state, formBuilderBloc)),
          ],
        );
      }
      return const Text('Error');
    },
  );
}

Widget _buildProgressBar(FormBuilderState state) {
  final currentPageIndex = state.pages.indexWhere(
    (page) => page.pageId == state.currentPageId,
  );
  final progress = (currentPageIndex + 1) / state.pages.length;
  return Container(
    width: double.infinity,
    height: 4,
    color: Colors.grey[800],
    child: LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.transparent,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
    ),
  );
}

Widget _buildMainContent(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return Stack(
    children: [
      formBuilderCanvas(state, formBuilderBloc),
      if (state.showComponentsPanel)
        formBuilderComponentsPanel(state, formBuilderBloc),
      //Hide it , dont open
      // if (state.showButtonComponentsPanel)
      //   formBuilderButtonComponentsPanel(state, formBuilderBloc),
    ],
  );
}
