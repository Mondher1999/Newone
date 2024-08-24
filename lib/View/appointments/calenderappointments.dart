import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:madidou/View/auth/login_view.dart';
import 'package:madidou/bloc/appointment/appointment_bloc.dart';
import 'package:madidou/bloc/appointment/appointment_event.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/disponibility/disponibility_bloc.dart';
import 'package:madidou/bloc/disponibility/disponibility_event.dart';
import 'package:madidou/bloc/disponibility/disponibility_state.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import necessary for locale data

class StylishCalendarScreen extends StatefulWidget {
  final Property property; // Add this line to accept property details
  const StylishCalendarScreen({Key? key, required this.property})
      : super(key: key);

  @override
  _StylishCalendarScreenState createState() => _StylishCalendarScreenState();
}

class _StylishCalendarScreenState extends State<StylishCalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  List<dynamic> _disponibilities = []; // Store disponibilities
  List<DateTime> _highlightedDates = []; // Dates to highlight

  @override
  void initState() {
    super.initState();

    print(widget.property.userId);
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    initializeDateFormatting('fr_FR', null); // Initialize date formatting
    BlocProvider.of<DisponibilityBloc>(context)
        .add(GetDisponibilitiesEvent(widget.property.userId));
  }

  String? userId = AuthService.firebase().currentUser?.id;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DisponibilityBloc, DisponibilityState>(
      listener: (context, state) {
        if (state is DisponibilitiesLoaded) {
          updateDisponibilities(state.disponibilities);
        } else if (state is DisponibilityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error fetching disponibilities: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 55.0, bottom: 0, right: 10, left: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 0, bottom: 50),
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
                const SizedBox(height: 0.0),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 0.0, bottom: 20),
                    child: Text(
                      "Disponibilité de propriétaire",
                      style: TextStyle(
                        fontSize: 23,
                        color: Color(0xFF5e5f99),
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                      top: 0.0, right: 20, left: 20, bottom: 50),
                  child: const Text(
                    "Merci de choisir parmi les dates disponibles, indiquées par une marque verte, pour fixer votre rendez-vous.",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 0.0),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: Colors.white,
                    // Light greyish-purple card background
                    elevation: 7,
                    shadowColor: Colors.grey.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: TableCalendar(
                        locale: 'fr_FR',
                        firstDay:
                            DateTime.now(), // Set first selectable day to today

                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        eventLoader: (day) => _highlightedDates
                            .where((d) => isSameDay(d, day))
                            .toList(),
                        onDaySelected: (selectedDay, focusedDay) {
                          if (_highlightedDates
                              .any((day) => isSameDay(day, selectedDay))) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => buildDisponibilityDetails(
                                  context, selectedDay),
                            );
                          } else {
                            // Optionally show a message if the day is not available
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Choisir une date parmi les dates de disponibilité.',
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.w600, // Set font weight
                                      fontSize: 13, // Set font size
                                      fontFamily:
                                          'Montserrat' // Set font family
                                      ),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color.fromARGB(255, 255, 112,
                                    137), // Set the background color
                              ),
                            );
                            ;
                          }
                        },
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                          markerDecoration: BoxDecoration(
                            color: Colors
                                .blue, // Color for days with disponibilities
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Montserrat'),
                          defaultTextStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5e5f99),
                              fontSize: 16,
                              fontFamily: 'Montserrat'),
                          todayTextStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Montserrat'),
                          todayDecoration: const BoxDecoration(
                            color: Color(0xFF5e5f99),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 112, 137),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5e5f99),
                              fontFamily: 'Montserrat'),
                          leftChevronIcon: Icon(Icons.chevron_left,
                              color: Color(0xFF5e5f99), size: 30),
                          rightChevronIcon: Icon(Icons.chevron_right,
                              color: Color(0xFF5e5f99), size: 30),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              // Assuming events are your disponibilities
                              return Positioned(
                                right: 1,
                                bottom: 1,
                                child: _buildDisponibilityMarker(
                                    date, events.length),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisponibilityMarker(DateTime date, int count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: Colors.green[400], // Updated to a green color
        shape: BoxShape.rectangle, // Rectangle with rounded corners
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!
                .withOpacity(0.5), // Match the shadow color to the container
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1), // Positioning the shadow
          ),
        ],
      ),
      width: 20, // Size to adequately fit the icon
      height: 20,
      child: const Center(
        child: Icon(
          Icons.check, // Using a checkmark icon
          color: Colors.white,
          size: 15, // Size of the icon inside the container
        ),
      ),
    );
  }

  Widget buildDisponibilityDetails(BuildContext context, DateTime selectedDay) {
    List<dynamic> dayDisponibilities = _disponibilities.where((disponibility) {
      return disponibility['dates'].any((dateString) {
        String cleanedDateString = dateString.replaceAll(RegExp(r'[^\d/]'), '');
        List<String> parts = cleanedDateString.split('/');
        try {
          DateTime date = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          return isSameDay(date, selectedDay);
        } catch (e) {
          debugPrint('Error parsing date: $cleanedDateString, Error: $e');
          return false;
        }
      });
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.25, // Adapt height to 80% of screen height
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            'Votre rendez vous sera fixer ${DateFormat('dd/MM/yyyy').format(selectedDay)}',
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => handleReservation(
                  userId!, context), // Ensure propertyId is passed correctly
              style: ElevatedButton.styleFrom(
                  elevation: 5,
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 255, 112, 137)),
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleReservation(String propertyId, BuildContext context) {
    if (_selectedDay != null) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmer la réservation'),
            content: Text(
                'Êtes-vous sûr de vouloir réserver un rendez-vous le ${DateFormat('yyyy-MM-dd').format(_selectedDay!)} ?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: const Text('Confirmer'),
                onPressed: () {
                  createOrUpdateAppointment(propertyId, context,
                      dialogContext); // Adjusted to pass dialogContext
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Aucune date sélectionnée ! Veuillez sélectionner une date d'abord."),
        backgroundColor: Colors.red[800],
      ));
    }
  }

  void confirmAndLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "Réservation confirmée pour le ${DateFormat('dd-MM-yyyy').format(_selectedDay!)}." +
              "Vous recevrez une notification lorsque le propriétaire acceptera le rendez-vous.",
          style: TextStyle(
            fontFamily: "Montserrat", // Apply Montserrat font family
            fontWeight: FontWeight.w600, // Set font weight to w600
          )),
      backgroundColor: const Color.fromARGB(
          255, 255, 112, 137), // Set the specified pinkish color
      duration: const Duration(milliseconds: 6000),
    ));

    // Wait for the SnackBar to be shown before navigating back
    Future.delayed(Duration(milliseconds: 5000), () {
      Navigator.of(context).pop(); // Navigates back to the previous screen
    });
  }

  void createOrUpdateAppointment(
      String propertyId, BuildContext context, BuildContext dialogContext,
      {String? appointmentId}) {
    final String? userId = AuthService.firebase().currentUser?.id;

// This should come from your user session or similar
    // Determine how you get this ID

    final appointmentData = {
      'ownerId': widget.property.userId,
      'idproperty': widget.property.id,
      'dateAppointment': _selectedDay!.toIso8601String(),
      'status': 'En attente'
    };

    // If appointmentId is not provided, treat this as a new appointment creation
    BlocProvider.of<AppointmentBloc>(context).add(CreateAppointmentEvent(
        userId: userId!, appointmentData: appointmentData));

    Navigator.of(dialogContext).pop(); // Close the dialog after confirming
    Navigator.of(context)
        .pop(); // Close the bottom sheet modal after the dialog

    // Display confirmation message and handle logout if necessary
    confirmAndLogout(context);
  }

  void updateDisponibilities(List<dynamic> disponibilities) {
    setState(() {
      _disponibilities = disponibilities;
      _highlightedDates = [];
      for (var disponibility in disponibilities) {
        for (var dateString in disponibility['dates']) {
          // Remove potential extra quotes
          var cleanedDateString = dateString.replaceAll('"', '').trim();
          var parts = cleanedDateString.split('/');
          var date = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          _highlightedDates.add(date);
        }
      }
    });
  }
}
