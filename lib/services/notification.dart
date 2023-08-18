import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class CustomNotification {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  // Future showNotificationWithoutSound(Position position) async {
  //   var androidPlatformChannelSpecifics =  AndroidNotificationDetails(
  //       '1', 'location-bg',
  //       playSound: false, importance: Importance.max, priority: Priority.high);
  //   var iOSPlatformChannelSpecifics =
  //   IOSNotificationDetails(presentSound: false);
  //   var platformChannelSpecifics = NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Location fetched',
  //     position.toString(),
  //     platformChannelSpecifics,
  //     payload: '',
  //   );
  // }

  Future showNotificationText(String text) async {
     AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
          'back_location_not',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high);
     NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
        // (await flutterLocalNotificationsPlugin!.getActiveNotifications())
        //   .first
        //   ;
   await flutterLocalNotificationsPlugin!
        .show(0, 'local_not', text, notificationDetails);
  }

  CustomNotification() {
    initialize();
  }
  initialize() async {
     flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }
}
