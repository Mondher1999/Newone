import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:madidou/bloc/user/user_bloc.dart';
import 'package:madidou/bloc/user/user_event.dart';
import 'package:madidou/services/auth/auth_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initLocalNotifications();
  }

  void _initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> initNotification(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        _setupTokenListeners(context);
        _setupForegroundNotificationListener();
        break;
      case AuthorizationStatus.denied:
        print('User has denied permission');
        break;
      case AuthorizationStatus.notDetermined:
        print('Permission has not been requested/determined');
        break;
    }
  }

  void _setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  void _setupTokenListeners(BuildContext context) {
    _firebaseMessaging.getToken().then((token) {
      print("Initial FCM Token: $token");
      _updateToken(context, token);
    }).catchError((error) {
      print('Error getting initial token: $error');
    });

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _updateToken(context, token);
    });
  }

  void _updateToken(BuildContext context, String? token) {
    final String? userId = AuthService.firebase().currentUser?.id;
    if (token != null && userId != null) {
      BlocProvider.of<UserBloc>(context, listen: false)
          .add(UpdateFCMToken(userId, token));
      print('Token updated: $token');
    } else {
      print('Token or User ID is null. Token not updated.');
    }
  }
}
