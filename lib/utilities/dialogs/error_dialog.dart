import 'package:flutter/material.dart';
import 'package:madidou/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: "Erreur d'authentification",
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
