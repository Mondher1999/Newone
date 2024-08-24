import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/disponibility/disponibility_event.dart';
import 'package:madidou/bloc/disponibility/disponibility_state.dart';
import 'package:madidou/data/repository/disponibility_repository.dart';

class DisponibilityBloc extends Bloc<DisponibilityEvent, DisponibilityState> {
  final DisponibilityRepository repository;

  DisponibilityBloc({required this.repository})
      : super(DisponibilityInitial()) {
    on<CreateDisponibilityEvent>((event, emit) async {
      emit(DisponibilityLoading());
      try {
        final result = await repository.createDisponibility(event.userId);
        emit(DisponibilityCreated(result));
      } catch (error) {
        emit(DisponibilityError(error.toString()));
      }
    });

    on<GetDisponibilitiesEvent>((event, emit) async {
      emit(DisponibilityLoading());
      try {
        print("Fetching disponibilities for property ID: ${event.ownerId}");
        final disponibilities =
            await repository.getDisponibilities(event.ownerId);
        print("Disponibilities fetched: $disponibilities");
        emit(DisponibilitiesLoaded(disponibilities));
      } catch (error) {
        print("Error in fetching disponibilities: $error");
        emit(DisponibilityError(error.toString()));
      }
    });
    on<UpdateDisponibilityEvent>((event, emit) async {
      emit(DisponibilityLoading());
      try {
        if (event.userId.isEmpty || event.updateData.isEmpty) {
          throw Exception("Invalid data for updating disponibility.");
        }
        await repository.updateDisponibility(
            event.userId, event.updateData.cast<String>());
        final disponibilities =
            await repository.getDisponibilities(event.userId);
        emit(DisponibilitiesLoaded(disponibilities));
        bool status = await repository.checkUserStatus(event.userId);
        if (status) {
          emit(DisponibilityStatusChecked(status));
        } else {
          emit(DisponibilityStatusNotChecked(status));
        }

        //emit(DisponibilityUpdated()); // Emit a success state
      } catch (error) {
        print("Failed to update disponibility: $error");
        emit(DisponibilityError(error.toString()));
      }
    });

    on<CheckUserStatusEvent>((event, emit) async {
      emit(DisponibilityLoading());
      try {
        bool status = await repository.checkUserStatus(event.userId);
        if (status) {
          emit(DisponibilityStatusChecked(status));
        } else {
          emit(DisponibilityStatusNotChecked(status));
        }
      } catch (error) {
        emit(DisponibilityError(error.toString()));
      }
    });

    // Handling BlockDisponibilityEvent

    // Handling UnblockDisponibilityEvent
  }
}
