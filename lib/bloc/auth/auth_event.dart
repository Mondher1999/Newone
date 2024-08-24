import 'package:flutter/foundation.dart';
import 'package:madidou/services/auth/auth_user.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventShouldLogIn extends AuthEvent {
  const AuthEventShouldLogIn();
}

class SetAsLocataire extends AuthEvent {
  final AuthUser user;
  SetAsLocataire(this.user);
}

class SetAsProprietaire extends AuthEvent {
  final AuthUser user;
  SetAsProprietaire(this.user);
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
