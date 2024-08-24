import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/components/forgot_pass_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static String routeName = "/forgot_password";

  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEventShouldLogIn(),
                );
          },
        ),
      ),
      body: const SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 50),
                Text(
                  "Mot de passe oublié",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Montserrat",
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Entrez votre adresse e-mail pour recevoir un lien de réinitialisation de votre mot de passe.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Montserrat",
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 80),
                ForgotPassForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
