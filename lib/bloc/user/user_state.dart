import 'dart:io';

import 'package:madidou/data/model/user.dart';

abstract class UserState {}

class UserCreationSuccess extends UserState {
  final Users user; // Optionally hold the created user's details

  UserCreationSuccess(this.user);
}

class UserImageUpdated extends UserState {
  final String imageUrl;
  UserImageUpdated(this.imageUrl);
}

class UserUpdateSuccess extends UserState {
  final Users user; // Optionally hold the created user's details

  UserUpdateSuccess(this.user);
}

class UserImageLoaded extends UserState {
  final String imageUrl;

  UserImageLoaded(this.imageUrl);
}

class UsersLoaded extends UserState {
  final List<Users> users;
  UsersLoaded(this.users);
}

class UserDeleteSucess extends UserState {}

class UserLocataireRole extends UserState {}

class UserCreating extends UserState {}

class UserUpdating extends UserState {}

class UserDeleting extends UserState {}

class UserError extends UserState {}

class UserLoading extends UserState {} // State when loading user details

class UserLoadSuccess extends UserState {
  final Users user;
  UserLoadSuccess(this.user);
}

class FriendDeletedSuccessfully extends UserState {
  final String message;

  FriendDeletedSuccessfully({this.message = "Friend deleted successfully."});

  @override
  List<Object> get props => [message];
}

class UserFriendsLoaded extends UserState {
  final List<Users> friends;

  UserFriendsLoaded(this.friends);
}

class FriendAddedSuccessfully extends UserState {}

class UserFCMTokenUpdated extends UserState {
  final String message;

  UserFCMTokenUpdated([this.message = "FCM token updated successfully"]);
}
// State for an error