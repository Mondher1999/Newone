abstract class DisponibilityEvent {}

class CreateDisponibilityEvent extends DisponibilityEvent {
  final String userId;
  CreateDisponibilityEvent({required this.userId});
}

class GetDisponibilitiesEvent extends DisponibilityEvent {
  final String ownerId;
  GetDisponibilitiesEvent(this.ownerId);
}

class UpdateDisponibilityEvent extends DisponibilityEvent {
  final String userId;

  final List<String> updateData;

  UpdateDisponibilityEvent({required this.userId, required this.updateData});
}

class CheckUserStatusEvent extends DisponibilityEvent {
  final String userId;

  CheckUserStatusEvent(this.userId);
}
