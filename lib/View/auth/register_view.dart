import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/messages/message_list_view.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/disponibility/disponibility_bloc.dart';
import 'package:madidou/bloc/disponibility/disponibility_event.dart';
import 'package:madidou/bloc/housingFile/housingFile_bloc.dart';
import 'package:madidou/bloc/housingFile/housingFile_event.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/data/model/housingFile.dart';
import 'package:madidou/data/model/user.dart';
import 'package:madidou/services/auth/auth_exceptions.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/utilities/dialogs/error_dialog.dart';
import 'package:madidou/utilities/dialogs/verification_account.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

class RegisterScreenTest extends StatefulWidget {
  const RegisterScreenTest({super.key});

  @override
  State<RegisterScreenTest> createState() => _RegisterScreenTestState();
}

class _RegisterScreenTestState extends State<RegisterScreenTest> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  final user = AuthService.firebase().currentUser?.id;
  TextEditingController _dateNaissance = TextEditingController();
  late DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Default to month view

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _nom = TextEditingController();
    _prenom = TextEditingController();
    _dateNaissance = TextEditingController();
    initializeDateFormatting('fr_FR', null);

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _prenom.dispose();
    _nom.dispose();
    _password.dispose();
    _dateNaissance.dispose();

    super.dispose();
  }

  // Fonction pour afficher le DatePicker et mettre à jour le texte du controller
  // Function to show date picker
  // Function to show date picker
  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime earliestDate =
        DateTime(today.year - 18, today.month, today.day);

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
                          color: Color.fromARGB(255, 255, 112, 137),
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
                        focusedDay: _focusedDay,
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
                            color: Color.fromARGB(255, 255, 112, 137),
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
        _dateNaissance.text =
            DateFormat('dd/MM/yyyy', 'fr_FR').format(pickedDate);
      });
    }
  }

  void _submitUser(String iduser) {
    final user = Users(
      id: iduser, // Will be assigned by the server
      nom: _nom.text,
      prenom: _prenom.text,
      dateNaissance: _dateNaissance.text,
      role: 'Locataire',
      email: _email.text,
      fileUrl: '', // Updated after image upload
      adresse: 'adresse',
      numeroTel: '0',
      maritalSatiation: 'non sélection',
      nbrChildren: 'non sélection',
      monthlyIncome: 'non sélection',
      moveInDate: '01/05/2010',
      housingAid: 'non sélection',
      noticePeriod: 'non sélection',
      validefilesuser: 'non validé',
      valideinfouser: 'non validé',
      jobSatiation:
          'non sélection', // Ideally, this should come from your auth system
    );

    BlocProvider.of<UserBloc>(context).add(AddUser(user, imagePath: ''));
    BlocProvider.of<HousingFileBloc>(context).add(CreateHousingFile(
      userId: AuthService.firebase().currentUser!.id,
    ));

    BlocProvider.of<DisponibilityBloc>(context).add(CreateDisponibilityEvent(
        userId: AuthService.firebase().currentUser!.id)); // Ensure
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre adresse e-mail.';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return 'Veuillez saisir une adresse e-mail valide.';
    }
    return null;
  }

  String? _nomValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre Nom.';
    }
    return null;
  }

  String? _prenomValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre Prenom.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Mot de passe faible");
          } else if (state.exception is EmailAlreadyInUseException) {
            await showErrorDialog(context, 'Email déjà utilisé');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Échec de l'inscription");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Adresse e-mail invalide');
          }
        }

        if (state is AuthStateRegistrationSuccess) {
          // Now that you have the userId, use it
          if (_formKey.currentState!.validate()) {
            _submitUser(state.userId);
            await showVerificationDialog(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(""),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventShouldLogIn(),
                  );
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créer un compte',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: "Montserrat",
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Complétez vos informations .',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: "Montserrat",
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _prenom,
                          validator: _prenomValidator,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Prénom',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      const Color.fromARGB(255, 110, 110, 110),
                                  fontFamily: "Montserrat",
                                ),
                          ),
                        ),
                        TextFormField(
                          controller: _nom,
                          validator: _nomValidator,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Nom.',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      const Color.fromARGB(255, 110, 110, 110),
                                  fontFamily: "Montserrat",
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Assurez-vous qu'il correspond au nom figurant sur votre piéce d'identité",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: "Montserrat",
                                  ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _dateNaissance,
                          readOnly: true, // Make this field read-only
                          decoration: InputDecoration(
                            hintText: 'Anniversaire',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      const Color.fromARGB(255, 110, 110, 110),
                                  fontFamily: "Montserrat",
                                ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer votre date d'anniversaire";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Vous devez avoir au moins 18 ans pour vous inscrire.Les autres utilisateurs de Madidou ne verront pas votre date d'anniversaire",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: "Montserrat",
                                  ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              hintText: 'Adresse e-mail.'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 110, 110, 110),
                                fontFamily: "Montserrat",
                              ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Nous vous enverrons une confirmation de réservation par e-mail",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: "Montserrat",
                                  ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          obscureText: _obscureText,
                          controller: _password,
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      const Color.fromARGB(255, 110, 110, 110),
                                  fontFamily: "Montserrat",
                                ),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: _passwordValidator,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              AuthEventRegister(
                                email,
                                password,
                              ),
                            );
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                          Colors.white), // Change text color here
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 48)),
                    ),
                    child: Text(
                      'Continuer',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: "Montserrat",
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
