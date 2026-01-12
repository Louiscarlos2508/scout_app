import 'package:firebase_messaging/firebase_messaging.dart';

/// Handler pour les notifications en arrière-plan (doit être une fonction top-level).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}
