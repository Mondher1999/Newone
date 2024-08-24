import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/services/auth/auth_user.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoadSuccess) {
          _handleUserState(state, context);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(25.0),
        color: Colors.white,
        elevation: 10,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0)),
        child: InkWell(
          onTap: () => _handleTap(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _textSection(),
                const SizedBox(width: 20),
                _imageSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current user is null.')),
      );
      return;
    }

    final userBloc = context.read<UserBloc>();
    userBloc.add(FetchUser(currentUser.uid));
    debugPrint(
        "Debug: FetchUser event added to UserBloc for userID ${currentUser.uid}");
  }

  Future<void> _handleUserState(UserState state, BuildContext context) async {
    if (!(state is UserLoadSuccess)) return;

    final newRole =
        (state.user.role == 'propriétaire') ? 'Locataire' : 'propriétaire';
    bool confirm = await _showRoleChangeDialog(context, newRole);
    if (!confirm) return;

    final userBloc = context.read<UserBloc>();
    userBloc
        .add(UpdateUserRole(state.user.copyWith(role: newRole), state.user.id));
    final firebaseUser = FirebaseAuth.instance.currentUser;

    AuthUser authUser =
        AuthUser.fromFirebase(firebaseUser!); // Ensure this conversion is valid
    final authBloc = context.read<AuthBloc>();
    if (newRole == 'Locataire') {
      authBloc.add(SetAsLocataire(authUser));
    } else {
      authBloc.add(SetAsProprietaire(authUser));
    }
  }

  Future<bool> _showRoleChangeDialog(
      BuildContext context, String newRole) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Confirmation'),
            content: Text(
                'Voulez-vous passer à l\'écran de ${newRole.toLowerCase()}?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Non'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Oui'),
              ),
            ],
          ),
        ) ??
        false; // Handle null by returning false
  }

  Widget _textSection() {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Mettre votre logement sur Madidou",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Commencez votre activité et gagnez de l'argent en toute simplicité",
            style: TextStyle(
              color: Color.fromARGB(255, 71, 71, 71),
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSection() {
    return Expanded(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          "assets/images/imagemaison.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
