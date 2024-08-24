import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madidou/View/appointments/Propri%C3%A9taire/appointmentsScreen.dart';
import 'package:madidou/View/appointments/appointments_list.dart';
import 'package:madidou/View/appointments/calendarDisponibility.dart';
import 'package:madidou/View/appointments/calenderappointmentsupdate.dart';
import 'package:madidou/View/auth/Profile/profile_screen.dart';
import 'package:madidou/View/messages/message_list_view.dart';
import 'package:madidou/View/property/Locataire/Favoris/property_favoris.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/properties_update.dart';
import 'package:madidou/View/property/Locataire/Property_Read/propertylist_locataire.dart';
import 'package:madidou/View/property/Propri%C3%A9taire/property_Read/propertylist_propri%C3%A9taire.dart';
import 'package:madidou/View/sideMenu/animated_bar.dart';
import 'package:madidou/View/sideMenu/side_menu.dart';
import 'package:madidou/bloc/appointment/appointment_bloc.dart';
import 'package:madidou/bloc/appointment/appointment_event.dart';
import 'package:madidou/bloc/auth/auth_bloc.dart';
import 'package:madidou/bloc/auth/auth_state.dart';
import 'package:madidou/bloc/disponibility/disponibility_bloc.dart';
import 'package:madidou/bloc/disponibility/disponibility_event.dart';
import 'package:madidou/bloc/disponibility/disponibility_state.dart';
import 'package:madidou/bloc/favorite/favorite_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/bloc/property/property_bloc.dart';
import 'package:madidou/bloc/property/property_event.dart';
import 'package:madidou/bloc/property/property_state.dart.dart';
import 'package:madidou/data/enums/amenities.dart';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/auth/auth_service.dart';
import 'package:madidou/services/auth/auth_user.dart';
import 'package:madidou/utilities/river/rive_asset.dart';

import 'package:madidou/utilities/river/rive_utils.dart';
import 'package:rive/rive.dart';

class PropertiesProprietaireScreen extends StatefulWidget {
  final int initialIndex;

  PropertiesProprietaireScreen({
    this.initialIndex = 0,
  });

  @override
  _PropertiesProprietaireScreenState createState() =>
      _PropertiesProprietaireScreenState();
}

class _PropertiesProprietaireScreenState
    extends State<PropertiesProprietaireScreen>
    with SingleTickerProviderStateMixin {
  List<Property> _localProperties = []; // Added for local list management
  List<Property> _FavoriteProperties = []; // Added for local list management
  final List<Amenities> selectedAmenities = [];
  List<Appointment> _localappointment = [];

  int _selectedIndexprop = 0;
  int _selectedIndexloc = 0;
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scalAnimation;
  RiveAsset selectedBottomNav = bottomNavsPropretaire.first;
  late final List<XFile> images = [];

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Action Obligatoire'),
          content: Text(
              "S'il vous plaît ajouter des dates sur votre calendrier de disponibilité sinon supprimer l'annonce."),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Correctly pops the dialog
              },
            ),
            TextButton(
              child: Text('Mettre à jour les dates'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog before navigating
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarDisponibility(),
                    ));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentScreen(int selectedIndex, AuthState state) {
    // Check the type of state and adjust the widget accordingly
    if (state is AuthStateProprietaire) {
      final String? userId = AuthService.firebase().currentUser?.id;

      BlocProvider.of<AppointmentBloc>(context)
          .add(GetAppointmentsbyproprietaireEvent(ownerId: userId!));

      DisponibilityBloc bloc = BlocProvider.of<DisponibilityBloc>(context);
      bloc.add(CheckUserStatusEvent(userId));

      return BlocListener<DisponibilityBloc, DisponibilityState>(
        listener: (context, disponibilityState) {
          if (disponibilityState is DisponibilityStatusNotChecked) {
            _showStatusDialog(context);
          } else if (disponibilityState is DisponibilityStatusChecked) {}
        },
        child: Builder(
          builder: (context) {
            switch (_selectedIndexprop) {
              case 0:
                return PropertyListProprietaireWidget(
                  properties: _localProperties,
                  onPropertyDelete: _showDeleteConfirmationDialog,
                  onPropertyUpdate: _navigateToUpdateScreen,
                  images: images,
                  selectedAmenities: [],
                );
              case 1:
                return AppointmentsScreen(
                  appointment: _localappointment,
                );
              case 2:
                return const MessagesListView();
              case 3:
                return ProfileScreen();
              default:
                return Placeholder(); // Fallback widget
            }
          },
        ),
      );
    } else if (state is AuthStateLocataire) {
      final String? userId = AuthService.firebase().currentUser?.id;
      BlocProvider.of<AppointmentBloc>(context)
          .add(GetAppointmentsbylocataireEvent(userId: userId!));
      switch (_selectedIndexloc) {
        case 0:
          return PropertyListLocataireWidget(
            properties: _localProperties,
            onPropertyDelete: _showDeleteConfirmationDialog,
            onPropertyUpdate: _navigateToUpdateScreen,
          ); // Assuming this widget for demonstration
        case 1:
          return BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state is FavoritesLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is FavoritesLoaded) {
                // Corrected to use `state.properties`
                return PropertyFavorisListWidget(
                  properties: state.properties,
                  onPropertyDelete: _showDeleteConfirmationDialog,
                  onPropertyUpdate: _navigateToUpdateScreen,
                );
              } else {
                return Center(child: Text('Failed to load favorites'));
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
          return ProfileScreen(); // Assuming shared functionality
        default:
          return Placeholder(); // Fallback widget for undefined indexes
      }
    }

    // Handle any other state or fallback condition
    return Placeholder();
  }

  late SMIBool isSidebarClosed;
  bool isSideMenuClosed = true;

  // Define your views as widgets or methods returning widgets
  void _onItemTapped(int index, AuthState state) {
    setState(() {
      if (state is AuthStateProprietaire) {
        _selectedIndexprop = index; // Update the index for proprietors
      } else if (state is AuthStateLocataire) {
        _selectedIndexloc = index; // Update the index for renters
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Trigger the FetchPs event as soon as the widget is initialized
    final String? userId = AuthService.firebase().currentUser?.id;

    if (userId != null) {
      context.read<PropertyBloc>().add(FetchPropertiesByUserId(userId!));
      context.read<FavoriteBloc>().add(FetchFavorites(userId));
    }

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

  void _selectScreen(int index, AuthState state) {
    setState(() {
      if (state is AuthStateProprietaire) {
        _selectedIndexprop = index; // Update index for proprietors
      } else if (state is AuthStateLocataire) {
        _selectedIndexloc = index; // Update index for renters
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFededf6),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateProprietaire) {
            return Stack(
              // Adding return here to ensure the Stack is returned when the condition is true
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
                          ..rotateY(animation.value -
                              30 * animation.value * pi / 180),
                        child: Transform.translate(
                          offset: Offset(animation.value * 265, 0),
                          child: Transform.scale(
                            scale: scalAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 70),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                                child: _buildCurrentScreen(
                                    _selectedIndexprop, state),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                                color: Color.fromARGB(255, 32, 3, 110)
                                    .withOpacity(0.8),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ...List.generate(
                                    bottomNavsPropretaire.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        bottomNavsPropretaire[index]
                                            .input!
                                            .change(true);
                                        if (bottomNavsPropretaire[index] !=
                                            selectedBottomNav) {
                                          setState(() {
                                            selectedBottomNav =
                                                bottomNavsPropretaire[index];
                                            _selectScreen(index,
                                                state); // Update the view
                                          });
                                        }
                                        Future.delayed(
                                            const Duration(seconds: 1), () {
                                          bottomNavsPropretaire[index]
                                              .input!
                                              .change(false);
                                        });
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedBar(
                                              isActive: bottomNavsPropretaire[
                                                      index] ==
                                                  selectedBottomNav),
                                          SizedBox(
                                            height: 36,
                                            width: 36,
                                            child: Opacity(
                                              opacity: bottomNavsPropretaire[
                                                          index] ==
                                                      selectedBottomNav
                                                  ? 1
                                                  : 0.5,
                                              child: RiveAnimation.asset(
                                                bottomNavsPropretaire.first.src,
                                                artboard:
                                                    bottomNavsPropretaire[index]
                                                        .artboard,
                                                onInit: (artboard) {
                                                  StateMachineController
                                                      controller =
                                                      RiveUtils.getRiveController(
                                                          artboard,
                                                          stateMachineName:
                                                              bottomNavsPropretaire[
                                                                      index]
                                                                  .stateMachineName);
                                                  bottomNavsPropretaire[index]
                                                      .input = controller
                                                          .findSMI("active")
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
            );
          } else {
            return Stack(
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
                          ..rotateY(animation.value -
                              30 * animation.value * pi / 180),
                        child: Transform.translate(
                          offset: Offset(animation.value * 265, 0),
                          child: Transform.scale(
                            scale: scalAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 70),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                                child: _buildCurrentScreen(
                                    _selectedIndexloc, state),
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
                                color: Color.fromARGB(255, 32, 3, 110)
                                    .withOpacity(0.8),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            _selectScreen(index,
                                                state); // Update the view
                                          });
                                        }
                                        Future.delayed(
                                            const Duration(seconds: 1), () {
                                          bottomNavsLocataire[index]
                                              .input!
                                              .change(false);
                                        });
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedBar(
                                              isActive:
                                                  bottomNavsLocataire[index] ==
                                                      selectedBottomNav),
                                          SizedBox(
                                            height: 36,
                                            width: 36,
                                            child: Opacity(
                                              opacity:
                                                  bottomNavsLocataire[index] ==
                                                          selectedBottomNav
                                                      ? 1
                                                      : 0.5,
                                              child: RiveAnimation.asset(
                                                bottomNavsLocataire.first.src,
                                                artboard:
                                                    bottomNavsLocataire[index]
                                                        .artboard,
                                                onInit: (artboard) {
                                                  StateMachineController
                                                      controller =
                                                      RiveUtils.getRiveController(
                                                          artboard,
                                                          stateMachineName:
                                                              bottomNavsLocataire[
                                                                      index]
                                                                  .stateMachineName);

                                                  bottomNavsLocataire[index]
                                                      .input = controller
                                                          .findSMI("active")
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
            ); // Ensure returning a Widget in the 'else' branch as well
          }
        },
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
                // Dispatch DeletePost event
                final firebaseUser = FirebaseAuth.instance.currentUser;
                final AuthUser authUser = AuthUser.fromFirebase(firebaseUser!);
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
                    builder: (context) => PropertiesProprietaireScreen()),
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
