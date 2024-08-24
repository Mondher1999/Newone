import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/data/repository/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserLoading()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading()); // Emitting a loading state
      try {
        final users =
            await userRepository.getUsers(); // Fetch posts from the repository
        emit(UsersLoaded(users)); // Emitting a loaded state with the posts
      } catch (e) {
        emit(UserError()); // Emitting an error state if an exception occurs
      }
    });

    // In user_bloc.dart

    on<DeleteFriendEvent>((event, emit) async {
      emit(UserUpdating()); // Emit a loading state while processing
      try {
        bool success =
            await userRepository.deleteFriend(event.userId, event.friendId);
        List<Users> friends = await userRepository.getUserFriends(event.userId);

        if (success) {
          emit(FriendDeletedSuccessfully());
          emit(UserFriendsLoaded(
              friends)); // You might need to define this state
        } else {
          emit(UserError());
        }
      } catch (e) {
        emit(UserError());
      }
    });

// Inside UserBloc class definition

    on<UpdateUserImage>((event, emit) async {
      emit(UserUpdating());
      try {
        bool success =
            await userRepository.updateUserImage(event.userId, event.imageFile);
        if (success) {
          // Fetch the updated user data or just the new image URL
          String newImageUrl =
              await userRepository.getUserImageById(event.userId);
          emit(UserImageUpdated(
              newImageUrl)); // Pass the new image URL with the state
        } else {
          //  emit(UserError("Failed to update image."));
        }
      } catch (e) {
        //  emit(UserError(e.toString()));
      }
    });

    on<FetchUserFriendsEvent>((event, emit) async {
      emit(UserLoading());
      try {
        List<Users> friends = await userRepository.getUserFriends(event.userId);
        emit(UserFriendsLoaded(friends)); // Define this state as needed
      } catch (e) {
        emit(UserError());
      }
    });

    on<AddFriendEvent>((event, emit) async {
      emit(UserUpdating());
      try {
        bool success =
            await userRepository.addFriend(event.userId, event.friendId);
        // Make sure to await this call
        List<Users> friends = await userRepository.getUserFriends(event.userId);
        if (success) {
          emit(FriendAddedSuccessfully());

          emit(UserFriendsLoaded(friends));
          // Define this state as needed
        } else {
          emit(UserError());
        }
      } catch (e) {
        emit(UserError());
      }
    });

    on<UpdateFCMToken>((event, emit) async {
      try {
        bool success =
            await userRepository.updateFCMToken(event.userId, event.token);
        if (success) {
          emit(UserFCMTokenUpdated());
        } else {
          emit(UserError());
        }
      } catch (e) {
        emit(UserError());
      }
    });

    on<AddUser>((event, emit) async {
      emit(UserCreating());
      try {
        File? imageFile;

        final newUser = await userRepository.createUser(event.user, imageFile);
        emit(UserCreationSuccess(newUser)); // Make sure this line executes
      } catch (e) {
        emit(UserError()); // Make sure this isn't mistakenly executed
      }
    });

    // In UserBloc class in user_bloc.dart
    // In UserBloc class in user_bloc.dart

    on<FetchUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.getUserById(event.userId);
        emit(UserLoadSuccess(user));
      } catch (e) {
        emit(UserError());
        //print(e.toString()); // For debugging
      }
    });

    on<UpdateUser>((event, emit) async {
      emit(UserUpdating());
      try {
        final updatedPost = await userRepository.updateUser(
          event.user.id,
          event.user,
        ); // Pass imagePath directly
        emit(UserUpdateSuccess(updatedPost));
        // Refresh posts list
      } catch (e) {
        emit(UserError());
        print(e.toString()); // For debugging
      }
    });

    on<UpdateUserRole>((event, emit) async {
      emit(UserUpdating());
      try {
        final updatedUser = await userRepository.updateUserRole(
            event!.user.id, {'role': event.user.role}, event.userId);
        emit(UserUpdateSuccess(updatedUser));
      } catch (e) {
        emit(UserError());
        print(e.toString());
      }
    });

    on<DeleteUser>((event, emit) async {
      emit(UserDeleting());

      try {
        // Await the completion of the deletion process

        emit(UserDeleteSucess());

        // Define this state as needed
      } catch (_) {
        emit(
            UserError()); // It's good practice to handle errors and inform the user
      }
    });
  }
}
