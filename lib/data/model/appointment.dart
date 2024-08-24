class Appointment {
  String id;
  String userId;
  String ownerId;
  String propertyId;
  DateTime dateAppointment;
  String status;

  Appointment({
    required this.id,
    required this.userId,
    required this.ownerId,
    required this.propertyId,
    required this.dateAppointment,
    required this.status,
  });

  // Constructor to create an Appointment object from JSON
  Appointment.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        userId = json['userId'] ?? '',
        ownerId = json['ownerId'] ?? '',
        propertyId = json['idproperty'] ?? '',
        dateAppointment = DateTime.parse(
            json['dateAppointment'] ?? DateTime.now().toIso8601String()),
        status = json['status'] ??
            'pending'; // Assuming 'pending' is the default status

  // Method to convert an Appointment object into a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'ownerId': ownerId,
        'idproperty': propertyId,
        'dateAppointment': dateAppointment.toIso8601String(),
        'status': status,
      };
}
