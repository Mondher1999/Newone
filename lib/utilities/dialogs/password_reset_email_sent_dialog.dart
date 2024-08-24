import 'package:flutter/widgets.dart';
import 'package:madidou/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Mise à jour du mot de passe',
    content:
        "Lien de réinitialisation envoyé. Merci de consulter votre courriel, de mettre à jour votre mot de passe, et de vous reconnecter, s'il vous plaît.",
    optionBuilder: () => {
      'OK': null,
    },
  );
}
