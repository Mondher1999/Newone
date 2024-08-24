import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/LoadingScreen.dart';

import 'package:madidou/View/auth/forget_password_view.dart';
import 'package:madidou/View/auth/login_view.dart';
import 'package:madidou/View/auth/register_view.dart';
import 'package:madidou/View/property/Locataire/Property_Read/properties_locataire_screen.dart';

import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_propri%C3%A9taire_screen.dart';
import 'package:madidou/bloc/appointment/appointment_bloc.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_event.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/disponibility/disponibility_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/housingFile/housingFile_bloc.dart';
import 'package:madidou/bloc/message/message_bloc.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/user/user_bloc.dart';

import 'package:madidou/data/repository/appointment_repository.dart';
import 'package:madidou/data/repository/disponibility_repository.dart';
import 'package:madidou/data/repository/favorite_repository.dart';
import 'package:madidou/data/repository/housingFile_repository.dart';
import 'package:madidou/data/repository/message_repository.dart';
import 'package:madidou/data/repository/property_repository.dart';
import 'package:madidou/data/repository/user_repository.dart';
import 'package:madidou/firebase_options.dart';
import 'package:madidou/services/HousingFile/housingFile_api_service.dart';
import 'package:madidou/services/appointment/appointmentapiservice.dart';
import 'package:madidou/services/auth/auth_service.dart';

import 'package:madidou/services/auth/firebase_auth_provider.dart';
import 'package:madidou/services/disponibility/disponibilityapiservice.dart';
import 'package:madidou/services/favorite/favorite_api_service.dart';
import 'package:madidou/services/message/message_api_service.dart';
import 'package:madidou/services/property/property_api_service.dart';
import 'package:madidou/services/user/user_api_service.dart';
import 'package:madidou/services/notification/NotificationService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Log the error or handle it appropriately
    print("Firebase initialization failed: $e");
  }

  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                  provider: FirebaseAuthProvider(),
                  userRepository: UserRepository(apiService: ApiUserService()),
                ),
              ),
              BlocProvider<PropertyBloc>(
                create: (context) => PropertyBloc(
                  propertyRepository:
                      PropertyRepository(apiService: ApiPropertyService()),
                ),
              ),
              BlocProvider<MessageBloc>(
                create: (context) => MessageBloc(
                  repository:
                      MessageRepository(apiService: MessageApiService()),
                ),
              ),
              BlocProvider<FavoriteBloc>(
                create: (context) => FavoriteBloc(
                  favoriteRepository:
                      FavoriteRepository(apiService: ApiFavoriteService()),
                ),
              ),
              BlocProvider<UserBloc>(
                create: (context) => UserBloc(
                  userRepository: UserRepository(apiService: ApiUserService()),
                ),
              ),
              BlocProvider<HousingFileBloc>(
                create: (context) => HousingFileBloc(
                  housingFileRepository: HousingFileRepository(
                      apiService: HousingFileApiService()),
                ),
              ),
              BlocProvider<DisponibilityBloc>(
                create: (context) => DisponibilityBloc(
                  repository: DisponibilityRepository(
                      apiService: DisponibilityApiService()),
                ),
              ),
              BlocProvider<AppointmentBloc>(
                create: (context) => AppointmentBloc(
                  repository: AppointmentRepository(
                      apiService: AppointmentApiService()),
                ),
              ),
            ],
            child: Builder(
              builder: (context) {
                NotificationService notificationService = NotificationService();
                notificationService.initNotification(context);
                return MyApp();
              },
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madidou',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: const Color(0xFF5e5f99),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide.none,
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFFFBFBFB),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF5e5f99)),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  bool _isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    _startAuthCheckTimer();
  }

  void _startAuthCheckTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_isTimerRunning) {
        context.read<AuthBloc>().add(const AuthEventInitialize());
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateProprietaire ||
            state is AuthStateLocataire ||
            state is AuthStateForgotPassword ||
            state is AuthStateNeedsverification ||
            state is AuthStateLoggedOut ||
            state is AuthStateShouldLogIn ||
            state is AuthStateRegistering) {
          _isTimerRunning = false; // Stop the timer
        }
      },
      builder: (context, state) {
        if (state is AuthStateProprietaire) {
          return PropertiesProprietaireScreen();
        } else if (state is AuthStateLocataire) {
          return PropertiesLocataireScreen();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordScreen();
        } else if (state is AuthStateNeedsverification) {
          return const LoginScreen();
        } else if (state is AuthStateLoggedOut) {
          return PropertiesLocataireScreen();
        } else if (state is AuthStateShouldLogIn) {
          return const LoginScreen();
        } else if (state is AuthStateRegistering) {
          return const RegisterScreenTest();
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
