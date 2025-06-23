import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFormBloc extends Bloc<DynamicFormEvent, DynamicFormState> {
  final RemoteConfigService _remoteConfigService;

  DynamicFormBloc({required RemoteConfigService remoteConfigService})
    : _remoteConfigService = remoteConfigService,
      super(const DynamicFormInitial()) {
    on<LoadDynamicFormPageEvent>(_onLoadDynamicFormPage);
  }

  Future<void> _onLoadDynamicFormPage(
    LoadDynamicFormPageEvent event,
    Emitter<DynamicFormState> emit,
  ) async {
    //delay 0.5s

    emit(DynamicFormLoading.fromState(state: state));
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final page = _remoteConfigService.getConfigKey(event.configKey);
      if (page != null) {
        emit(DynamicFormSuccess.fromState(state: state, page: page));
      } else {
        throw Exception('Form not found');
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to load form: $e';
      debugPrint('Error: $e, StackTrace: $stackTrace');
      emit(DynamicFormError(errorMessage: errorMessage));
    }
  }
}
