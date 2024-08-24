import 'dart:io';

import 'package:madidou/data/model/user.dart';

abstract class UserEvent {}

class FetchUsers extends UserEvent {}

class AddUser extends UserEvent {
  final Users user;
  final String? imagePath; // Add this
  AddUser(this.user, {this.imagePath});
}

class UpdateUserImage extends UserEvent {
  final String userId;
  final File imageFile;

  UpdateUserImage(this.userId, this.imageFile);
}

class FetchUserImage extends UserEvent {
  final String userId;

  FetchUserImage(this.userId);
}

class FetchUserFriendsEvent extends UserEvent {
  final String userId;

  FetchUserFriendsEvent({required this.userId});
}

// In user_event.dart

class DeleteFriendEvent extends UserEvent {
  final String userId;
  final String friendId;

  DeleteFriendEvent({required this.userId, required this.friendId});
}

class AddFriendEvent extends UserEvent {
  final String userId;
  final String friendId;

  AddFriendEvent({required this.userId, required this.friendId});
}

class UpdateFCMToken extends UserEvent {
  final String userId;
  final String token;

  UpdateFCMToken(this.userId, this.token);
}

class UpdateUser extends UserEvent {
  final Users user;
  // Optional, for image updates
  UpdateUser(this.user);
}

class UpdateUserRole extends UserEvent {
  String userId;
  final Users user;
  // Optional, for image updates
  UpdateUserRole(this.user, this.userId);
}

class FetchUser extends UserEvent {
  final String userId;

  FetchUser(this.userId);
}

class DeleteUser extends UserEvent {
  final String userId;
  DeleteUser(this.userId);
}
