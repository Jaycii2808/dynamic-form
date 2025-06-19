import 'package:dynamic_form_bi/data/models/text_input_model.dart';
import 'package:equatable/equatable.dart';

abstract class TextInputState extends Equatable {
  final TextInputScreenModel? page;
  final String? errorMessage;

  const TextInputState({
    this.page,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [page, errorMessage];
}

class TextInputInitial extends TextInputState {
  const TextInputInitial({
    super.page,
    super.errorMessage,
  });

  @override
  List<Object?> get props => [page, errorMessage];
}

class TextInputLoading extends TextInputState {
  const TextInputLoading({
    super.page,
    super.errorMessage,
  });

  TextInputLoading.fromState({required TextInputState state})
      : super(
    page: state.page,
    errorMessage: state.errorMessage,
  );

  @override
  List<Object?> get props => [page, errorMessage];
}

class TextInputSuccess extends TextInputState {
  const TextInputSuccess({
    required TextInputScreenModel page,
    super.errorMessage,
  }) : super(page: page);

  TextInputSuccess.fromState({required TextInputState state, required TextInputScreenModel page})
      : super(
    page: page,
    errorMessage: state.errorMessage,
  );

  @override
  List<Object?> get props => [page, errorMessage];
}

class TextInputError extends TextInputState {
  const TextInputError({
    required String errorMessage,
    super.page,
  }) : super(errorMessage: errorMessage);

  @override
  List<Object?> get props => [page, errorMessage];
}

class TextInputEmpty extends TextInputState {
  const TextInputEmpty({
    super.page,
    super.errorMessage,
  });

  @override
  List<Object?> get props => [page, errorMessage];
}