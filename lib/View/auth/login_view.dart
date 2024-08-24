import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/components/socal_card.dart';
import 'package:madidou/services/auth/auth_exceptions.dart';
import 'package:madidou/utilities/dialogs/error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String getErrorMessageFromException(Exception exception) {
    if (exception is EmailorpasswordincorrectAuthException) {
      _password.clear();
      setState(() {});
      return 'Impossible de trouver un utilisateur avec les identifiants saisis!';
    } else if (exception is TooManyRequestsAuthException) {
      _password.clear();
      setState(() {});
      return "Accès suspendu pour sécurité. Réessayez dans 2 minutes, s'il vous plaît.";
    } else if (exception is UsernotVerified) {
      _password.clear();
      setState(() {});
      return "Un lien d'activation vous a été adressé par courriel. Veuillez le consulter afin d'activer votre compte, encore en attente d'activation, pour procéder à la connexion.";
    } else {
      _password.clear();
      setState(() {});
      return "Un lien d'activation vous a été adressé par courriel. Veuillez le consulter afin d'activer votre compte, encore en attente d'activation, pour procéder à la connexion.";
    }
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    context.read<AuthBloc>().add(
          AuthEventLogIn(
            email,
            password,
          ),
        );
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

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedinFailure && state.exception != null) {
          // Here, implement a function to parse the exception and get a user-friendly message
          final String errorMessage =
              getErrorMessageFromException(state.exception);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Login Error"),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, right: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.11),
                  Text(
                    'Bienvenue de retour!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: "Montserrat",
                        ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      'Veuillez vous connecter pour accéder et commencer.',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.black,
                            fontFamily: "Montserrat",
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adresse e-mail',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.black,
                                    fontFamily: "Montserrat",
                                  ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Saisissez votre adresse e-mail.',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color:
                                      const Color.fromARGB(255, 110, 110, 110),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Montserrat",
                                ),
                          ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Mot de passe',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.black,
                                    fontFamily: "Montserrat",
                                  ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          obscureText: _obscureText,
                          controller: _password,
                          decoration: InputDecoration(
                            hintText: 'Saisissez votre Mot de passe',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color:
                                      const Color.fromARGB(255, 110, 110, 110),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Montserrat",
                                ),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: _passwordValidator,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                    const AuthEventForgotPassword(),
                                  );
                              // Implement forgot password
                            },
                            child: const Text(
                              'Mot de passe Oublié ? ',
                              style: TextStyle(
                                color: Color(0xFF5e5f99),
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                        Colors.white,
                      ), // Change text color here
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 48)),
                    ),
                    child: Text(
                      'Se Connecter',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: "Montserrat",
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 90),
                  Container(
                    width:
                        300, // Set the width of the container to determine the length of the divider
                    child: const Divider(),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocalCard(
                        icon: "assets/icons/google-icon.svg",
                        press: () {},
                      ),
                      SocalCard(
                        icon: "assets/icons/facebook-2.svg",
                        press: () {},
                      ),
                      SocalCard(
                        icon: "assets/icons/twitter.svg",
                        press: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: "Vous n'avez pas encore de compte ?",
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat",
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '  Inscrivez-vous',
                          style: const TextStyle(
                            color: Color(0xFF5e5f99),
                            fontFamily: "Montserrat",
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.read<AuthBloc>().add(
                                    const AuthEventShouldRegister(),
                                  );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
