import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isupply_final/firestore_api.dart';
import 'package:isupply_final/order_list.dart';

Map<int, String> status ={
  0: "Pending",
  1: "Confirmed",
  2: "Shipping",
  3: "Delivered",
};
Map<int, String> orderStatuses = {
  0: "Is Pending...",
  1: "Has Been Confirmed",
  2: "Is On Its Way",
  3: "Has Been Delivered",
};
Map<int, String> progressLine = {
  0: '🟢 Order Placed -> ⚪ Preparing -> ⚪ Out for Delivery -> ⚪ Delivered',
  1: '✅ Order Placed -> 🟢 Preparing -> ⚪ Out for Delivery -> ⚪ Delivered',
  2: '✅ Order Placed -> ✅ Preparing -> 🟢 Out for Delivery -> ⚪ Delivered',
  3: '✅ Order Placed -> ✅ Preparing -> ✅ Out for Delivery -> ✅ Delivered',
};

Future<BigTextStyleInformation> notificationBigText(RemoteMessage message) async {
  int before = int.parse(message.data['before']);
  int after = int.parse(message.data['after']);
  String orderID = message.data['orderID'];
  String sellerID = message.data['sellerID'];
  String sellerName = await FirestoreData().getSellerName(sellerID);
  
  BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
    '$orderID status changed from ${status[before]} to ${status[after]}\n ${progressLine[after]}',
    contentTitle: '$orderID ${orderStatuses[after]}',
    summaryText: 'Order Status Update With $sellerName',
  );

  return bigTextStyle;
}

Future<BigPictureStyleInformation> notificationBigPic(RemoteMessage message) async {
  int before = int.parse(message.data['before']);
  int after = int.parse(message.data['after']);
  String orderID = message.data['orderID'];
  String sellerID = message.data['sellerID'];
  String sellerName = await FirestoreData().getSellerName(sellerID);

  BigPictureStyleInformation bigPicStyle = BigPictureStyleInformation(

  );


  return bigPicStyle;
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //the ui of the notification
  final title = message.notification?.title ?? message.data['title'];
  final body = message.notification?.body ?? message.data['body'];
  print('Title: $title');
  print('Body: $body');
  // print('Payload: ${message.data}');
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
      final title = message.data['title'];
      final body = message.data['body'];
      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      OrderListController.navigateToBuyer();
    });
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings);

    const channel = AndroidNotificationChannel(
      'channel_id',
      'High Importance Notifications',
      description: 'This channel is used for order updates',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  }
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.data['title'];
    final body = message.data['body'];
    // final state = int.parse(message.data['after']);
    final style = await notificationBigText(message);
    final androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'i',
      styleInformation: style,
    );
      // largeIcon: DrawableResourceAndroidBitmap('i'),

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0, //notification id
      title,
      body,
      notificationDetails,
    );
  }
}