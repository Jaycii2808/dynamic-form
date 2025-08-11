import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/validation/short_answer_validation_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_event.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_state.dart';

// BLoC
class ShortAnswerFormBuilderWidgetBloc
    extends
        Bloc<
          ShortAnswerFormBuilderWidgetEvent,
          ShortAnswerFormBuilderWidgetState
        > {
  ShortAnswerFormBuilderWidgetBloc()
    : super(
        const ShortAnswerFormBuilderWidgetInitial(
          component: DynamicFormModel(
            id: '',
            type: FormTypeEnum.shortAnswerFormType,
            order: 0,
            config: ConfigModel(),
            style: StyleModel(),
          ),
          question: '',
          description: '',
          isRequired: false,
          isEditingDescription: false,
          isDescriptionEnabled: false,
          validation: ShortAnswerValidationModel(),
          isValidationPanelVisible: false,
        ),
      ) {
    on<InitializeShortAnswerFormBuilderEvent>(_onInitialize);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateRequiredEvent>(_onUpdateRequired);
    on<SetEditingDescriptionEvent>(_onSetEditingDescription);
    on<CancelEditDescriptionEvent>(_onCancelEditDescription);
    on<ToggleDescriptionEnabledEvent>(_onToggleDescriptionEnabled);
    on<ClearDescriptionEvent>(_onClearDescription);
    on<ToggleValidationPanelEvent>(_onToggleValidationPanel);
    on<UpdateValidationTypeEvent>(_onUpdateValidationType);
    on<UpdateNumberActionEvent>(_onUpdateNumberAction);
    on<UpdateTextActionEvent>(_onUpdateTextAction);
    on<UpdateLengthTypeEvent>(_onUpdateLengthType);
    on<UpdateRegexActionEvent>(_onUpdateRegexAction);
    on<UpdateValidationValueEvent>(_onUpdateValidationValue);
    on<UpdateValidationErrorMessageEvent>(_onUpdateValidationErrorMessage);
    on<UpdateValidationSecondValueEvent>(_onUpdateValidationSecondValue);
  }

  Future<void> _onInitialize(
    InitializeShortAnswerFormBuilderEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) async {
    emit(ShortAnswerFormBuilderWidgetLoading.fromState(state: state));

    try {
      final component = event.component;
      final question = component.config?.label ?? '';
      final description = component.config?.description ?? '';
      final isRequired = component.config?.isRequired ?? false;

      // Parse validation from component config
      ShortAnswerValidationModel validation =
          const ShortAnswerValidationModel();
      if (component.config?.validate != null) {
        validation = ShortAnswerValidationModel.fromJson(
          component.config!.validate!,
        );
      }

      // Set description enabled only if there's actual description content
      final isDescriptionEnabled = description.isNotEmpty;

      emit(
        ShortAnswerFormBuilderWidgetSuccess(
          component: component,
          question: question,
          description: description,
          isRequired: isRequired,
          isEditingDescription: false,
          isDescriptionEnabled: isDescriptionEnabled,
          validation: validation,
          availablePages: event.availablePages,
          isValidationPanelVisible: false,
        ),
      );
    } catch (e) {
      emit(
        ShortAnswerFormBuilderWidgetError(
          component: state.component,
          question: state.question,
          description: state.description,
          isRequired: state.isRequired,
          isEditingDescription: state.isEditingDescription,
          isDescriptionEnabled: state.isDescriptionEnabled,
          validation: state.validation,
          availablePages: state.availablePages,
          errorMessage: 'Failed to initialize: $e',
          isValidationPanelVisible: state.isValidationPanelVisible,
        ),
      );
    }
  }

  void _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      emit(currentState.copyWith(question: event.question));
    }
  }

  void _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final isDescriptionEnabled = event.description.isNotEmpty;
      emit(
        currentState.copyWith(
          description: event.description,
          isDescriptionEnabled: isDescriptionEnabled,
        ),
      );
    }
  }

  void _onUpdateRequired(
    UpdateRequiredEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      emit(currentState.copyWith(isRequired: event.isRequired));
    }
  }

  void _onSetEditingDescription(
    SetEditingDescriptionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      emit(currentState.copyWith(isEditingDescription: event.isEditing));
    }
  }

  void _onCancelEditDescription(
    CancelEditDescriptionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      emit(currentState.copyWith(isEditingDescription: false));
    }
  }

  void _onClearDescription(
    ClearDescriptionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      emit(
        currentState.copyWith(
          description: '',
          isDescriptionEnabled: false,
          isEditingDescription: false,
        ),
      );
    }
  }

  void _onToggleValidationPanel(
    ToggleValidationPanelEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      emit(currentState.copyWith(isValidationPanelVisible: event.visible));
    }
  }

  void _onToggleDescriptionEnabled(
    ToggleDescriptionEnabledEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final newEnabled = !currentState.isDescriptionEnabled;
      if (newEnabled) {
        // Enable description and start editing
        final newState = currentState.copyWith(
          isDescriptionEnabled: true,
          isEditingDescription: true,
        );
        emit(newState);
      } else {
        // Disable description, clear it, and stop editing
        emit(
          currentState.copyWith(
            isDescriptionEnabled: false,
            isEditingDescription: false,
            description: '',
          ),
        );
      }
    }
  }

  void _onUpdateValidationType(
    UpdateValidationTypeEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final prev = currentState.validation;

      ShortAnswerValidationModel updatedValidation;
      final type = event.validationType;

      if (type == null) {
        // Clear entire validation when no type is selected
        updatedValidation = const ShortAnswerValidationModel();
      } else {
        switch (type) {
          case ShortAnswerValidationType.number:
            // Reset to number context; clear other types and values
            updatedValidation = ShortAnswerValidationModel(
              validationType: ShortAnswerValidationType.number,
              numberAction: null,
              // Keep custom error if any
              errorMessage: prev.errorMessage,
            );
            break;
          case ShortAnswerValidationType.text:
            // Reset to text context; clear number/length/regex and values
            updatedValidation = ShortAnswerValidationModel(
              validationType: ShortAnswerValidationType.text,
              textAction: null,
              errorMessage: prev.errorMessage,
            );
            break;
          case ShortAnswerValidationType.length:
            // Reset to length context
            updatedValidation = ShortAnswerValidationModel(
              validationType: ShortAnswerValidationType.length,
              lengthType: null,
              errorMessage: prev.errorMessage,
            );
            break;
          case ShortAnswerValidationType.regularExpression:
            // Reset to regex context
            updatedValidation = ShortAnswerValidationModel(
              validationType: ShortAnswerValidationType.regularExpression,
              regexAction: null,
              errorMessage: prev.errorMessage,
            );
            break;
        }
      }

      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateNumberAction(
    UpdateNumberActionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final prev = currentState.validation;

      ShortAnswerValidationModel updatedValidation;
      final action = event.action;

      if (action == null) {
        // Clear number action and related values
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          errorMessage: prev.errorMessage,
        );
      } else if (action == NumberValidationAction.wholeNumber) {
        // No target values needed
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          numberAction: action,
          errorMessage: prev.errorMessage,
        );
      } else if (action == NumberValidationAction.between ||
          action == NumberValidationAction.notBetween) {
        // Range requires two values; preserve if any
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          numberAction: action,
          validationValue: prev.validationValue,
          validationSecondValue: prev.validationSecondValue,
          errorMessage: prev.errorMessage,
        );
      } else {
        // Single target value; clear second value
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          numberAction: action,
          validationValue: prev.validationValue,
          errorMessage: prev.errorMessage,
        );
      }

      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateTextAction(
    UpdateTextActionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final prev = currentState.validation;

      ShortAnswerValidationModel updatedValidation;
      final action = event.action;

      if (action == null) {
        // Clear text action and its value
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          errorMessage: prev.errorMessage,
        );
      } else if (action == TextValidationAction.emailAddress ||
          action == TextValidationAction.url) {
        // Pattern-based actions; value is not needed
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          textAction: action,
          errorMessage: prev.errorMessage,
        );
      } else {
        // contains / doesNotContain require a value
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          textAction: action,
          validationValue: prev.validationValue,
          errorMessage: prev.errorMessage,
        );
      }

      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateLengthType(
    UpdateLengthTypeEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final prev = currentState.validation;

      final type = event.lengthType;
      ShortAnswerValidationModel updatedValidation;

      if (type == null) {
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          errorMessage: prev.errorMessage,
        );
      } else {
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          lengthType: type,
          validationValue: prev.validationValue,
          errorMessage: prev.errorMessage,
        );
      }

      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateRegexAction(
    UpdateRegexActionEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final prev = currentState.validation;

      final action = event.action;
      ShortAnswerValidationModel updatedValidation;

      if (action == null) {
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          errorMessage: prev.errorMessage,
        );
      } else {
        updatedValidation = ShortAnswerValidationModel(
          validationType: prev.validationType,
          regexAction: action,
          validationValue: prev.validationValue,
          errorMessage: prev.errorMessage,
        );
      }

      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateValidationValue(
    UpdateValidationValueEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final updatedValidation = currentState.validation.copyWith(
        validationValue: event.value,
      );
      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateValidationErrorMessage(
    UpdateValidationErrorMessageEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final updatedValidation = currentState.validation.copyWith(
        errorMessage: event.errorMessage,
      );
      emit(currentState.copyWith(validation: updatedValidation));
    }
  }

  void _onUpdateValidationSecondValue(
    UpdateValidationSecondValueEvent event,
    Emitter<ShortAnswerFormBuilderWidgetState> emit,
  ) {
    if (state is ShortAnswerFormBuilderWidgetSuccess) {
      final currentState = state as ShortAnswerFormBuilderWidgetSuccess;
      final updatedValidation = currentState.validation.copyWith(
        validationSecondValue: event.value,
      );
      emit(currentState.copyWith(validation: updatedValidation));
    }
  }
}
