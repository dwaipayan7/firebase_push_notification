import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification/screens/notification_details.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {


  void firebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    //FCM Token
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // foreground notification

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "No Title";
      final body = message.notification?.body ?? "No Body";

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(
            body,
            style: TextStyle(overflow: TextOverflow.ellipsis),
            maxLines: 1,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationDetails(title: title, body: body),
                  ),
                );
              },
              child: Text("Next"),
            ),
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text("Cancelled")),
          ],
        ),
      );
    });

    //app is not close but is in the background

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "No Title";
      final body = message.notification?.body ?? "No Body";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetails(title: title, body: body),
        ),
      );
    });

    //termination state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final title = message.notification?.title ?? "No Title";
        final body = message.notification?.body ?? "No Body";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetails(title: title, body: body),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Push Notification", style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

    );
  }
}
