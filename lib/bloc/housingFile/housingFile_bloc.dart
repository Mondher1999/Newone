import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/housingFile/housingFile_event.dart';
import 'package:madidou/bloc/housingFile/housingFile_state.dart';
import 'package:madidou/data/repository/housingFile_repository.dart';

class HousingFileBloc extends Bloc<HousingFileEvent, HousingFileState> {
  final HousingFileRepository housingFileRepository;

  HousingFileBloc({required this.housingFileRepository})
      : super(HousingFileLoading()) {
    on<FetchHousingFile>((event, emit) async {
      emit(HousingFileLoading());
      try {
        final housingFile =
            await housingFileRepository.getHousingFileByUserId(event.userId);
        emit(HousingFileLoaded(housingFile));
      } catch (e) {
        emit(HousingFileError("Failed to load housing file: ${e.toString()}"));
      }
    });

    on<CreateHousingFile>((event, emit) async {
      emit(HousingFileCreating());
      try {
        final success =
            await housingFileRepository.createHousingFile(event.userId);
        if (success) {
          emit(HousingFileCreateSuccess(success));
        } else {
          emit(HousingFileError('Failed to create housing file'));
        }
      } catch (e) {
        emit(HousingFileError('Failed to create housing file: $e'));
      }
    });

    on<UpdateHousingFile>((event, emit) async {
      emit(HousingFileUpdating());
      try {
        final housingFile = await housingFileRepository.updateHousingFile(
            event.userId, event.updateData);
        emit(HousingFileUpdateSuccess(housingFile));
      } catch (e) {
        emit(
            HousingFileError("Failed to update housing file: ${e.toString()}"));
      }
      // This is handled in BlocListener in your UI component
    });

    on<FetchSpecificFile>((event, emit) async {
      emit(HousingFileLoading());
      try {
        final fileUrl = await housingFileRepository.getFileByUserId(
            event.userId, event.fieldName);
        emit(HousingFileSpecificLoaded(fileUrl));
      } catch (e) {
        emit(HousingFileError(
            "Failed to load ${event.fieldName}: ${e.toString()}"));
      }
    });
  }
}
