import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/validation/short_answer_validation_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';

// Events
abstract class DynamicShortAnswerEvent extends Equatable {
  const DynamicShortAnswerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDynamicShortAnswerEvent extends DynamicShortAnswerEvent {
  final DynamicFormModel component;

  const InitializeDynamicShortAnswerEvent({required this.component});

  @override
  List<Object?> get props => [component];
}

class UpdateValueEvent extends DynamicShortAnswerEvent {
  final String value;

  const UpdateValueEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class ValidateValueEvent extends DynamicShortAnswerEvent {
  final String value;

  const ValidateValueEvent(this.value);

  @override
  List<Object?> get props => [value];
}

// States
abstract class DynamicShortAnswerState extends Equatable {
  final DynamicFormModel component;
  final String? currentValue;
  final String? errorText;

  const DynamicShortAnswerState({
    required this.component,
    this.currentValue,
    this.errorText,
  });

  @override
  List<Object?> get props => [component, currentValue, errorText];
}

class DynamicShortAnswerInitial extends DynamicShortAnswerState {
  const DynamicShortAnswerInitial({
    required super.component,
    super.currentValue,
    super.errorText,
  });
}

class DynamicShortAnswerLoading extends DynamicShortAnswerState {
  const DynamicShortAnswerLoading({
    required super.component,
    super.currentValue,
    super.errorText,
  });

  factory DynamicShortAnswerLoading.fromState({
    required DynamicShortAnswerState state,
  }) {
    return DynamicShortAnswerLoading(
      component: state.component,
      currentValue: state.currentValue,
      errorText: state.errorText,
    );
  }
}

class DynamicShortAnswerSuccess extends DynamicShortAnswerState {
  const DynamicShortAnswerSuccess({
    required super.component,
    super.currentValue,
    super.errorText,
  });

  factory DynamicShortAnswerSuccess.fromState({
    required DynamicShortAnswerState state,
  }) {
    return DynamicShortAnswerSuccess(
      component: state.component,
      currentValue: state.currentValue,
      errorText: state.errorText,
    );
  }

  DynamicShortAnswerSuccess copyWith({
    DynamicFormModel? component,
    String? currentValue,
    String? errorText,
  }) {
    return DynamicShortAnswerSuccess(
      component: component ?? this.component,
      currentValue: currentValue ?? this.currentValue,
      errorText: errorText ?? this.errorText,
    );
  }
}

class DynamicShortAnswerError extends DynamicShortAnswerState {
  final String errorMessage;

  const DynamicShortAnswerError({
    required super.component,
    super.currentValue,
    super.errorText,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

// BLoC
class DynamicShortAnswerBloc
    extends Bloc<DynamicShortAnswerEvent, DynamicShortAnswerState> {
  DynamicShortAnswerBloc()
    : super(
        const DynamicShortAnswerInitial(
          component: DynamicFormModel(
            id: '',
            type: FormTypeEnum.shortAnswerFormType,
            order: 0,
            config: ConfigModel(),
            style: StyleModel(),
          ),
        ),
      ) {
    on<InitializeDynamicShortAnswerEvent>(_onInitialize);
    on<UpdateValueEvent>(_onUpdateValue);
    on<ValidateValueEvent>(_onValidateValue);
  }

  Future<void> _onInitialize(
    InitializeDynamicShortAnswerEvent event,
    Emitter<DynamicShortAnswerState> emit,
  ) async {
    emit(DynamicShortAnswerLoading.fromState(state: state));

    try {
      final component = event.component;
      final currentValue = component.config?.value?.toString() ?? '';

      emit(
        DynamicShortAnswerSuccess(
          component: component,
          currentValue: currentValue,
          errorText: null,
        ),
      );
    } catch (e) {
      emit(
        DynamicShortAnswerError(
          component: state.component,
          currentValue: state.currentValue,
          errorText: state.errorText,
          errorMessage: 'Failed to initialize: $e',
        ),
      );
    }
  }

  void _onUpdateValue(
    UpdateValueEvent event,
    Emitter<DynamicShortAnswerState> emit,
  ) {
    if (state is DynamicShortAnswerSuccess) {
      final currentState = state as DynamicShortAnswerSuccess;

      // Validate the value
      final validationError = _validateValue(event.value);

      emit(
        currentState.copyWith(
          currentValue: event.value,
          errorText: validationError,
        ),
      );
    }
  }

  void _onValidateValue(
    ValidateValueEvent event,
    Emitter<DynamicShortAnswerState> emit,
  ) {
    if (state is DynamicShortAnswerSuccess) {
      final currentState = state as DynamicShortAnswerSuccess;

      final validationError = _validateValue(event.value);

      emit(
        currentState.copyWith(
          errorText: validationError,
        ),
      );
    }
  }

  String? _validateValue(String value) {
    final config = state.component.config;
    final isRequired = config?.isRequired ?? false;

    // Check if required
    if (isRequired && (value.isEmpty || value.trim().isEmpty)) {
      return config?.errorText ?? 'This field is required';
    }

    // If empty and not required, no validation needed
    if (value.isEmpty || value.trim().isEmpty) {
      return null;
    }

    // Use component's validation property directly
    final validation = state.component.validation;
    if (validation is ShortAnswerValidationModel) {
      final shortValidation = validation as ShortAnswerValidationModel;
      return shortValidation.validateValue(value);
    }
    // Fallback: parse from config.validate when typed validation is absent
    final rawValidate = state.component.config?.validate;
    if (rawValidate is Map<String, dynamic>) {
      final parsed = ShortAnswerValidationModel.fromJson(rawValidate);
      return parsed.validateValue(value);
    }

    return null;
  }
}
