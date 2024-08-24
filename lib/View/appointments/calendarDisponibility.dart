import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:madidou/bloc/disponibility/disponibility_bloc.dart';
import 'package:madidou/bloc/disponibility/disponibility_event.dart';
import 'package:madidou/bloc/disponibility/disponibility_state.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarDisponibility extends StatefulWidget {
  const CalendarDisponibility({Key? key}) : super(key: key);

  @override
  _CalendarDisponibilityState createState() => _CalendarDisponibilityState();
}

class _CalendarDisponibilityState extends State<CalendarDisponibility> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  Set<DateTime> _selectedDays = {};

  List<dynamic> _disponibilities = [];
  List<DateTime> _highlightedDates = [];

  @override
  void initState() {
    super.initState();
    final String? userId = AuthService.firebase().currentUser?.id;
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    initializeDateFormatting('fr_FR', null);
    BlocProvider.of<DisponibilityBloc>(context)
        .add(GetDisponibilitiesEvent(userId!));
  }

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
        } else if (state is DisponibilityUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Disponibilities updated successfully'),
              backgroundColor: Colors.green[700],
            ),
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
                      "Calendrier de Disponibilité",
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
                  child: Text(
                    "Merci de sélectionner les dates où vous êtes disponible pour vos rendez-vous.",
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
                    elevation: 7,
                    shadowColor: Colors.grey.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TableCalendar(
                        locale: 'fr_FR',
                        firstDay: DateTime.now(),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            _selectedDays.contains(day),
                        eventLoader: (day) => _highlightedDates
                            .where((d) => isSameDay(d, day))
                            .toList(),
                        onDaySelected: (selectedDay, focusedDay) {
                          DateTime normalizedSelectedDay =
                              normalizeDate(selectedDay);
                          if (!_highlightedDates
                              .contains(normalizedSelectedDay)) {
                            setState(() {
                              if (_selectedDays
                                  .contains(normalizedSelectedDay)) {
                                _selectedDays.remove(normalizedSelectedDay);
                              } else {
                                _selectedDays.add(normalizedSelectedDay);
                              }
                              _focusedDay = focusedDay;
                            });
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
                            color: Colors.blue,
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
                          todayDecoration: BoxDecoration(
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
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0, left: 22),
                  child: ElevatedButton(
                    onPressed: () => updateDisponibility(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 255, 112, 137),
                    ),
                    child: const Text(
                      'Ajouter vos dates de disponibilité',
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
          ),
        ),
      ),
    );
  }

  Widget _buildDisponibilityMarker(DateTime date, int count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: Colors.green[400],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      width: 20,
      height: 20,
      child: const Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }

  void updateDisponibility(BuildContext context) {
    final String? userId = AuthService.firebase().currentUser?.id;

    if (userId != null) {
      List<String> updateData = _selectedDays.map((day) {
        return "${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}";
      }).toList();

      BlocProvider.of<DisponibilityBloc>(context).add(
          UpdateDisponibilityEvent(userId: userId, updateData: updateData));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Dates ajoutées avec succès.",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Color(0xFF5e5f99),
        duration: Duration(seconds: 1), // Set the duration to 1 second
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Erreur: L'utilisateur n'est pas connecté."),
        backgroundColor: Colors.red[800],
        duration: Duration(seconds: 1), // Set the duration to 1 second
      ));
    }
  }

  void updateDisponibilities(List<dynamic> disponibilities) {
    Set<DateTime> newHighlightedDates = Set();
    for (var disponibility in disponibilities) {
      for (var dateString in disponibility['dates']) {
        var cleanedDateString = dateString.replaceAll('"', '').trim();
        var parts = cleanedDateString.split('/');
        var date = normalizeDate(DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])));
        newHighlightedDates.add(date);
      }
    }

    setState(() {
      _highlightedDates = newHighlightedDates.toList();
      // Remove highlighted dates from selected days
      _selectedDays
          .removeWhere((day) => _highlightedDates.contains(normalizeDate(day)));
    });
  }
}
