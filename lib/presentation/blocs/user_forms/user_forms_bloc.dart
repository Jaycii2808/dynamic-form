import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/services/user_forms_service.dart';
import 'package:dynamic_form_bi/core/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/user_forms/user_forms_state.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';

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
    on<ImportFormFromJsonEvent>(_onImportFormFromJson);
    on<ClearImportedFormEvent>(_onClearImportedForm);
    on<OpenFormForEditEvent>(_onOpenFormForEdit);
    on<ClearOpenFormEvent>(_onClearOpenForm);
  }

  Future<void> _onLoadUserForms(
    LoadUserFormsEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e) {
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
      await _userFormsService.saveUserForm(
        formBuilderModel: event.formBuilderModel,
        userId: event.userId,
      );

      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e) {
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
      await _userFormsService.updateUserForm(
        formId: event.formId,
        formBuilderModel: event.formBuilderModel,
        userId: event.userId,
      );

      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e) {
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
      await _userFormsService.deleteUserForm(
        formId: event.formId,
        userId: event.userId,
      );

      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e) {
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
      await _userFormsService.createUserFormFromTemplate(
        templateData: event.templateData,
        templateName: event.templateName,
        userId: event.userId,
      );

      final userForms = await _userFormsService.getUserForms(
        userId: event.userId,
      );

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          userForms: userForms,
        ),
      );
    } catch (e) {
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
      final formTemplates = await _loadFormTemplatesFromRemoteConfig();

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(
          formTemplates: formTemplates,
        ),
      );
    } catch (e) {
      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to load form templates: $e',
        ),
      );
    }
  }

  Future<void> _onImportFormFromJson(
    ImportFormFromJsonEvent event,
    Emitter<UserFormsState> emit,
  ) async {
    emit(UserFormsLoading.fromState(state: state));
    try {
      final trimmed = event.rawJson.trim();
      if (trimmed.isEmpty) {
        throw const FormatException('JSON is empty');
      }

      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid JSON format: root must be an object',
        );
      }

      final parsedModel = FormBuilderModel.fromJson(decoded);

      final pagesExcludingSubmit = parsedModel.pages
          .where((p) => !p.title.toLowerCase().contains('submit'))
          .toList();

      List<FormBuilderPageModel> sanitizedPages = pagesExcludingSubmit.map((
        page,
      ) {
        final filteredComponents = page.components.where((component) {
          if (component.type != FormTypeEnum.buttonFormType) return true;
          final action = component.config?.action;
          if (action == null) return true;
          return action != ButtonAction.nextPage.value &&
              action != ButtonAction.previousPage.value &&
              action != ButtonAction.submitForm.value;
        }).toList();
        return page.copyWith(components: filteredComponents);
      }).toList();

      if (sanitizedPages.isEmpty) {
        sanitizedPages = const [
          FormBuilderPageModel(
            pageId: 'page_1',
            title: 'Form Page',
            order: 1,
            showPreviousButton: false,
            showNextButton: false,
            showSubmitButton: true,
            components: [],
          ),
        ];
      }

      final model = parsedModel.copyWith(pages: sanitizedPages);

      emit(
        UserFormsSuccess.fromState(state: state).copyWith(importedForm: model),
      );
    } catch (e) {
      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to import JSON: $e',
        ),
      );
    }
  }

  void _onClearImportedForm(
    ClearImportedFormEvent event,
    Emitter<UserFormsState> emit,
  ) {
    emit(UserFormsSuccess.fromState(state: state).copyWith(importedForm: null));
  }

  void _onOpenFormForEdit(
    OpenFormForEditEvent event,
    Emitter<UserFormsState> emit,
  ) {
    try {
      final form = event.form;
      final String? formId = form['formId'] as String?;

      if (formId != null && formId.isNotEmpty) {
        emit(
          UserFormsSuccess.fromState(
            state: state,
          ).copyWith(openFormId: formId, openFormModel: null),
        );
        return;
      }

      if (form['formData'] != null) {
        final formData = form['formData'] as Map<String, dynamic>;
        final formBuilderModel = FormBuilderModel.fromJson(formData);
        emit(
          UserFormsSuccess.fromState(
            state: state,
          ).copyWith(openFormId: null, openFormModel: formBuilderModel),
        );
        return;
      }

      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Error: Form data not found',
        ),
      );
    } catch (e) {
      emit(
        UserFormsError.fromState(
          state: state,
          errorMessage: 'Failed to prepare form for editing: $e',
        ),
      );
    }
  }

  void _onClearOpenForm(
    ClearOpenFormEvent event,
    Emitter<UserFormsState> emit,
  ) {
    emit(
      UserFormsSuccess.fromState(
        state: state,
      ).copyWith(openFormId: null, openFormModel: null),
    );
  }

  Future<List<Map<String, dynamic>>>
  _loadFormTemplatesFromRemoteConfig() async {
    try {
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
