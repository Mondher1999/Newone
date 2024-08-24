import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/bloc/user/user_state.dart';
import 'package:madidou/data/model/user.dart';
import 'package:intl/intl.dart';
import 'package:madidou/services/auth/auth_service.dart';

class ProfilLocataire extends StatefulWidget {
  final String userId;

  const ProfilLocataire({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilLocataire> createState() => _ProfilLocataireState();
}

class _ProfilLocataireState extends State<ProfilLocataire> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _email;
  late TextEditingController _nom;
  late TextEditingController _prenom;
  late TextEditingController _dateNaissance;
  late TextEditingController _adresse;
  late TextEditingController _numeroTel;
  late TextEditingController _maritalStatus;

  late TextEditingController _role;
  late TextEditingController _moveInDate;

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
    _selectedJobStatus =
        jobStatusOptions.first.value; // Set default values similarly
    _selectedMaritalStatus = maritalStatusOptions.first.value;
    _selectedNumberOfChildren = numberOfChildrenOptions.first.value;
    _selectedMonthlyIncome = monthlyIncomeOptions.first.value;
    _selectedHousingAid = housingAidOptions.first.value;
    _selectedNoticePeriod = noticePeriodOptions.first.value;
    final String? userId = AuthService.firebase().currentUser?.id;
    if (userId != null) {
      BlocProvider.of<UserBloc>(context, listen: false)
          .add(FetchUser(widget.userId));
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
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
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
                              color: Colors.deepPurple,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Column buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoubleDisplayField("Prénom", _prenom.text, Icons.person_outline,
            "Nom", _nom.text, Icons.person_outline),
        _buildDisplayField("Email", _email.text, Icons.email_outlined),
        _buildDisplayField(
            "Date de naissance", _dateNaissance.text, Icons.cake_outlined),
        _buildDisplayField("Adresse", _adresse.text, Icons.home_outlined),
        _buildDisplayField("Numéro de téléphone", _numeroTel.text,
            Icons.phone_android_outlined),
        _buildDisplayField("Statut marital", _selectedMaritalStatus.toString(),
            Icons.favorite_outline),
        _buildDisplayField("Nombre d'enfants",
            _selectedNumberOfChildren.toString(), Icons.child_care_outlined),
        _buildDisplayField("Revenu mensuel", _selectedMonthlyIncome.toString(),
            Icons.monetization_on_outlined),
        _buildDisplayField("Statut professionnel",
            _selectedJobStatus.toString(), Icons.work_outline),
        _buildDisplayField("Date d'emménagement", _moveInDate.text.toString(),
            Icons.event_available_outlined),
        _buildDisplayField("Aide au logement", _selectedHousingAid.toString(),
            Icons.house_siding_outlined),
        _buildDisplayField("Période de préavis",
            _selectedNoticePeriod.toString(), Icons.timer_outlined),
      ],
    );
  }

  Widget _buildDoubleDisplayField(String label1, String value1, IconData icon1,
      String label2, String value2, IconData icon2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3), // Changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon1,
                      color: Color.fromARGB(255, 255, 112, 137), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label1,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        SizedBox(height: 5),
                        Text(value1,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label2,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        SizedBox(height: 5),
                        Text(value2,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600)),
                      ],
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

  Widget _buildDisplayField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color.fromARGB(255, 255, 112, 137)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateFormat('dd/MM/yyyy')
        .parse(controller.text.isNotEmpty ? controller.text : '01/01/2000');

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      // Check if a date was selected
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
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
