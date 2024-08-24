import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:madidou/View/appointments/Propri%C3%A9taire/informationDetailsScreen.dart';
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
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';

class AppointmentsListView extends StatefulWidget {
  final List<Appointment> appointment;

  const AppointmentsListView({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  _AppointmentsListViewState createState() => _AppointmentsListViewState();
}

class _AppointmentsListViewState extends State<AppointmentsListView> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    // Assuming widget.appointment is already populated with data fetched from the database

    // Debugging output
  }

  Future<bool> showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return const Color(0xFFfbbc05); // Google's material yellow
      case 'refusé':
        return const Color(0xFFea4335);
      case 'annulé':
        return const Color(0xFFea4335); // Google's material red
      case 'accepté':
        return const Color(0xFF34a853); // Google's material green
      default:
        return Colors.grey; // Default color if status is undefined
    }
  }

  final String? userId = AuthService.firebase().currentUser?.id;

  void _showCongratulatoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Félicitations!"),
          content: const Text(
              "Vous pouvez maintenant parler avec le locataire. "
              "Pour plus d'informations sur le locataire, merci de cliquer sur 'Voir les détails' "
              "dans le rendez-vous pour consulter les informations sur le locataire et ses documents."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Close the dialog first
                // Optionally navigate to details screen or perform other actions
              },
              child: const Text("D'accord"),
            ),
          ],
        );
      },
    );
  }

  Widget buildAppointmentCard(
    BuildContext context,
    Appointment appointment,
    Color cardColor,
    AuthState userState,
  ) {
    // Define specific colors for actions
    final Color cancelColor =
        const Color.fromARGB(255, 255, 112, 137); // Bright pink
    final Color modifyColor = const Color(0xFF5e5f99); // Deep purple
    final Color acceptColor =
        const Color(0xFF4CAF50); // Green for accept button
    final Color detailsColor =
        const Color(0xFF4CAF50); // Same green used for details

    List<Widget> buttons = [];

    if (appointment.status.toLowerCase() == 'refusé') {
      // Do not show any buttons if the status is 'refusé'
    } else {
      if (userState is AuthStateProprietaire) {
        if (appointment.status.toLowerCase() == 'accepté') {
          // "Voir les détails" button for accepted appointments
          buttons.add(
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformationDetailScreen(
                          userId: appointment.userId,
                        ),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: modifyColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Voir les détails",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
          buttons.add(const SizedBox(width: 8));

          // "Annuler" button for accepted appointments
          buttons.add(
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  bool confirm = await showConfirmationDialog(
                      context,
                      'Confirmation',
                      'Êtes-vous sûr de vouloir Annuler ce rendez-vous?');
                  if (confirm) {
                    BlocProvider.of<AppointmentBloc>(context).add(
                        CancelAppointmentProprietaireEvent(
                            appointmentid: appointment.id, userId: userId!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: cancelColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Annuler",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
        } else if (appointment.status == 'En attente') {
          buttons.add(
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Dispatch events to blocs
                  BlocProvider.of<AppointmentBloc>(context).add(
                      AcceptAppointmentEvent(
                          appointmentid: appointment.id, userId: userId!));
                  BlocProvider.of<UserBloc>(context).add(AddFriendEvent(
                      userId: appointment.ownerId,
                      friendId: appointment.userId));

                  // Show the congratulatory dialog
                  _showCongratulatoryDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: modifyColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Accepter",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );

          buttons.add(const SizedBox(width: 8));

          // "Annuler" button for accepted appointments
          buttons.add(
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  bool confirm = await showConfirmationDialog(
                      context,
                      'Confirmation',
                      'Êtes-vous sûr de vouloir refuser ce rendez-vous?');
                  if (confirm) {
                    BlocProvider.of<AppointmentBloc>(context).add(
                        RefuseAppointmentEvent(
                            appointmentid: appointment.id, userId: userId!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: cancelColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Refuser",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
          // "Accepter" and "Refuser" buttons for pending appointments
        }
      } else if (userState is AuthStateLocataire) {
        if (appointment.status.toLowerCase() == 'accepté') {
          // "Modifier la date" and "Annuler" buttons for accepted appointments for tenants
          buttons.add(
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StylishCalendarScreenUpdate(
                            appointment: appointment),
                      ));
                  // Action for changing the date
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: modifyColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Modifier la date",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
          buttons.add(const SizedBox(width: 8));
          buttons.add(
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  bool confirm = await showConfirmationDialog(
                      context,
                      'Confirmation',
                      'Êtes-vous sûr de vouloir Annuler ce rendez-vous?');
                  if (confirm) {
                    BlocProvider.of<AppointmentBloc>(context).add(
                        CancelAppointmentLocataireEvent(
                            appointmentid: appointment.id, userId: userId!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: cancelColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Annuler",
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
        }
      }
    }

    return InkWell(
      onTap: () {
        // Action for tapping on the card
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(24), // Increased rounding for a softer look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Very subtle shadow
              blurRadius: 20,
              offset: Offset(0, 10), // Raised effect for a floating appearance
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: Colors.black87,
                      size: 24), // Pink accent color for icons
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'fr_FR')
                          .format(appointment.dateAppointment),
                      style: TextStyle(
                          fontFamily:
                              "Montserrat", // Modern and accessible font
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: cardColor, borderRadius: BorderRadius.circular(10)),
                child: Text("Statut : ${appointment.status}",
                    style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16)),
              ),
              SizedBox(height: 20),
              Text(
                "Ref de propriété : ${appointment.propertyId}",
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey[900] // Subtle, sophisticated text color
                    ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttons,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthStateProprietaire) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 20.0, bottom: 5),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_outlined),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 20, top: 30.0, bottom: 5),
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
                    ],
                  );
                } else {
                  // Return this widget if the state does not match AuthStateProprietaire
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, top: 50.0, bottom: 5),
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
                  );
                }
              },
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
                  } else if (authState is AuthStateLocataire) {
                    // User is logged in, show favorite properties
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, right: 10, left: 10, bottom: 30),
                      child: Column(
                        children: [
                          Expanded(
                            child:
                                BlocBuilder<AppointmentBloc, AppointmentState>(
                              builder: (context, state) {
                                if (state is AppointmentsLoaded) {
                                  return ListView.builder(
                                    itemCount: state.appointments.length,
                                    itemBuilder: (context, index) {
                                      final Appointment appointment =
                                          state.appointments[index];
                                      Color cardColor =
                                          getStatusColor(appointment.status);
                                      // Assuming authState is available here, directly derived from BlocBuilder or some context
                                      return Container(
                                        margin: const EdgeInsets.only(
                                            bottom:
                                                20), // Adds space at the bottom of each card
                                        child: buildAppointmentCard(context,
                                            appointment, cardColor, authState),
                                      );
                                    },
                                  );
                                } else if (state is AppointmentLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is AppointmentError) {
                                  if (state.message.contains(
                                      "pas de rendez-vous programmés")) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .error_outline, // Icône pour l'erreur
                                            color: Color.fromARGB(
                                                255, 255, 112, 137),
                                            size: 40,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Vous n'avez pas de rendez-vous programmés",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 112, 137),
                                              fontFamily: "Montserrat",
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .error_outline, // Icône pour l'erreur
                                            color: Color.fromARGB(
                                                255, 255, 112, 137),
                                            size: 50,
                                          ),
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 0.0, bottom: 50),
                                            child: Text(
                                              "Vous n'avez pas de rendez-vous programmés",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 112, 137),
                                                fontFamily: "Montserrat",
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  return Container(); // Default widget in case of an undefined state
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (authState is AuthStateProprietaire) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, right: 10, left: 10, bottom: 30),
                      child: Column(
                        children: [
                          Expanded(
                            child:
                                BlocBuilder<AppointmentBloc, AppointmentState>(
                              builder: (context, state) {
                                if (state is AppointmentsLoaded) {
                                  return ListView.builder(
                                    itemCount: state.appointments.length,
                                    itemBuilder: (context, index) {
                                      final appointment =
                                          state.appointments[index];
                                      Color cardColor =
                                          getStatusColor(appointment.status);
                                      return Container(
                                        margin: const EdgeInsets.only(
                                            bottom:
                                                20), // Adds space at the bottom of each card
                                        child: buildAppointmentCard(context,
                                            appointment, cardColor, authState),
                                      );
                                    },
                                  );
                                } else if (state is AppointmentLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is AppointmentError) {
                                  if (state.message.contains(
                                      "pas de rendez-vous programmés")) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .error_outline, // Icône pour l'erreur
                                            color: Color.fromARGB(
                                                255, 255, 112, 137),
                                            size: 50,
                                          ),
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 0.0, bottom: 50),
                                            child: Text(
                                              "Vous n'avez pas de rendez-vous programmés",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 112, 137),
                                                fontFamily: "Montserrat",
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .error_outline, // Icône pour l'erreur
                                            color: Color.fromARGB(
                                                255, 255, 112, 137),
                                            size: 50,
                                          ),
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 0.0, bottom: 50),
                                            child: Text(
                                              "Vous n'avez pas de rendez-vous programmés",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 112, 137),
                                                fontFamily: "Montserrat",
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  return Container(); // Default widget in case of an undefined state
                                }
                              },
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
