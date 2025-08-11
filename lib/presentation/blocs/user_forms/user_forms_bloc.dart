import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart';
import 'package:dynamic_form_bi/core/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_state.dart';
import 'package:flutter/foundation.dart';

class UserFormsBloc extends Bloc<UserFormsEvent, UserFormsState> {
  final UserFormsService _userFormsService;
  final RemoteConfigService _remoteConfigService;

  UserFormsBloc({
    required UserFormsService userFormsService,
    required RemoteConfigService remoteConfigService,
  }) : _userFormsService = userFormsService,
       _remoteConfigService = remoteConfigService,
       super(const UserFormsInitial()) {
    on<LoadUserFormsEvent>(_onLoadUserForms);
    on<SaveUserFormEvent>(_onSaveUserForm);
    on<UpdateUserFormEvent>(_onUpdateUserForm);
    on<DeleteUserFormEvent>(_onDeleteUserForm);
    on<CreateUserFormFromTemplateEvent>(_onCreateUserFormFromTemplate);
    on<LoadFormTemplatesEvent>(_onLoadFormTemplates);
  }

  Future<void> _onLoadUserForms(
    LoadUserFormsEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      debugPrint('🔄 [UserFormsBloc] Loading user forms');

      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      debugPrint('✅ [UserFormsBloc] Loaded ${userForms.length} user forms');

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsBloc] Error loading user forms: $e');
      debugPrint('❌ [UserFormsBloc] Stack trace: $stackTrace');

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to load user forms: $e',
        ),
      );
    }
  }

  Future<void> _onSaveUserForm(
    SaveUserFormEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      debugPrint(
        '🔄 [UserFormsBloc] Saving user form: ${event.formBuilderModel.name}',
      );

      final formId = await _userFormsService.saveUserForm(
        formBuilderModel: event.formBuilderModel,
        userId: event.userId,
      );

      debugPrint('✅ [UserFormsBloc] User form saved with ID: $formId');

      // Reload user forms after saving
      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsBloc] Error saving user form: $e');
      debugPrint('❌ [UserFormsBloc] Stack trace: $stackTrace');

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to save user form: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateUserForm(
    UpdateUserFormEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      debugPrint('🔄 [UserFormsBloc] Updating user form: ${event.formId}');

      await _userFormsService.updateUserForm(
        formId: event.formId,
        formBuilderModel: event.formBuilderModel,
        userId: event.userId,
      );

      debugPrint('✅ [UserFormsBloc] User form updated: ${event.formId}');

      // Reload user forms after updating
      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsBloc] Error updating user form: $e');
      debugPrint('❌ [UserFormsBloc] Stack trace: $stackTrace');

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to update user form: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteUserForm(
    DeleteUserFormEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      debugPrint('🔄 [UserFormsBloc] Deleting user form: ${event.formId}');

      await _userFormsService.deleteUserForm(
        formId: event.formId,
        userId: event.userId,
      );

      debugPrint('✅ [UserFormsBloc] User form deleted: ${event.formId}');

      // Reload user forms after deleting
      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsBloc] Error deleting user form: $e');
      debugPrint('❌ [UserFormsBloc] Stack trace: $stackTrace');

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to delete user form: $e',
        ),
      );
    }
  }

  Future<void> _onCreateUserFormFromTemplate(
    CreateUserFormFromTemplateEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      debugPrint(
        '🔄 [UserFormsBloc] Creating user form from template: ${event.templateName}',
      );

      final formId = await _userFormsService.createUserFormFromTemplate(
        templateData: event.templateData,
        templateName: event.templateName,
        userId: event.userId,
      );

      debugPrint(
        '✅ [UserFormsBloc] User form created from template with ID: $formId',
      );

      // Reload user forms after creating
      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [UserFormsBloc] Error creating user form from template: $e',
      );
      debugPrint('❌ [UserFormsBloc] Stack trace: $stackTrace');

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to create user form from template: $e',
        ),
      );
    }
  }

  Future<void> _onLoadFormTemplates(
    LoadFormTemplatesEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      debugPrint(
        '🔄 [UserFormsBloc] Loading form templates from Remote Config',
      );

      // Load form templates from Remote Config
      final formTemplates = await _loadFormTemplatesFromRemoteConfig();

      debugPrint(
        '✅ [UserFormsBloc] Loaded ${formTemplates.length} form templates',
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          formTemplates: formTemplates,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsBloc] Error loading form templates: $e');
      debugPrint('❌ [UserFormsBloc] Stack trace: $stackTrace');

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to load form templates: $e',
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>>
  _loadFormTemplatesFromRemoteConfig() async {
    try {
      // Get form templates from Remote Config
      final templatesJson = _remoteConfigService.getString('form_templates');

      if (templatesJson.isEmpty) {
        debugPrint(
          '⚠️ [UserFormsBloc] No form templates found in Remote Config',
        );
        return [];
      }

      final templates = List<Map<String, dynamic>>.from(
        jsonDecode(templatesJson),
      );

      debugPrint(
        '🔄 [UserFormsBloc] Parsed ${templates.length} templates from Remote Config',
      );
      return templates;
    } catch (e) {
      debugPrint('❌ [UserFormsBloc] Error parsing form templates: $e');
      return [];
    }
  }
}
