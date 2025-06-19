import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/text_input/text_input_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/text_input/text_input_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextInputBloc extends Bloc<TextInputEvent, TextInputState> {
  final RemoteConfigService _remoteConfigService;

  TextInputBloc({required RemoteConfigService remoteConfigService})
      : _remoteConfigService = remoteConfigService,
        super(const TextInputInitial()) {
    on<LoadTextInputPageEvent>(_onLoadTextInputPage);
  }

  // Handle page load event
  Future<void> _onLoadTextInputPage(
      LoadTextInputPageEvent event,
      Emitter<TextInputState> emit,
      ) async {
    emit(TextInputLoading.fromState(state: state));
    try {
      final page = _remoteConfigService.getTextInputScreen();
      if (page != null) {
        emit(TextInputSuccess.fromState(state: state, page: page));
      } else {
        throw Exception('No UI components found');
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to load UI page: $e';
      debugPrint('Error: $e, StackTrace: $stackTrace');
      emit(TextInputError(errorMessage: errorMessage));
    }
  }


}