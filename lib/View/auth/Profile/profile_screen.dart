import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/auth/login_view.dart';
import 'package:madidou/View/auth/Profile/profile_menu.dart';
import 'package:madidou/View/auth/Profile/profile_pic.dart';
import 'package:madidou/View/auth/update_housing_files_screen.dart';
import 'package:madidou/View/auth/update_profile_view.dart';
import 'package:madidou/View/property/Locataire/Property_Read/properties_locataire_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/guide_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:madidou/utilities/dialogs/logout_dialog.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({Key? key}) : super(key: key);

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateLocataire) {
            // L'utilisateur n'est pas connecté
            return _buildProfilePage(context);
          } else if (state is AuthStateProprietaire) {
            return _buildProfilePageProprietaire(context);
          } else {
            return _buildLoginPrompt(context);
          }
        },
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 30.0, bottom: 15),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Profil", // Replace with actual user name
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF5e5f99),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Add more widgets here if needed
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const ProfilePic(),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Mon Espace", // Replace with actual user name
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ProfileMenu(
            text: "Informations personnelles",
            icon: "assets/icons/userIcon.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpdateProfileScreen()),
              );
            },
          ),
          ProfileMenu(
            text: "Mon Coffre Fort",
            icon: "assets/icons/safe.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpdateHousingFilesScreen()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 23.0, bottom: 10),
            child: SizedBox(
              width: 330,
              child: Divider(),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(25.0), // Outer margin of the card
            color: const Color.fromARGB(
                255, 255, 255, 255), // Background color of the card
            elevation: 10, // Shadow depth below the card
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(17.0), // Rounded corners of the card
            ),
            child: InkWell(
              onTap: () async {
                final userId = AuthService.firebase()
                    .currentUser
                    ?.id; // Fetch the current user ID
                if (userId == null) {
                  debugPrint("Debug: User ID is null, exiting function.");
                  return;
                }

                final UserBloc userBloc = context.read<UserBloc>();
                userBloc.add(FetchUser(userId)); // Fetch user details
                debugPrint(
                    "Debug: FetchUser event added to UserBloc for userID $userId");

                StreamSubscription<UserState>? subscription =
                    userBloc.stream.listen((state) async {
                  debugPrint(
                      "Debug: UserBloc state updated: ${state.runtimeType}");
                  if (state is UserLoadSuccess) {
                    String newRole = (state.user.role == 'propriétaire')
                        ? 'Locataire'
                        : 'propriétaire';
                    debugPrint(
                        "Debug: Current user role is ${state.user.role}, new role will be $newRole");

                    if (state.user.role != newRole) {
                      final updatedUser = state.user.copyWith(role: newRole);
                      bool confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Confirmation'),
                              content: Text(
                                  'Voulez-vous passer à l\'écran de ${newRole.toLowerCase()}?'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Non')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Oui')),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirm) {
                        final firebaseUser = FirebaseAuth.instance.currentUser;
                        final AuthUser authUser =
                            AuthUser.fromFirebase(firebaseUser!);
                        userBloc.add(UpdateUserRole(updatedUser, authUser.id));
                        try {
                          final firebaseUser =
                              FirebaseAuth.instance.currentUser;
                          if (firebaseUser == null) {
                            debugPrint("Error: Current user is null.");
                            return;
                          }

                          final AuthUser authUser =
                              AuthUser.fromFirebase(firebaseUser);
                          if (newRole == 'Locataire') {
                            context
                                .read<AuthBloc>()
                                .add(SetAsLocataire(authUser));
                          } else if (newRole == 'propriétaire') {
                            context
                                .read<AuthBloc>()
                                .add(SetAsProprietaire(authUser));
                          }
                        } catch (e) {
                          debugPrint("An error occurred: $e");
                        }
                      }
                    }
                  }
                });

                subscription.onDone(() => subscription.cancel());
              },
              child: Padding(
                padding:
                    const EdgeInsets.all(16.0), // Inner padding of the card
                child: Row(
                  children: [
                    Expanded(
                      flex: 3, // Allocates 3 parts of space to the text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mettre votre logement sur Madidou",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Commencez votre activité et gagnez de l'argent en toute simplicité",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 71, 71, 71)
                                  .withOpacity(0.9),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                        width: 20), // Space between the text and the image
                    Expanded(
                      flex: 1, // Allocates 1 part of space to the image
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          "assets/images/imagemaison.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14.0, bottom: 5),
            child: SizedBox(
              width: 330,
              child: Divider(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Réglage",
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/bell.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Centre d'aide",
            icon: "assets/icons/questionmark.svg",
            press: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 10),
            child: SizedBox(
              width: 330,
              child: Divider(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Juridique",
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ProfileMenu(
            text: "Condition de service",
            icon: "assets/icons/gdpricon.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Politique de confidentialité",
            icon: "assets/icons/gdpricon.svg",
            press: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 350,
              child: Divider(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 20, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                },
                child: const Text(
                  "Déconnexion",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Montserrat",
                    color: Color(0xFF5e5f99),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 350,
              child: Divider(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 33, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Version 1.0 (25938547)",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: "Montserrat",
                  color: Color(0xFF5e5f99),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePageProprietaire(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 30.0, bottom: 15),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Profil", // Replace with actual user name
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF5e5f99),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Add more widgets here if needed
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const ProfilePic(),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Mon Espace", // Replace with actual user name
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ProfileMenu(
            text: "Informations personnelles",
            icon: "assets/icons/userIcon.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpdateProfileScreen()),
              );
            },
          ),
          ProfileMenu(
            text: "Créez une nouvelle annonce",
            icon: "assets/icons/add.svg",
            press: () {
              final List<XFile> images;
              final List<Amenities> selectedAmenities;
              // Correct navigation method
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => FirstScreen(
                          images: [],
                          selectedAmenities: [],
                        )),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14.0, bottom: 5),
            child: SizedBox(
              width: 330,
              child: Divider(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Réglage",
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/bell.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Centre d'aide",
            icon: "assets/icons/questionmark.svg",
            press: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 10),
            child: SizedBox(
              width: 330,
              child: Divider(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Juridique",
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5e5f99),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ProfileMenu(
            text: "Condition de service",
            icon: "assets/icons/gdpricon.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Politique de confidentialité",
            icon: "assets/icons/gdpricon.svg",
            press: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 350,
              child: Divider(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 15.0, right: 17, left: 17, bottom: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                final userId = AuthService.firebase()
                    .currentUser
                    ?.id; // Ensure you are using `uid` and not `id`
                if (userId == null) {
                  debugPrint("Debug: User ID is null, exiting function.");
                  return;
                }

                final UserBloc userBloc = context.read<UserBloc>();
                userBloc.add(FetchUser(userId));
                debugPrint(
                    "Debug: FetchUser event added to UserBloc for userID $userId");

                StreamSubscription<UserState>? subscription =
                    userBloc.stream.listen((state) async {
                  debugPrint(
                      "Debug: UserBloc state updated: ${state.runtimeType}");
                  if (state is UserLoadSuccess) {
                    String newRole = (state.user.role == 'propriétaire')
                        ? 'Locataire'
                        : 'propriétaire';
                    debugPrint(
                        "Debug: Current user role is ${state.user.role}, new role will be $newRole");

                    if (state.user.role != newRole) {
                      final updatedUser = state.user.copyWith(role: newRole);
                      bool confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Confirmation'),
                              content: Text(
                                  'Voulez-vous passer à l\'écran de ${newRole.toLowerCase()}?'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Non')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Oui')),
                              ],
                            ),
                          ) ??
                          false;

                      debugPrint("Debug: Confirmation dialog result: $confirm");
                      if (confirm) {
                        final firebaseUser = FirebaseAuth.instance.currentUser;
                        final AuthUser authUser =
                            AuthUser.fromFirebase(firebaseUser!);
                        userBloc.add(UpdateUserRole(updatedUser, authUser.id));
                        debugPrint(
                            "Debug: UpdateUserRole event added to UserBloc for ${updatedUser.id}");

                        try {
                          final firebaseUser =
                              FirebaseAuth.instance.currentUser;
                          if (firebaseUser == null) {
                            debugPrint("Error: Current user is null.");
                            return;
                          }

                          final AuthUser authUser =
                              AuthUser.fromFirebase(firebaseUser);
                          if (newRole == 'Locataire') {
                            context
                                .read<AuthBloc>()
                                .add(SetAsLocataire(authUser));
                          } else if (newRole == 'propriétaire') {
                            context
                                .read<AuthBloc>()
                                .add(SetAsProprietaire(authUser));
                          }

                          debugPrint(
                              "Debug: AuthBloc event added for new role $newRole");
                        } catch (e) {
                          debugPrint("An error occurred: $e");
                        }
                      }
                    }
                  }
                });

                // Important: Cancel the subscription when the stream ends or when it's no longer needed
                subscription.onDone(() => subscription.cancel());
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Coins arrondis
                ),
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(255, 255, 112, 137), // Text color
              ),
              child: const Padding(
                padding: EdgeInsets.all(0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Passer en mode locataire",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 15.0, right: 17, left: 17, bottom: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Coins arrondis
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF5e5f99), // Text color
                ),
                child: const Text(
                  "Déconnexion",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              width: 350,
              child: Divider(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 33, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Version 1.0 (25938547)",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: "Montserrat",
                  color: Color(0xFF5e5f99),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    // Page incitant à se connecter
    return SingleChildScrollView(
      // Utiliser SingleChildScrollView
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 20),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Votre profil ",
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF5e5f99),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "Connectez-vous pour trouver votre Logment.",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to login screen
                          context.read<AuthBloc>().add(
                                const AuthEventShouldLogIn(),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          // Définit la couleur de fond du bouton (par exemple, bleu)
                          backgroundColor: const Color(0xFF5e5f99),
                          // Définit la taille minimum du bouton
                          minimumSize:
                              const Size(450, 45), // Taille plus petite
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  16), // Ajuste le padding à l'intérieur du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Coins arrondis
                          ),
                        ),
                        child: const Text(
                          "Connexion",
                          style: TextStyle(
                              color: Colors.white, // Couleur du texte en blanc
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: RichText(
                        text: TextSpan(
                          text: "Vous n'avez pas e compte ?",
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Montserrat",
                            fontSize: 13,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '  Inscrivez-vous',
                              style: const TextStyle(
                                color: Color(0xFF5e5f99),
                                fontFamily: "Montserrat",
                                fontSize: 13,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.read<AuthBloc>().add(
                                        const AuthEventShouldRegister(),
                                      );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Réglage", // Replace with actual user name
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF5e5f99),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ProfileMenu(
                    text: "Notifications",
                    icon: "assets/icons/bell.svg",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Centre d'aide",
                    icon: "assets/icons/questionmark.svg",
                    press: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 10),
                    child: SizedBox(
                      width:
                          330, // Set the width of the container to determine the length of the divider
                      child: Divider(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Juridique", // Replace with actual user name
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF5e5f99),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ProfileMenu(
                    text: "Condition de service",
                    icon: "assets/icons/gdpricon.svg",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Politique de confidentialité",
                    icon: "assets/icons/gdpricon.svg",
                    press: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                      width:
                          350, // Set the width of the container to determine the length of the divider
                      child: Divider(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 33, bottom: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Version 1.0 (25938547)",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: "Montserrat",
                          color: Color(0xFF5e5f99),
                          fontWeight: FontWeight.w500, // Rend le texte gras
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
