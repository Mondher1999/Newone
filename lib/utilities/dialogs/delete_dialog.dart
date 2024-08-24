import 'package:flutter/material.dart';
import 'package:madidou/utilities/dialogs/generic_dialog.dart';

Future<bool> ShouldDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Detete",
    content: "Are you sure you want to Delete this item ?",
    optionBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
