import 'package:flutter/material.dart';
import 'package:madidou/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Confirmer la déconnexion",
    content: "Êtes-vous sûr de vouloir vous déconnecter ?",
    optionBuilder: () => {
      'Annuler': false,
      'Déconnecter': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
