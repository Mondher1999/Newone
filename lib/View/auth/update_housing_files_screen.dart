import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:madidou/bloc/housingFile/housingFile_bloc.dart';
import 'package:madidou/bloc/housingFile/housingFile_event.dart';
import 'package:madidou/bloc/housingFile/housingFile_state.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/data/model/housingFile.dart';
import 'package:madidou/services/auth/auth_service.dart';

class UpdateHousingFilesScreen extends StatefulWidget {
  const UpdateHousingFilesScreen({Key? key}) : super(key: key);

  @override
  State<UpdateHousingFilesScreen> createState() =>
      _UpdateHousingFilesScreenState();
}

class _UpdateHousingFilesScreenState extends State<UpdateHousingFilesScreen> {
  final Map<String, TextEditingController> _controllers = {
    "Carte d'identité": TextEditingController(),
    'Dernier bulletin salaire': TextEditingController(),
    'Impots': TextEditingController(),
    'Dernier facture': TextEditingController(),
    'Dernier quittance': TextEditingController(),
    "Relevé d'identité bancaire": TextEditingController(),
    'Dernier état des lieux': TextEditingController(),
  };

  late Map<String, bool> _isUploadedMap = {};

  late HousingFileBloc _housingFileBloc;

  @override
  void initState() {
    super.initState();
    final user = AuthService.firebase().currentUser?.id;

    if (user != null) {
      _housingFileBloc = BlocProvider.of<HousingFileBloc>(context);
      _housingFileBloc.add(FetchHousingFile(user));
    } else {
      // Handle case where user is not authenticated
      print('User not authenticated.');
    }

    _initializeIsUploadedMap();
  }

  void _initializeIsUploadedMap() {
    setState(() {
      _isUploadedMap = {
        "Carte d'identité": false,
        'Dernier bulletin salaire': false,
        'Impots': false,
        'Dernier facture': false,
        'Dernier quittance': false,
        "Relevé d'identité bancaire": false,
        'Dernier état des lieux': false,
      };
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mettre à Jour les Fichiers de Logement",
          style: TextStyle(
              color: Colors.black, // Couleur du texte en blanc
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w500,
              fontSize: 13), // Adjust text size here
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      body: BlocListener<HousingFileBloc, HousingFileState>(
        listener: (context, state) {
          if (state is HousingFileCreating || state is HousingFileUpdating) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        state is HousingFileCreating
                            ? "S'il vous plaît attendez jusqu'à l'ajout de votre fichier"
                            : "Mise à jour en cours, veuillez patienter...",
                        style: TextStyle(
                            color: Colors.white, // Text color
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                duration: Duration(seconds: 2), // Adjust based on your needs
                backgroundColor: Color.fromARGB(255, 255, 112,
                    137), // Choose a color that fits your app theme
              ),
            );
          } else if (state is HousingFileCreateSuccess ||
              state is HousingFileUpdateSuccess) {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Ensure to remove the loading snackbar
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Votre document est ajouté avec succès!'),
              backgroundColor: Color.fromARGB(255, 255, 112, 137),
            ));
            _housingFileBloc
                .add(FetchHousingFile(AuthService.firebase().currentUser!.id));
          } else if (state is HousingFileError) {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Ensure to remove loading snackbar
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')));
          }
          if (state is HousingFileLoaded) {
            _updateControllers(state.housingFile);
          }
        },
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 20.0, bottom: 7, right: 7, left: 7),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: _controllers.keys
                  .map((field) => _buildFileUploadField(field))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _updateControllers(HousingFile housingFile) {
    setState(() {
      _isUploadedMap = {
        "Carte d'identité":
            housingFile.cin != null && housingFile.cin!.isNotEmpty,
        'Dernier bulletin salaire': housingFile.bulletinSalaire != null &&
            housingFile.bulletinSalaire!.isNotEmpty,
        'Impots': housingFile.impots != null && housingFile.impots!.isNotEmpty,
        'Dernier facture':
            housingFile.facture != null && housingFile.facture!.isNotEmpty,
        'Dernier quittance':
            housingFile.quittance != null && housingFile.quittance!.isNotEmpty,
        "Relevé d'identité bancaire": housingFile.identiteBancaire != null &&
            housingFile.identiteBancaire!.isNotEmpty,
        'Dernier état des lieux':
            housingFile.etatLieu != null && housingFile.etatLieu!.isNotEmpty,
      };
    });

    print("_isUploadedMap: $_isUploadedMap");
  }

  Widget _buildFileUploadField(String field) {
    bool isUploaded = _isUploadedMap[field] == true;
    IconData iconData = Icons.insert_drive_file; // Default icon

    // Logic to choose the icon based on the file name
    if (field.contains("Carte d'identité")) {
      iconData = Icons.person;
    } else if (field.contains('Dernier bulletin salaire')) {
      iconData = Icons.attach_money;
    } else if (field.contains('Impots')) {
      iconData = Icons.assignment;
    } else if (field.contains('Dernier facture')) {
      iconData = Icons.receipt;
    } else if (field.contains('Dernier quittance')) {
      iconData = Icons.receipt_long;
    } else if (field.contains("Relevé d'identité bancaire")) {
      iconData = Icons.credit_card;
    } else if (field.contains('Dernier état des lieux')) {
      iconData = Icons.home;
    }

    return InkWell(
      onTap: () {
        if (!isUploaded) {
          _pickAndUpdateFile(field);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white, // Set container background to white
          borderRadius: BorderRadius.circular(8), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(iconData), // Icon determined by the logic above
          title: Text(
            field.replaceAll('_', ' ').toString(),
            style: TextStyle(
                color: Colors.black, // Text color
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          subtitle:
              Text(isUploaded ? 'Fichier Ajouté' : 'en attente de votre ajout'),
          trailing: isUploaded
              ? Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.file_upload),
        ),
      ),
    );
  }

  void _pickAndUpdateFile(String field) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(
          result.files.single.path!); // Getting the actual file from the result

      // Mapping UI field names to actual backend field keys
      String backendFieldKey = fieldMap(field);

      // Triggering BLoC event to upload the file
      _housingFileBloc.add(UpdateHousingFile(
          userId: AuthService.firebase()
              .currentUser!
              .id, // Ensure user is logged in
          updateData: {backendFieldKey: file}));
      final String? userId = AuthService.firebase().currentUser?.id;
      if (userId != null) {
        BlocProvider.of<UserBloc>(context, listen: false)
            .add(FetchUser(userId));
      }
      // Assuming a successful upload, update UI state accordingly
    }
  }

  String fieldMap(String field) {
    switch (field) {
      case "Carte d'identité":
        return 'cin';
      case "Dernier bulletin salaire":
        return 'd_bulletin_salaire';
      case "Impots":
        return 'impots';
      case "Dernier facture":
        return 'd_facture';
      case "Dernier quittance":
        return 'd_quittance';
      case "Relevé d'identité bancaire":
        return 're_identite_bancaire';
      case "Dernier état des lieux":
        return 'd_etat_lieu';
      default:
        return '';
    }
  }

  void _uploadAllFiles() {
    // Logic for uploading all files
  }
}
