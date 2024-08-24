abstract class AppointmentEvent {}

class CreateAppointmentEvent extends AppointmentEvent {
  final String userId;
  final Map<String, dynamic> appointmentData;
  CreateAppointmentEvent({
    required this.userId,
    required this.appointmentData,
  });
}

class GetAppointmentsbyproprietaireEvent extends AppointmentEvent {
  final String ownerId;
  // Add this line

  GetAppointmentsbyproprietaireEvent(
      {required String this.ownerId}); // Modify constructor to include the date
}

class GetAppointmentsbylocataireEvent extends AppointmentEvent {
  final String userId;
  // Add this line

  GetAppointmentsbylocataireEvent(
      {required String this.userId}); // Modify constructor to include the date
}

class UpdateAppointmentEvent extends AppointmentEvent {
  final String id;
  final String userId;
  final Map<String, dynamic> updateData;

  UpdateAppointmentEvent({
    required this.id,
    required this.updateData,
    required this.userId,
  });
}

class AcceptAppointmentEvent extends AppointmentEvent {
  final String userId;
  final String appointmentid;
  AcceptAppointmentEvent({required this.userId, required this.appointmentid});
}

class CancelAppointmentProprietaireEvent extends AppointmentEvent {
  final String userId;
  final String appointmentid;
  CancelAppointmentProprietaireEvent(
      {required this.userId, required this.appointmentid});
}

class CheckCreateUpdateAppointmentEvent extends AppointmentEvent {
  final String userId;
  final String id;
  final DateTime dateAppointment;
  final String ownerId;
  final String status;

  CheckCreateUpdateAppointmentEvent({
    required this.userId,
    required this.id,
    required this.dateAppointment,
    required this.ownerId,
    this.status = "En attente",
  });
}

class CancelAppointmentLocataireEvent extends AppointmentEvent {
  final String userId;
  final String appointmentid;
  CancelAppointmentLocataireEvent(
      {required this.userId, required this.appointmentid});
}

class RefuseAppointmentEvent extends AppointmentEvent {
  final String userId;
  final String appointmentid;
  RefuseAppointmentEvent({required this.userId, required this.appointmentid});
}
