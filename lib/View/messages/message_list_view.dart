import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/messages/messaging_detail_view.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/repository/user_repository.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:madidou/services/user/user_api_service.dart';

class MessagesListView extends StatefulWidget {
  const MessagesListView({
    Key? key,
  }) : super(key: key);

  @override
  _MessagesListViewState createState() => _MessagesListViewState();
}

final String? userId = AuthService.firebase().currentUser?.id;
late UserRepository userRepository;
String _imageUrl = 'https://via.placeholder.com/150';

class _MessagesListViewState extends State<MessagesListView> {
  @override
  void initState() {
    super.initState();
    final String? userId = AuthService.firebase().currentUser?.id;
    // Assuming 'currentUser' is already set and represents the logged-in user

    if (userId != null) {
      BlocProvider.of<UserBloc>(context)
          .add(FetchUserFriendsEvent(userId: userId!));

      userRepository = UserRepository(apiService: ApiUserService());
      _loadUserProfileImage();
      BlocProvider.of<UserBloc>(context, listen: false).add(FetchUser(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        // Handle favorite removal success
        if (state is FavoriteRemoveSuccess) {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
          BlocProvider.of<FavoriteBloc>(context)
              .add(FetchFavorites(authUser.id));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFededf6),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 50),
                  child: Text(
                    "Messages",
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF5e5f99),
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthStateLocataire ||
                        authState is AuthStateProprietaire) {
                      // User is not logged in, show message and connect button
                      SizedBox(height: 30);
                      return _buildUserListView(authState);
                    } else {
                      // Loading or other states
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 25.0),
                              child: SizedBox(
                                width:
                                    350, // Set the width of the container to determine the length of the divider
                                child: Divider(),
                              ),
                            ),
                            const Text(
                              "Connectez-vous pour consulter les messages.",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                            const Text(
                              "",
                              style: TextStyle(
                                fontSize: 8,
                              ),
                            ),
                            Text(
                              "Une fois votre connexion effectuée. les messages des Locataire apparaitront ici",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to login screen
                                  context.read<AuthBloc>().add(
                                        const AuthEventShouldLogIn(),
                                      );
                                },
                                child: const Text(
                                  "Connexion",
                                  style: TextStyle(
                                      color: Colors
                                          .white, // Couleur du texte en blanc
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  // Définit la couleur de fond du bouton (par exemple, bleu)
                                  backgroundColor: const Color(0xFF5e5f99),
                                  // Définit la taille minimum du bouton
                                  minimumSize:
                                      const Size(140, 50), // Taille plus petite
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          16), // Ajuste le padding à l'intérieur du bouton
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Coins arrondis
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildUserListView(AuthState state) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is UserFriendsLoaded) {
          if (state.friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Color.fromARGB(255, 255, 112, 137),
                    size: 50,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 0.0, bottom: 50),
                    child: Text(
                      "Aucun contact dans votre liste",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 112, 137),
                        fontFamily: "Montserrat",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: state.friends.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final user = state.friends[index];

              return FutureBuilder<String>(
                future: userRepository.getUserImageById(user.id),
                builder: (context, snapshot) {
                  String imageUrl =
                      snapshot.data ?? 'https://via.placeholder.com/150';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagingScreen(
                            currentUserId: userId!,
                            otherUserId: user.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                imageUrl != 'https://via.placeholder.com/150'
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child: imageUrl == 'https://via.placeholder.com/150'
                                ? Text(
                                    user.nom.isNotEmpty ? user.nom[0] : '',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 25),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user.prenom} ${user.nom}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Appuyez pour discuter",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 255, 112, 137),
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.message, color: Colors.deepPurple),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else if (state is UserError) {
          return Center(child: Text("Failed to load friends"));
        } else {
          return Container(); // Placeholder for other states
        }
      },
    );
  }
}
