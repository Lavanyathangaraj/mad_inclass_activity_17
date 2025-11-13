import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Background handler
Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔥 Background Message: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  runApp(const NotificationApp());
}

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notification Types Demo",
      home: const NotificationHome(title: "Cloud Messaging Notification"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotificationHome extends StatefulWidget {
  final String title;

  const NotificationHome({super.key, required this.title});

  @override
  State<NotificationHome> createState() => _NotificationHomeState();
}

class _NotificationHomeState extends State<NotificationHome> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    listenToNotifications();
  }

  void requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get device token
    String? token = await messaging.getToken();
    print("FCM Token: $token");
  }

  void listenToNotifications() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      addNotification(message);
    });

    // Notification click (from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      addNotification(message);
    });

    // Terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        addNotification(message);
      }
    });
  }

  void addNotification(RemoteMessage message) {
    final type = message.data["type"] ?? "regular";

    setState(() {
      notifications.insert(0, {
        "title": message.notification?.title ?? "No Title",
        "body": message.notification?.body ?? "No Body",
        "type": type,
        "category": message.data["category"] ?? "unknown",
      });
    });
  }

  Color getColor(String type) {
    switch (type) {
      case "important":
        return Colors.red.shade300;
      case "wisdom":
        return Colors.blue.shade300;
      case "regular":
      default:
        return Colors.green.shade300;
    }
  }

  IconData getIcon(String type) {
    switch (type) {
      case "important":
        return Icons.warning_amber_rounded;
      case "wisdom":
        return Icons.auto_stories;
      case "regular":
      default:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications received yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  color: getColor(n["type"]),
                  child: ListTile(
                    leading: Icon(
                      getIcon(n["type"]),
                      size: 32,
                    ),
                    title: Text(
                      n["title"],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(n["body"]),
                    trailing: Text(
                      n["type"].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
