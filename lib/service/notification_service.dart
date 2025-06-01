import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceCustom {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  //background message handler

  @pragma('vm:entry-point')
 static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Handling a background message ${message.messageId}');

    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

 static Future<void> _showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic>? data = message.data;

    String title = notification?.title ?? data['title'] ?? 'No Title';
    String body = notification?.body ?? data['body'] ?? 'No Body';

    //Android notification
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'CHANNEL_ID',
          'CHANNEL_NAME',
          channelDescription: 'Notification channel for basics',
          priority: Priority.high,
          importance: Importance.high,
        );

    //iOS notification

    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    //combine platform-check

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSDetails,
    );

    //show notifications

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      title,
      body,
      notificationDetails,
    );
  }
  // initial firebase messaging

 static Future<void> initializeNotification() async {
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showFlutterNotification(message);
    });

    await _getFcmToken();

    await _initializeLocalNotification();

    await _getInitialNotification();
  }

  //Fetch and print fcm token

 static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  //initialize the local notification system

 static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            print('onDidReceiveNotificationResponse');
          },
    );
  }

 static Future<void> _getInitialNotification() async {
    RemoteMessage? message = await _firebaseMessaging.getInitialMessage();

    if (message != null) {
      print('Message payload: ${message.data}');
    }
  }
}
