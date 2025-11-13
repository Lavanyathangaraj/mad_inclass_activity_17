import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

/// BACKGROUND MESSAGE HANDLER
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Background Message: ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  const MessagingTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;

    _requestNotificationPermission();
    _initializeFCM();
    _listenToForegroundMessages();
    _listenToNotificationClick();
  }

  // 🔹 Request Notification Permission (important for Android 13+ & iOS)
  void _requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

    print("User Permission Status: ${settings.authorizationStatus}");
  }

  // 🔹 Get Token + Subscribe to topic
  void _initializeFCM() async {
    messaging.subscribeToTopic("messaging");

    String? token = await messaging.getToken();
    print("FCM Token: $token");
  }

  // 🔹 Handle messages while the app is OPEN
  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message Received: ${event.notification?.body}");
      print("Data: ${event.data}");

      if (event.notification?.body != null) {
        _showAlert(event.notification!.title ?? "Notification",
            event.notification!.body!);
      }
    });
  }

  // 🔹 Listen when notification is clicked
  void _listenToNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked!");
      _showAlert("Notification Clicked",
          message.notification?.body ?? "Opened the notification");
    });
  }

  // 🔹 Show Dialog Alert
  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))
        ],
      ),
    );
  }

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(child: Text("Messaging Tutorial")),
    );
  }
}
