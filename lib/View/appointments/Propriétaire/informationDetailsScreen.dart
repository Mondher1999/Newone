import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:madidou/View/appointments/Propri%C3%A9taire/Documents/documentsListScreen.dart';
import 'package:madidou/View/appointments/Propri%C3%A9taire/profilLocataire.dart';
import 'package:madidou/View/appointments/appointments_list.dart';
import 'package:madidou/View/appointments/calendarDisponibility.dart';
import 'package:madidou/bloc/appointment/appointment_bloc.dart';
import 'package:madidou/bloc/appointment/appointment_state.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';

import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/services/auth/auth_service.dart';

class InformationDetailScreen extends StatefulWidget {
  final String userId;

  const InformationDetailScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _InformationDetailScreenState createState() =>
      _InformationDetailScreenState();
}

class _InformationDetailScreenState extends State<InformationDetailScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  List<Appointment> _localappointment = [];

  final String? userId = AuthService.firebase().currentUser?.id;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        // Handle favorite removal success
      },
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 40.0),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 50, bottom: 0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthStateLoggedOut ||
                      authState is AuthStateLoggedIn) {
                    // User is not logged in, show message and connect button
                    // User is not logged in, show message and connect button
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 4, left: 20, right: 20),
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
                            "Connectez-vous pour consulter vos Rendez vous.",
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
                            "consulter vos Rendez vous en vous connectant à votre compte.",
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
                  } else if (authState is AuthStateProprietaire) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 0, right: 0, left: 0, bottom: 30),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                SizedBox(
                                  height: 0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.05), // Lighter shadow for subtlety
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: Offset(0,
                                              5), // Reduced shadow displacement
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.account_circle,
                                          size: 25,
                                          color: Color.fromARGB(255, 255, 112,
                                              137)), // Consistent icon color
                                      title: Text(
                                        "Profil complet du locataire",
                                        style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfilLocataire(
                                                      userId: widget.userId)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 40.0, left: 40.0),
                                  child: Divider(
                                    height: 50,
                                    color: Colors.grey[200],
                                  ),
                                ), // Subtle and lighter divider
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.assignment,
                                          size: 25,
                                          color: Color.fromARGB(
                                              255, 255, 112, 137)),
                                      title: Text(
                                        "Documents légaux et contrats",
                                        style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DocumentsListScreen(
                                                      userId: widget.userId)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Default return for all other AuthState cases
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
