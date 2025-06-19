import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/remote_config_service.dart';
import '../../core/models/ui_component_model.dart';
import 'ui_event.dart';
import 'ui_state.dart';

// BLoC
class UIBloc extends Bloc<UIEvent, UIState> {
  final RemoteConfigService _remoteConfigService;

  UIBloc({required RemoteConfigService remoteConfigService})
    : _remoteConfigService = remoteConfigService,
      super(UIInitial()) {
    on<LoadUIPage>(_onLoadUIPage);
    on<RefreshUIPage>(_onRefreshUIPage);
  }

  Future<void> _onLoadUIPage(LoadUIPage event, Emitter<UIState> emit) async {
    emit(UILoading());
    try {
      final page = _remoteConfigService.getUIPage();
      if (page != null) {
        emit(UILoaded(page: page));
      } else {
        emit(UIEmpty());
      }
    } catch (e) {
      emit(UIError(message: 'Failed to load UI page: $e'));
    }
  }

  Future<void> _onRefreshUIPage(
    RefreshUIPage event,
    Emitter<UIState> emit,
  ) async {
    try {
      final page = _remoteConfigService.getUIPage();
      if (page != null) {
        emit(UILoaded(page: page));
      } else {
        emit(UIEmpty());
      }
    } catch (e) {
      emit(UIError(message: 'Failed to refresh UI page: $e'));
    }
  }
}
