import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/utilities/dialogs/error_dialog.dart';
import 'package:madidou/utilities/dialogs/password_reset_email_sent_dialog.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  List<String> errors = [];
  String? email;

  @override
  @override
  Widget build(BuildContext context) {
    // Wrap BlocListener with BlocProvider if AuthBloc is not provided globally
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              "Nous n'avons pas pu traiter votre demande. Veuillez vous assurer que vous êtes un utilisateur enregistré.",
            );
          }
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Added to handle overflow when keyboard is visible
          child: Column(
            children: [
              TextFormField(
                controller: _controller, // Make sure to use the controller
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,

                onSaved: (newValue) => email = newValue,
                onChanged: (value) {
                  // Your onChanged logic here...
                },

                decoration: const InputDecoration(
                  hintText: "Adresse e-mail",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Montserrat",
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon:
                      CustomSurffixIcon(svgIcon: "assets/icons/email_box.svg"),
                ),
              ),
              const SizedBox(height: 150),
              FormError(errors: errors),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Colors.white), // Change text color here
                  minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, 48)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                    // Form validation success logic here
                  }
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Montserrat",
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
