import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isupply_final/firestore_api.dart';
import 'package:isupply_final/order_list.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

Map<int, String> status = {
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

Map<int, String> progressLineImg = {
  0: 'status0',
  1: 'status1',
  2: 'status2',
  3: 'status3',
};

Map<int, String> statusImgs = {
  0: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status0.png?alt=media&token=987ce592-d15e-4cd1-b854-7f463d506cd6",
  1: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status1.png?alt=media&token=b8bd311b-cb6e-4c89-88c6-eee813eb851c",
  2: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status2.png?alt=media&token=cb5d5481-9bcd-4017-bb4a-521cbe895ca7",
  3: "https://firebasestorage.googleapis.com/v0/b/isupply-final.firebasestorage.app/o/status3.png?alt=media&token=8bab38bc-c6e7-42b5-af7e-1348d8459857",
};

// Future<BigPictureStyleInformation> notificationBigPic(RemoteMessage message) async {
//   int before = int.parse(message.data['before']);
//   int after = int.parse(message.data['after']);
//   String orderID = message.data['orderID'];
//   String sellerID = message.data['sellerID'];
//   String sellerName = await FirestoreData().getSellerName(sellerID);
//
//   return BigPictureStyleInformation(
//     DrawableResourceAndroidBitmap(progressLineImg[after] ?? 'status0'),
//     contentTitle: '$orderID ${orderStatuses[after]}',
//     summaryText: 'Order Status Update With $sellerName',
//   );
// }

Future<void> _showCustomStyledNotification(RemoteMessage message) async {
  int after = int.parse(message.data['after']);
  final title = message.notification?.title ?? message.data['title'] ?? 'Order Status Update';
  final body = message.notification?.body ?? message.data['body'] ?? '';

  // final style = await notificationBigPic(message);
  final imageUrl = message.notification?.android?.imageUrl??statusImgs[after];

  final bigPictureStyle = BigPictureStyleInformation(
    FilePathAndroidBitmap(await _downloadAndSaveFile(imageUrl!, after)),
    contentTitle: title,
    summaryText: body,
  );

  final androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    styleInformation: bigPictureStyle,
    importance: Importance.max,
    priority: Priority.high,
    icon: 'i',
  );

  final notificationDetails = NotificationDetails(android: androidDetails);
  await _localNotifications.show(
    0,
    message.data['title'],
    message.data['body'],
    notificationDetails,
  );
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await _showCustomStyledNotification(message);
}

Future<String> _downloadAndSaveFile(String url, int state) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/state$state.png';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  } else {
    throw Exception('Failed to download image for state $state. HTTP ${response.statusCode}');
  }
}

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    await initLocalNotifications();
    final fcmToken = await _firebaseMessaging.getToken();
    print('token: $fcmToken');

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      _showCustomStyledNotification(message);
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
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}































// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:isupply_final/firestore_api.dart';
// import 'package:isupply_final/order_list.dart';
//
// Map<int, String> status ={
//   0: "Pending",
//   1: "Confirmed",
//   2: "Shipping",
//   3: "Delivered",
// };
// Map<int, String> orderStatuses = {
//   0: "Is Pending...",
//   1: "Has Been Confirmed",
//   2: "Is On Its Way",
//   3: "Has Been Delivered",
// };
// Map<int, String> progressLine = {
//   0: '🟢 Order Placed -> ⚪ Preparing -> ⚪ Out for Delivery -> ⚪ Delivered',
//   1: '✅ Order Placed -> 🟢 Preparing -> ⚪ Out for Delivery -> ⚪ Delivered',
//   2: '✅ Order Placed -> ✅ Preparing -> 🟢 Out for Delivery -> ⚪ Delivered',
//   3: '✅ Order Placed -> ✅ Preparing -> ✅ Out for Delivery -> ✅ Delivered',
// };
// Map<int, String> progressLineImg = {
//   0: 'status0',
//   1: 'status1',
//   2: 'status2',
//   3: 'status3',
// };
//
// Future<BigTextStyleInformation> notificationBigText(RemoteMessage message) async {
//   int before = int.parse(message.data['before']);
//   int after = int.parse(message.data['after']);
//   String orderID = message.data['orderID'];
//   String sellerID = message.data['sellerID'];
//   String sellerName = await FirestoreData().getSellerName(sellerID);
//
//   BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
//     '$orderID status changed from ${status[before]} to ${status[after]}\n ${progressLine[after]}',
//     contentTitle: '$orderID ${orderStatuses[after]}',
//     summaryText: 'Order Status Update With $sellerName',
//   );
//
//   return bigTextStyle;
// }
//
// Future<BigPictureStyleInformation> notificationBigPic(RemoteMessage message) async {
//   int before = int.parse(message.data['before']);
//   int after = int.parse(message.data['after']);
//   String orderID = message.data['orderID'];
//   String sellerID = message.data['sellerID'];
//   String sellerName = await FirestoreData().getSellerName(sellerID);
//
//   BigPictureStyleInformation bigPicStyle = BigPictureStyleInformation(
//     DrawableResourceAndroidBitmap(progressLineImg[after] ?? 'status0'),
//     contentTitle: '$orderID ${orderStatuses[after]}',
//     summaryText: 'Order Status Update',
//   );
//   return bigPicStyle;
// }
//
// Future<void> handleBackgroundMessage2(RemoteMessage message) async {
//   //the ui of the notification
//   final title = message.notification?.title ?? message.data['title'];
//   final body = message.notification?.body ?? message.data['body'];
//   print('Title: $title');
//   print('Body: $body');
//   // print('Payload: ${message.data}');
// }
//
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   await _showCustomStyledNotification(message);
// }
//
// Future<void> _showCustomStyledNotification(RemoteMessage message) async {
//   final style = await notificationBigText(message); // or BigPicture
//   final androidDetails = AndroidNotificationDetails(
//     'channel_id',
//     'channel_name',
//     styleInformation: style,
//     importance: Importance.max,
//     priority: Priority.high,
//     icon: 'i',
//   );
//
//   await _localNotifications.show(
//     0,
//     message.data['title'],
//     message.data['body'],
//     NotificationDetails(android: androidDetails),
//   );
// }
//
//
//
//
//
// class FirebaseAPI {
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   final _localNotifications = FlutterLocalNotificationsPlugin();
//
//
//
//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     await initLocalNotifications();
//     final fcmToken = await _firebaseMessaging.getToken();
//     print('token: $fcmToken');
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage); //this function needs to be top level functions (not inside a class or another function or lambda function)
//     FirebaseMessaging.onMessage.listen((message) {
//       final title = message.data['title'];
//       final body = message.data['body'];
//       _showForegroundNotification(message);
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       OrderListController.navigateToBuyer();
//     });
//   }
//
//   Future<void> initLocalNotifications() async {
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: android);
//     await _localNotifications.initialize(settings);
//
//     const channel = AndroidNotificationChannel(
//       'channel_id',
//       'High Importance Notifications',
//       description: 'This channel is used for order updates',
//       importance: Importance.max,
//     );
//
//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
//
//   }
//   Future<void> _showForegroundNotification(RemoteMessage message) async {
//     final title = message.data['title'];
//     final body = message.data['body'];
//     // final state = int.parse(message.data['after']);
//     // final style = await notificationBigText(message);
//     final style = await notificationBigPic(message);
//     final androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: 'i',
//       styleInformation: style,
//     );
//       // largeIcon: DrawableResourceAndroidBitmap('i'),
//
//     final notificationDetails = NotificationDetails(android: androidDetails);
//
//     await _localNotifications.show(
//       0, //notification id
//       title,
//       body,
//       notificationDetails,
//     );
//   }
// }