import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/appointment/appointment_event.dart';
import 'package:madidou/bloc/appointment/appointment_state.dart';
import 'package:madidou/data/repository/appointment_repository.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository repository;

  AppointmentBloc({required this.repository}) : super(AppointmentInitial()) {
    on<CreateAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final result = await repository.createAppointment(
            event.userId, event.appointmentData);
        emit(AppointmentCreated(result));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<GetAppointmentsbyproprietaireEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final appointments =
            await repository.getAppointmentsbyproprietaire(event.ownerId);
        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<GetAppointmentsbylocataireEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final appointments =
            await repository.getAppointmentsbylocataire(event.userId);
        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<UpdateAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final result =
            await repository.updateAppointment(event.id, event.updateData);
        emit(AppointmentUpdated(result));
        final appointments =
            await repository.getAppointmentsbyproprietaire(event.userId);

        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<AcceptAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final success = await repository.acceptAppointment(event.appointmentid);
        final appointments =
            await repository.getAppointmentsbyproprietaire(event.userId);
        if (success) {
          emit(AppointmentAccepted());
        } else {
          emit(AppointmentError('Failed to accept appointment'));
        }

        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<RefuseAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final success = await repository.refuseAppointment(event.appointmentid);
        final appointments =
            await repository.getAppointmentsbyproprietaire(event.userId);
        if (success) {
          emit(AppointmentRefused());
        } else {
          emit(AppointmentError('Failed to refuse appointment'));
        }
        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<CheckCreateUpdateAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final appointment = await repository.checkCreateUpdateAppointment(
          event.userId,
          event.id,
          event.dateAppointment,
          event.ownerId,
          event.status,
        );
        emit(AppointmentUpdated(
            appointment)); // or AppointmentCreated based on the response
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<CancelAppointmentProprietaireEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final success = await repository.cancelAppointment(event.appointmentid);
        final appointments =
            await repository.getAppointmentsbyproprietaire(event.userId);
        if (success) {
          emit(AppointmentRefused());
        } else {
          emit(AppointmentError('Failed to refuse appointment'));
        }
        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });

    on<CancelAppointmentLocataireEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        final success = await repository.cancelAppointment(event.appointmentid);
        final appointments =
            await repository.getAppointmentsbylocataire(event.userId);
        if (success) {
          emit(AppointmentRefused());
        } else {
          emit(AppointmentError('Failed to refuse appointment'));
        }
        emit(AppointmentsLoaded(appointments));
      } catch (error) {
        emit(AppointmentError(error.toString()));
      }
    });
  }
}
