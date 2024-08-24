abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentCreated extends AppointmentState {
  final dynamic result;
  AppointmentCreated(this.result);
}

class AppointmentsLoaded extends AppointmentState {
  final List<dynamic> appointments;
  AppointmentsLoaded(this.appointments);
}

class AppointmentUpdated extends AppointmentState {
  final dynamic result;
  AppointmentUpdated(this.result);
}

class AppointmentAccepted extends AppointmentState {}

class AppointmentRefused extends AppointmentState {}

class AppointmentCancel extends AppointmentState {}

class AppointmentError extends AppointmentState {
  final String message;
  AppointmentError(this.message);
}
