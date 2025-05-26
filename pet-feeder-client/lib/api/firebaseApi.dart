// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Title: ${message.notification?.title}');
//   print("Body: ${message.notification?.body}");
//   print("Payload: ${message.data}");
// }

// class Firebaseapi {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fCMToken = await _firebaseMessaging.getToken();
//     print("Token: $fCMToken");
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   }
// }

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/services/firebaseDatabaseService.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Background Notification - Title: ${message.notification?.title}');
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseAPI {
  final FirebasedatabaseService _databaseService = FirebasedatabaseService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _saveToken(token) async {
    Map<String, dynamic> data = {'token': token};
    _databaseService.updateData("computer", data);
  }

  Future<void> initNotifications() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission();

    // Get FCM token
    final fCMToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fCMToken");
    _saveToken(fCMToken);

    // Handle background notifications
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);
    await _localNotificationsPlugin.initialize(initSettings);

    // Listen for messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Notification - Title: ${message.notification?.title}');
      print("Body: ${message.notification?.body}");
      print("Payload: ${message.data}");
      _showLocalNotification(message);
    });

    // Handle notification when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from background notification");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Payload: ${message.data}");
    });
  }

  // Function to display local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      notificationDetails,
    );
  }
}
