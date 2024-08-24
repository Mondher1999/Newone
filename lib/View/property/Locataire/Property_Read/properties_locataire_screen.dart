import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/View/appointments/appointments_list.dart';
import 'package:madidou/View/auth/Profile/profile_screen.dart';
import 'package:madidou/View/messages/message_list_view.dart';
import 'package:madidou/View/property/Locataire/Favoris/property_favoris.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/Property%20_Creation/guide_screen.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_update.dart';
import 'package:madidou/View/property/Locataire/Property_Read/propertylist_locataire.dart';
import 'package:madidou/View/sideMenu/animated_bar.dart';
import 'package:madidou/View/sideMenu/side_menu.dart';
import 'package:madidou/bloc/appointment/appointment_bloc.dart';
import 'package:madidou/bloc/appointment/appointment_event.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:madidou/utilities/river/rive_asset.dart';

import 'package:madidou/utilities/river/rive_utils.dart';
import 'package:rive/rive.dart';

class PropertiesLocataireScreen extends StatefulWidget {
  final int initialIndex;

  PropertiesLocataireScreen({this.initialIndex = 0});

  @override
  _PropertiesLocataireScreenState createState() =>
      _PropertiesLocataireScreenState();
}

class _PropertiesLocataireScreenState extends State<PropertiesLocataireScreen>
    with SingleTickerProviderStateMixin {
  List<Property> _localProperties = []; // Added for local list management
  List<Property> _FavoriteProperties = []; // Added for local list management

  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scalAnimation;
  RiveAsset selectedBottomNav = bottomNavsLocataire.first;
  List<Appointment> _localappointment = [];

  Widget _buildCurrentScreen(int selectedIndex) {
    final String? userId = AuthService.firebase().currentUser?.id;

    if (userId != null) {
      BlocProvider.of<AppointmentBloc>(context)
          .add(GetAppointmentsbylocataireEvent(userId: userId!));
    }

    switch (selectedIndex) {
      case 0:
        return PropertyListLocataireWidget(
          properties: _localProperties,
          onPropertyDelete: _showDeleteConfirmationDialog,
          onPropertyUpdate: _navigateToUpdateScreen,
        );

      case 1:
        return BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state is FavoritesLoaded) {
              // Corrected to use `state.properties`
              return PropertyFavorisListWidget(
                properties: state.properties,
                onPropertyDelete: _showDeleteConfirmationDialog,
                onPropertyUpdate: _navigateToUpdateScreen,
              );
            } else {
              return PropertyFavorisListWidget(
                properties: _localProperties,
                onPropertyDelete: _showDeleteConfirmationDialog,
                onPropertyUpdate: _navigateToUpdateScreen,
              );
            }
          },
        );

      case 2:
        /*   return PropertyListAdminWidget(
          properties: _localProperties,
          onPropertyDelete: _showDeleteConfirmationDialog,
          onPropertyUpdate: _navigateToUpdateScreen, )*/
        return AppointmentsListView(
          appointment: _localappointment,
        );

      case 3:
        return const MessagesListView();

      case 4:
        return ProfileScreen();

      // return CreatePropertyScreen();

      default:
        return Placeholder(); // Fallback widget
    }
  }

  late SMIBool isSidebarClosed;
  bool isSideMenuClosed = true;

  // Define your views as widgets or methods returning widgets
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the index on tap
    });
  }

  @override
  void initState() {
    super.initState();
    // Trigger the FetchPs event as soon as the widget is initialized

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    scalAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    final String? userId = AuthService.firebase().currentUser?.id;

    if (userId != null) {
      context.read<FavoriteBloc>().add(FetchFavorites(userId));
    }

    context.read<PropertyBloc>().add(FetchProperties());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToUpdateScreen(String propertyId) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => UpdatePropertyView(
                  propertyId: propertyId,
                )))
        .then((_) {
      // Optionally refresh the properties list after updating a property
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
      context.read<PropertyBloc>().add(FetchProperties());
      context.read<FavoriteBloc>().add(FetchFavorites(authUser.id));
    });
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFededf6),
      /* appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createProperty);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          )
        ],
      ),*/
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: isSideMenuClosed ? -288 : 0,
            height: MediaQuery.of(context).size.height,
            child: const SideMenu(),
          ),
          BlocListener<PropertyBloc, PropertyState>(
            listener: (context, state) {
              if (state is PropertiesLoaded) {
                setState(() {
                  _localProperties = state.properties;
                });
              }
            },
            child: Stack(
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(
                        animation.value - 30 * animation.value * pi / 180),
                  child: Transform.translate(
                    offset: Offset(animation.value * 265, 0),
                    child: Transform.scale(
                      scale: scalAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          child: _buildCurrentScreen(_selectedIndex),
                        ),
                      ),
                    ),
                  ),
                ),
                /*    AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  left: isSideMenuClosed ? 0 : 210,
                  top: 15,
                  child: MenuBtn(
                    riveOnInit: (artboard) {
                      StateMachineController controller =
                          RiveUtils.getRiveController(artboard,
                              stateMachineName: "State Machine");
                      isSidebarClosed = controller.findSMI("isOpen") as SMIBool;
                      isSidebarClosed.value = true;
                    },
                    press: () {
                      isSidebarClosed.value = !isSidebarClosed.value;
                      if (isSideMenuClosed) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                      setState(() {
                        isSideMenuClosed = isSidebarClosed.value;
                      });
                    },
                  ),
                ), */

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, 100 * animation.value),
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              Color.fromARGB(255, 32, 3, 110).withOpacity(0.8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...List.generate(
                              bottomNavsLocataire.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  bottomNavsLocataire[index]
                                      .input!
                                      .change(true);
                                  if (bottomNavsLocataire[index] !=
                                      selectedBottomNav) {
                                    setState(() {
                                      selectedBottomNav =
                                          bottomNavsLocataire[index];
                                      _selectScreen(index); // Update the view
                                    });
                                  }
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    bottomNavsLocataire[index]
                                        .input!
                                        .change(false);
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedBar(
                                        isActive: bottomNavsLocataire[index] ==
                                            selectedBottomNav),
                                    SizedBox(
                                      height: 36,
                                      width: 36,
                                      child: Opacity(
                                        opacity: bottomNavsLocataire[index] ==
                                                selectedBottomNav
                                            ? 1
                                            : 0.5,
                                        child: RiveAnimation.asset(
                                          bottomNavsLocataire.first.src,
                                          artboard: bottomNavsLocataire[index]
                                              .artboard,
                                          onInit: (artboard) {
                                            StateMachineController controller =
                                                RiveUtils.getRiveController(
                                                    artboard,
                                                    stateMachineName:
                                                        bottomNavsLocataire[
                                                                index]
                                                            .stateMachineName);

                                            bottomNavsLocataire[index].input =
                                                controller.findSMI("active")
                                                    as SMIBool;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Property"),
          content: const Text("Are you sure you want to delete this property?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                final firebaseUser = FirebaseAuth.instance.currentUser;
                final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
                // Dispatch DeletePost event
                BlocProvider.of<PropertyBloc>(context)
                    .add(DeleteProperty(propertyId, authUser.id));

                // Close the delete confirmation dialog
                Navigator.of(context).pop();

                // Show success message
                _showDeleteSuccessDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Property Delted successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PropertiesLocataireScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
