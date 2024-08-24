import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:madidou/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistrationSuccess extends AuthState {
  final String userId;
  const AuthStateRegistrationSuccess(
      {required this.userId, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

// role State

abstract class AuthStateWithRole extends AuthState {
  final AuthUser user;
  final String role;

  const AuthStateWithRole(
      {required this.user, required this.role, required bool isLoading})
      : super(isLoading: isLoading);
}

// State for user with "propriétaire" role
class AuthStateProprietaire extends AuthState {
  final AuthUser user;
  final bool isLoading;

  AuthStateProprietaire({required this.user, required this.isLoading})
      : super(isLoading: false);
}

// State for user with "locataire" role
class AuthStateLocataire extends AuthState {
  final AuthUser user;
  final bool isLoading;

  AuthStateLocataire({required this.user, required this.isLoading})
      : super(isLoading: false);
}

class AuthStateLoggedinFailure extends AuthState {
  final Exception exception;
  const AuthStateLoggedinFailure(
      {required this.exception, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required this.exception,
    required bool this.hasSentEmail,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateNeedsverification extends AuthState {
  const AuthStateNeedsverification({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut(
      {required this.exception, required bool isLoading, String? loadingText})
      : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateShouldLogIn extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateShouldLogIn(
      {required this.exception, required bool isLoading, String? loadingText})
      : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}
