import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:madidou/View/appointments/appointments_list.dart';
import 'package:madidou/View/appointments/calendarDisponibility.dart';
import 'package:madidou/View/appointments/calenderappointments.dart';
import 'package:madidou/View/appointments/calenderappointmentsupdate.dart';
import 'package:madidou/View/property/Locataire/Property_Read/property_detail.dart';
import 'package:madidou/bloc/appointment/appointment_bloc.dart';
import 'package:madidou/bloc/appointment/appointment_event.dart';
import 'package:madidou/bloc/appointment/appointment_state.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';

class AppointmentsScreen extends StatefulWidget {
  final List<Appointment> appointment;

  const AppointmentsScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    // Sorting logic
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 50.0, bottom: 5),
                child: Text(
                  "Rendez Vous",
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
                          top: 20, right: 0, left: 0, bottom: 30),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                SizedBox(
                                    height:
                                        20), // Espacement amélioré pour plus de clarté
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          20), // Coins plus arrondis
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.05), // Ombre plus douce
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: Offset(0, 2), // Ombre subtile
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.view_agenda,
                                          size: 25,
                                          color: Color.fromARGB(255, 255, 112,
                                              137)), // Utilisation de la couleur rose spécifiée précédemment
                                      title: Text(
                                        "Consulter vos rendez-vous",
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
                                                  AppointmentsListView(
                                                appointment: _localappointment,
                                              ),
                                            ));
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
                                ), // Diviseur plus clair
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.calendar_today,
                                          size: 25,
                                          color: Color.fromARGB(
                                              255, 255, 112, 137)),
                                      title: Text(
                                        "Calendrier de disponibilité",
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
                                                  CalendarDisponibility(),
                                            ));
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
