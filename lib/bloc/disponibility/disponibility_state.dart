abstract class DisponibilityState {}

class DisponibilityInitial extends DisponibilityState {}

class DisponibilityLoading extends DisponibilityState {}

class DisponibilityCreated extends DisponibilityState {
  final dynamic result;
  DisponibilityCreated(this.result);
}

class DisponibilitiesLoaded extends DisponibilityState {
  final List<dynamic> disponibilities;
  DisponibilitiesLoaded(this.disponibilities);
}

class DisponibilityUpdated extends DisponibilityState {
  final dynamic result;
  DisponibilityUpdated(this.result);
}

class DisponibilityError extends DisponibilityState {
  final String message;
  DisponibilityError(this.message);
}

class DisponibilityStatusNotChecked extends DisponibilityState {
  final bool status;

  DisponibilityStatusNotChecked(this.status);
}

class DisponibilityStatusChecked extends DisponibilityState {
  final bool status;

  DisponibilityStatusChecked(this.status);
}
