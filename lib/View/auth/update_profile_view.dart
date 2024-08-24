import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/model/user.dart';
import 'package:intl/intl.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _email;
  late TextEditingController _nom;
  late TextEditingController _prenom;
  late TextEditingController _dateNaissance;
  late TextEditingController _adresse;
  late TextEditingController _numeroTel;
  late TextEditingController _maritalStatus;
  late TextEditingController _nbrChildren;
  late TextEditingController _monthlyIncome;
  late TextEditingController _jobStatus;
  late TextEditingController _role;
  late TextEditingController _moveInDate;
  late TextEditingController _housingAid;
  late TextEditingController _noticePeriod;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedJobStatus;
  String? _selectedMaritalStatus;
  String? _selectedNumberOfChildren;
  String? _selectedMonthlyIncome;
  String? _selectedHousingAid;
  String? _selectedNoticePeriod;

  final List<DropdownMenuItem<String>> jobStatusOptions = [
    const DropdownMenuItem(
        child: Text('non sélection'), value: 'non sélection'),
    const DropdownMenuItem(child: Text('Salarié'), value: 'Salarié'),
    const DropdownMenuItem(child: Text('Entrepreneur'), value: 'Entrepreneur'),
    const DropdownMenuItem(
        child: Text('Profession libérale'), value: 'Profession libérale'),
    const DropdownMenuItem(child: Text('Artisant'), value: 'Artisant'),
  ];

  final List<DropdownMenuItem<String>> maritalStatusOptions = [
    const DropdownMenuItem(
        child: Text('non sélection'), value: 'non sélection'),
    const DropdownMenuItem(child: Text('Célibataire'), value: 'Célibataire'),
    const DropdownMenuItem(child: Text('Marié(e)'), value: 'Marié(e)'),
    const DropdownMenuItem(child: Text('Divorcé(e)'), value: 'Divorcé(e)'),
    const DropdownMenuItem(child: Text('Veuf(ve)'), value: 'Veuf(ve)'),
  ];
  final List<DropdownMenuItem<String>> numberOfChildrenOptions = [
    const DropdownMenuItem(
        child: Text('non sélection'), value: 'non sélection'),
    const DropdownMenuItem(child: Text('0'), value: '0'),
    const DropdownMenuItem(child: Text('1'), value: '1'),
    const DropdownMenuItem(child: Text('2'), value: '2'),
    const DropdownMenuItem(child: Text('3'), value: '3'),
    const DropdownMenuItem(child: Text('4+'), value: '4+'),
  ];

  final List<DropdownMenuItem<String>> monthlyIncomeOptions = [
    const DropdownMenuItem(
        child: Text('non sélection'), value: 'non sélection'),
    const DropdownMenuItem(child: Text('1300-1800€'), value: '1300-1800€'),
    const DropdownMenuItem(child: Text('1800-2300€'), value: '1800-2300€'),
    const DropdownMenuItem(child: Text('2300-2800€'), value: '2300-2800€'),
    const DropdownMenuItem(child: Text('3000+ €'), value: '3000+ €'),
  ];

  final List<DropdownMenuItem<String>> noticePeriodOptions = [
    const DropdownMenuItem(
        child: Text('non sélection'), value: 'non sélection'),
    const DropdownMenuItem(child: Text('1 mois'), value: '1 mois'),
    const DropdownMenuItem(child: Text('2 mois'), value: '2 mois'),
    const DropdownMenuItem(child: Text('3 mois'), value: '3 mois'),
    const DropdownMenuItem(child: Text('4 mois +'), value: '4 mois +'),
  ];

  final List<DropdownMenuItem<String>> housingAidOptions = [
    const DropdownMenuItem(
        child: Text('non sélection'), value: 'non sélection'),
    const DropdownMenuItem(child: Text('Aucune'), value: 'Aucune'),
    const DropdownMenuItem(
        child: Text('Aide partielle'), value: 'Aide partielle'),
    const DropdownMenuItem(
        child: Text('Allocation logement'), value: 'Allocation logement'),
    const DropdownMenuItem(
        child: Text('Aide complète'), value: 'Aide complète'),
  ];

  @override
  void initState() {
    super.initState();
    initializeControllers();
    initializeDateFormatting('fr_FR', null);

    _selectedJobStatus =
        jobStatusOptions.first.value; // Set default values similarly
    _selectedMaritalStatus = maritalStatusOptions.first.value;
    _selectedNumberOfChildren = numberOfChildrenOptions.first.value;
    _selectedMonthlyIncome = monthlyIncomeOptions.first.value;
    _selectedHousingAid = housingAidOptions.first.value;
    _selectedNoticePeriod = noticePeriodOptions.first.value;
    final String? userId = AuthService.firebase().currentUser?.id;
    if (userId != null) {
      BlocProvider.of<UserBloc>(context, listen: false).add(FetchUser(userId));
    }
  }

  void initializeControllers() {
    _email = TextEditingController();
    _nom = TextEditingController();
    _prenom = TextEditingController();
    _dateNaissance = TextEditingController();
    _adresse = TextEditingController();
    _maritalStatus = TextEditingController(); // Make sure this is initialized

    _numeroTel = TextEditingController();

    _role = TextEditingController();
    _moveInDate = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _nom.dispose();
    _prenom.dispose();
    _dateNaissance.dispose();
    _adresse.dispose();
    _numeroTel.dispose();
    _maritalStatus.dispose();

    super.dispose();
  }

  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      final String? userId = AuthService.firebase().currentUser?.id;
      if (userId == null) {
        print("User ID is null, cannot update");
        return;
      }

      final updatedUser = Users.withoutFileUrl(
        id: userId,

        // Ensure this is either correctly fetched or handled if not needed
        nom: _nom.text,
        prenom: _prenom.text,
        dateNaissance: _dateNaissance.text,
        email: _email.text,
        adresse: _adresse.text,
        numeroTel: _numeroTel.text,
        maritalSatiation: _selectedMaritalStatus.toString(),
        nbrChildren: _selectedNumberOfChildren.toString(),
        monthlyIncome: _selectedMonthlyIncome.toString(),
        jobSatiation: _selectedJobStatus.toString(),
        role: _role.text,
        moveInDate: _moveInDate.text,
        housingAid: _selectedHousingAid.toString(),
        noticePeriod: _selectedNoticePeriod.toString(),
      );

      BlocProvider.of<UserBloc>(context).add(UpdateUser(updatedUser));

      Navigator.pop(context); // Optionally close the screen after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, size: 30, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16),
                  child: BlocListener<UserBloc, UserState>(
                    listener: (context, state) {
                      if (state is UserLoadSuccess) {
                        updateUserTextFields(state.user);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5.0),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 20.0, top: 10.0, bottom: 5),
                          child: Text(
                            "Informations personnelles",
                            style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFF5e5f99),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: buildFormFields(context),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateUser,
        icon: const Icon(
            Icons.save), // Optional: remove if you don't want an icon
        label: const Text('Sauvegarder',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat")), // Text on the button
        backgroundColor:
            const Color.fromARGB(255, 255, 112, 137), // Button color
        foregroundColor: Colors.white, // Text and icon color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Column buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: SizedBox(
            width:
                350, // Set the width of the container to determine the length of the divider
            child: Divider(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 5, left: 20.0),
          child: Text(
            "Nom légal",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: "Montserrat",
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _buildTextField(_prenom, 'Prénom'),
        _buildTextField(_nom, 'Nom'),
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 20.0),
          child: Text(
            "Assurez-vous qu'il correspond au nom figurant sur votre piéce d'identité",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: "Montserrat",
                ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: SizedBox(
            width:
                350, // Set the width of the container to determine the length of the divider
            child: Divider(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 5, left: 20.0),
          child: Text(
            "Adesse courriel ",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: "Montserrat",
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _buildTextField(_email, 'Email', isEnabled: false),
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: SizedBox(
            width:
                350, // Set the width of the container to determine the length of the divider
            child: Divider(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 5, left: 20.0),
          child: Text(
            "Informations facultatives ",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: "Montserrat",
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _buildDateField(context, _dateNaissance, 'Date de naissance'),
        _buildTextField(_adresse, 'Adresse'),
        _buildTextField(_numeroTel, 'Numéro de téléphone'),
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 20.0),
          child: Text(
            "Veuillez vous assurer que les informations fournies sont exactes et à jour.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: "Montserrat",
                ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: SizedBox(
            width:
                350, // Set the width of the container to determine the length of the divider
            child: Divider(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 5, left: 20.0),
          child: Text(
            "Informations facultatives ",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: "Montserrat",
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _buildDropdownField(
            maritalStatusOptions, _selectedMaritalStatus, 'Statut marital',
            (newValue) {
          setState(() {
            _selectedMaritalStatus = newValue;
          });
        }),
        _buildDropdownField(numberOfChildrenOptions, _selectedNumberOfChildren,
            'Nombre d\'enfants', (newValue) {
          setState(() {
            _selectedNumberOfChildren = newValue;
          });
        }),
        _buildDropdownField(
            monthlyIncomeOptions, _selectedMonthlyIncome, 'Revenu mensuel',
            (newValue) {
          setState(() {
            _selectedMonthlyIncome = newValue;
          });
        }),
        _buildDropdownField(
            jobStatusOptions, _selectedJobStatus, 'Statut professionnel',
            (newValue) {
          setState(() {
            _selectedJobStatus = newValue;
          });
        }),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20.0, bottom: 10),
          child: Text(
            "Veuillez vous assurer que les informations fournies sont exactes et à jour.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: "Montserrat",
                ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          child: SizedBox(
            width:
                350, // Set the width of the container to determine the length of the divider
            child: Divider(),
          ),
        ),
        _buildDateField(context, _moveInDate, 'Date d\'emménagement'),
        _buildDropdownField(
            housingAidOptions, _selectedHousingAid, 'Aide au logement',
            (newValue) {
          setState(() {
            _selectedHousingAid = newValue;
          });
        }),
        _buildDropdownField(
            noticePeriodOptions, _selectedNoticePeriod, 'Période de préavis',
            (newValue) {
          setState(() {
            _selectedNoticePeriod = newValue;
          });
        }),
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 20.0),
          child: Text(
            "Veuillez vous assurer que les informations fournies sont exactes et à jour.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: "Montserrat",
                ),
          ),
        ),
        const SizedBox(
          height:
              100, // Set the width of the container to determine the length of the divider
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isEnabled = true}) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10, right: 10.0, bottom: 12, top: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),

          // Optionally gray out the label when disabled
          labelStyle: isEnabled
              ? TextStyle(color: Theme.of(context).colorScheme.secondary)
              : TextStyle(color: Colors.grey),
        ),
        enabled: isEnabled, // Control based on isEnabled flag
      ),
    );
  }

  void updateUserTextFields(Users user) {
    _email.text = user.email ?? '';
    _nom.text = user.nom ?? '';
    _prenom.text = user.prenom ?? '';
    _dateNaissance.text = user.dateNaissance ?? '';
    _adresse.text = user.adresse ?? '';
    _numeroTel.text = user.numeroTel ?? '';
    _moveInDate.text = user.moveInDate ?? '';
    _role.text = user.role ?? '';
    _selectedMaritalStatus =
        user.maritalSatiation ?? maritalStatusOptions.first.value;
    _selectedNumberOfChildren =
        user.nbrChildren ?? numberOfChildrenOptions.first.value;
    _selectedMonthlyIncome =
        user.monthlyIncome ?? monthlyIncomeOptions.first.value;
    _selectedJobStatus = user.jobSatiation ?? jobStatusOptions.first.value;
    _selectedHousingAid = user.housingAid ?? housingAidOptions.first.value;
    _selectedNoticePeriod =
        user.noticePeriod ?? noticePeriodOptions.first.value;

    setState(() {}); // Refresh the UI with the new data
  }

  Widget _buildDropdownField(
      List<DropdownMenuItem<String>> items,
      String? selectedValue,
      String labelText,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10, right: 10.0, bottom: 12, top: 12),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime today = DateTime.now();
    final DateTime earliestDate =
        DateTime(today.year - 18, today.month, today.day);
    final DateTime initialDate = DateFormat('dd/MM/yyyy')
        .parse(controller.text.isNotEmpty ? controller.text : '01/01/2000');

    // Adjust the focused day if it's beyond the last allowed day
    if (_focusedDay.isAfter(earliestDate)) {
      _focusedDay = earliestDate;
    }

    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Sélectionner une date',
                        style: TextStyle(
                          color: const Color(0xFF5e5f99),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      child: TableCalendar(
                        locale: 'fr_FR',
                        firstDay: DateTime.utc(1900, 1, 1),
                        lastDay: earliestDate,
                        focusedDay: _focusedDay.isBefore(earliestDate)
                            ? _focusedDay
                            : earliestDate,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          Navigator.of(context).pop(
                              selectedDay); // Close dialog on date selection
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
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronIcon: Icon(Icons.chevron_left,
                              color: const Color(0xFF5e5f99)),
                          rightChevronIcon: Icon(Icons.chevron_right,
                              color: const Color(0xFF5e5f99)),
                          titleTextStyle: TextStyle(
                            color: const Color(0xFF5e5f99),
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                          ),
                          headerPadding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        calendarBuilders: CalendarBuilders(
                          headerTitleBuilder: (context, day) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Month Dropdown
                                DropdownButton<int>(
                                  value: _focusedDay.month,
                                  items: List.generate(12, (index) => index + 1)
                                      .map((month) {
                                    return DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        DateFormat.MMMM('fr_FR')
                                            .format(DateTime(0, month)),
                                        style: TextStyle(
                                          color: const Color(0xFF5e5f99),
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _focusedDay = DateTime(_focusedDay.year,
                                            value, _focusedDay.day);
                                      });
                                    }
                                  },
                                ),
                                // Year Dropdown
                                DropdownButton<int>(
                                  value: _focusedDay.year,
                                  items: List.generate(today.year - 1900 + 1,
                                          (index) => today.year - index)
                                      .map((year) {
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text(
                                        year.toString(),
                                        style: TextStyle(
                                          color: const Color(0xFF5e5f99),
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _focusedDay = DateTime(value,
                                            _focusedDay.month, _focusedDay.day);
                                      });
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 112, 137),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: const Color(0xFF5e5f99),
                            shape: BoxShape.circle,
                          ),
                          outsideDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          defaultTextStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                          ),
                          weekendTextStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                          ),
                          holidayTextStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5e5f99),
                          ),
                          weekendStyle: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5e5f99),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: Text('Annuler',
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w600)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('OK',
                              style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(context).pop(_selectedDay);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          backgroundColor: Colors.white,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller,
      String labelText) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 110, 110, 110),
                fontFamily: "Montserrat",
              ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller),
          ),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, controller),
      ),
    );
  }
}
