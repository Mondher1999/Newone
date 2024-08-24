import 'package:flutter/widgets.dart';
import 'package:madidou/utilities/dialogs/generic_dialog.dart';

Future<void> showVerificationDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Compte créé avec succès !',
    content:
        "Lien d'activation envoyé. Merci de consulter votre courriel pour confirmer votre compte et vous connecter, s'il vous plaît.",
    optionBuilder: () => {
      'OK': null,
    },
  );
}
