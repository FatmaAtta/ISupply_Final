import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //the ui of the notification
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}


class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    await initLocalNotifications();
    final fcmToken = await _firebaseMessaging.getToken();
    print('token: $fcmToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage); //this function needs to be top level functions (not inside a class or another function or lambda function)
    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message);
    });
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings);
  }
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}
