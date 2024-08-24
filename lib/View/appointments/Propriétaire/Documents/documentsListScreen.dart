// documents_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/appointments/Propri%C3%A9taire/Documents/documentviewSreen.dart';
import 'package:madidou/bloc/housingFile/housingFile_bloc.dart';
import 'package:madidou/bloc/housingFile/housingFile_event.dart';
import 'package:madidou/bloc/housingFile/housingFile_state.dart';

class DocumentsListScreen extends StatelessWidget {
  final String userId;

  DocumentsListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HousingFileBloc bloc = BlocProvider.of<HousingFileBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document de condidat',
          style: TextStyle(
              color: Colors.black, // Couleur du texte en blanc
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
              fontSize: 17),
        ),
        // Stylish color for AppBar
        elevation: 0, // Flat design
      ),
      body: BlocListener<HousingFileBloc, HousingFileState>(
        listener: (context, state) {
          if (state is HousingFileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is HousingFileSpecificLoaded) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DocumentViewScreen(url: state.fileUrl),
            ));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: <Widget>[
              _buildDocumentTile(
                  bloc, "Carte d'identité", Icons.credit_card, "cin"),
              _buildDocumentTile(bloc, "Dernier bulletin salaire",
                  Icons.attach_money, "d_bulletin_salaire"),
              _buildDocumentTile(
                  bloc, "Dernier état des lieux", Icons.home, "d_etat_lieu"),
              _buildDocumentTile(
                  bloc, "Dernier facture", Icons.receipt, "d_facture"),
              _buildDocumentTile(
                  bloc, "Dernier quittance", Icons.description, "d_quittance"),
              _buildDocumentTile(
                  bloc, "Impots", Icons.account_balance, "impots"),
              _buildDocumentTile(bloc, "Relevé d'identité bancaire",
                  Icons.account_balance_wallet, "re_identite_bancaire"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTile(
      HousingFileBloc bloc, String title, IconData icon, String fileId) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => bloc.add(FetchSpecificFile(
            userId, fileId)), // Use exact fileId for each document
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: Color(0xFF5e5f99)),
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 112, 137),
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
