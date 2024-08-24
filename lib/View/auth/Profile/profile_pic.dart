import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/data/repository/user_repository.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/user/user_api_service.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  final ImagePicker _picker = ImagePicker();
  late UserRepository userRepository;
  String _imageUrl =
      'https://via.placeholder.com/150'; // Default placeholder image
  bool _showValidationIcon = false;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(apiService: ApiUserService());
    _loadUserProfileImage();
    final String? userId = AuthService.firebase().currentUser?.id;
    if (userId != null) {
      BlocProvider.of<UserBloc>(context, listen: false).add(FetchUser(userId));
    }
  }

  void _loadUserProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("No user logged in.");
      return;
    }
    try {
      String imageUrl = await userRepository.getUserImageById(userId);
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print("Failed to load user image: $e");
      setState(() {
        _imageUrl = 'https://via.placeholder.com/150';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoadSuccess) {
          _updateUserProfileValidation(state.user);
        }
        if (state is UserImageUpdated) {
          setState(() {
            _imageUrl = state.imageUrl ?? 'https://via.placeholder.com/150';
          });
        }
      },
      child: buildUserProfileImage(),
    );
  }

  Widget buildUserProfileImage() {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(_imageUrl),
          ),
          if (_showValidationIcon)
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.check_circle, color: Colors.blue, size: 24),
            ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: Colors.white),
                  ),
                  backgroundColor: Color(0xFFF5F6F9),
                ),
                onPressed: _updateProfileImage,
                child: SvgPicture.asset(
                  "assets/icons/cameraIcon.svg",
                  width: 22,
                  color: Color(0xFF5e5f99),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _updateUserProfileValidation(Users user) {
    setState(() {
      _showValidationIcon =
          (user.validefilesuser == 'validé' && user.valideinfouser == 'validé');
    });
  }

  Future<void> _updateProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    final File imageFile = File(image.path);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    BlocProvider.of<UserBloc>(context, listen: false)
        .add(UpdateUserImage(userId, imageFile));
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirmation"),
              content: const Text("Êtes-vous sûr de vouloir changer la photo?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Annuler"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          },
        ) ??
        false; // Handle the case where the dialog is dismissed with null
  }
}
