abstract class HousingFileEvent {}

class FetchHousingFile extends HousingFileEvent {
  final String userId;
  FetchHousingFile(this.userId);
}

class CreateHousingFile extends HousingFileEvent {
  final String userId;

  CreateHousingFile({required this.userId});
}

class FetchSpecificFile extends HousingFileEvent {
  final String userId;
  final String fieldName;
  FetchSpecificFile(this.userId, this.fieldName);
}

class UpdateHousingFile extends HousingFileEvent {
  final String userId;
  final Map<String, dynamic>
      updateData; // Using dynamic to handle both String and File types

  UpdateHousingFile({required this.userId, required this.updateData});
}
