import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/data/repository/user_repository.dart';
import 'package:madidou/services/auth/auth_exceptions.dart';
import 'package:madidou/services/auth/auth_provider.dart';
import 'package:madidou/services/auth/auth_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;
  final UserRepository userRepository;

  AuthBloc({required this.provider, required this.userRepository})
      : super(const AuthStateUninitialized(isLoading: true)) {
    //Should be registered

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    on<AuthEventShouldLogIn>((event, emit) {
      emit(const AuthStateShouldLogIn(
        isLoading: false,
        exception: null,
      ));
    });

    on<SetAsLocataire>((event, emit) {
      emit(AuthStateLocataire(user: event.user, isLoading: false));
    });

    on<SetAsProprietaire>((event, emit) {
      emit(AuthStateProprietaire(user: event.user, isLoading: false));
    });

    //forget Passwords
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return;
      }

      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;

      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
      emit(
        const AuthStateShouldLogIn(
          exception: null,
          isLoading: false,
        ),
      );
    });

    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      try {
        final userCredential = await provider.createUser(
          email: event.email,
          password: event.password,
        );

        // This is the correct way to get the user ID from a UserCredential object
        final userid = userCredential.id;
        emit(AuthStateRegistrationSuccess(userId: userid, isLoading: false));
        await provider.sendEmailVerification();
        emit(const AuthStateShouldLogIn(isLoading: false, exception: null));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    // Initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsverification(isLoading: false));
      } else {
        // emit(AuthStateLoggedIn(user: user, isLoading: false));

        final Users userDetails = await userRepository.getUserById(user.id);

        switch (userDetails.role) {
          case 'propriétaire':
            emit(AuthStateProprietaire(user: user, isLoading: false));
            break;
          case 'Locataire':
            emit(AuthStateLocataire(user: user, isLoading: false));
            break;
          default:
            emit(AuthStateLocataire(
                user: user, isLoading: false)); // Default state
            break;
        }
      }
    });

    //LogIn
    on<AuthEventLogIn>((event, emit) async {
      emit(AuthStateShouldLogIn(
          isLoading: true,
          loadingText: 'Veuillez patienter pendant que nous vous connectons.',
          exception: null));

      try {
        final AuthUser user =
            await provider.logIn(email: event.email, password: event.password);

        if (!user.isEmailVerified) {
          emit(AuthStateNeedsverification(isLoading: false));
        } else {
          final Users userDetails = await userRepository.getUserById(user.id);
          String? token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            // Update token using repository or send it to your server
            userRepository.updateFCMToken(user.id, token);
          }

          // Emit role-based states
          switch (userDetails.role) {
            case 'propriétaire':
              emit(AuthStateProprietaire(user: user, isLoading: false));
              break;
            case 'Locataire':
              emit(AuthStateLocataire(user: user, isLoading: false));
              break;
            default:
              emit(const AuthStateShouldLogIn(
                  isLoading: false, exception: null));
              break;
          }
        }
      } catch (e) {
        if (e is Exception) {
          // Ensure 'e' is an Exception
          emit(AuthStateLoggedinFailure(exception: e, isLoading: false));
          emit(const AuthStateShouldLogIn(isLoading: false, exception: null));
        } else if (e is Error) {
          emit(AuthStateLoggedinFailure(
              exception: GenericAuthException(), isLoading: false));
          emit(const AuthStateShouldLogIn(isLoading: false, exception: null));
        } else {
          // Optionally handle any other types that might not be an error or exception
          emit(AuthStateLoggedinFailure(
              exception: GenericAuthException(), isLoading: false));
          emit(const AuthStateShouldLogIn(isLoading: false, exception: null));
        }
      }
    });

    //LogOut
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();

        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
  }
}
