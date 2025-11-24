import 'package:equatable/equatable.dart';

abstract class BaseValidation extends Equatable {
  const BaseValidation();

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [];
}
