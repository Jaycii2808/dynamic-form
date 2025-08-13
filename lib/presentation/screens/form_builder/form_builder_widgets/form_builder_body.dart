import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_canvas.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_components_panel.dart';
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
      if (state is FormBuilderLoading || state is FormBuilderInitial) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is FormBuilderSuccess) {
        return _buildMainContent(state, formBuilderBloc);
      }
      return const Text('Error');
    },
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
    ],
  );
}
