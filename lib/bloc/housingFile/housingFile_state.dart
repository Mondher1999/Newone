abstract class HousingFileState {}

class HousingFileCreating extends HousingFileState {}

class HousingFileUpdating extends HousingFileState {}

class HousingFileLoading extends HousingFileState {}

class HousingFileLoaded extends HousingFileState {
  final dynamic housingFile; // Assuming your model or a generic dynamic type
  HousingFileLoaded(this.housingFile);
}

class HousingFileCreateSuccess extends HousingFileState {
  final dynamic housingFile;
  HousingFileCreateSuccess(this.housingFile);
}

class HousingFileUpdateSuccess extends HousingFileState {
  final dynamic housingFile;
  HousingFileUpdateSuccess(this.housingFile);
}

class HousingFileError extends HousingFileState {
  final String message;
  HousingFileError(this.message);
}

class HousingFileSpecificLoaded extends HousingFileState {
  final String fileUrl;
  HousingFileSpecificLoaded(this.fileUrl);
}
