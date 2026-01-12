import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service pour gérer les notifications Firebase Cloud Messaging.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialise le service de notifications.
  static Future<void> initialize() async {
    // Demander la permission pour les notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Obtenir le token FCM
    String? token = await _messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await saveTokenToFirestore(token);
    }

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      saveTokenToFirestore(newToken);
    });

    // Configurer les handlers pour les notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Sauvegarde le token FCM dans Firestore pour l'utilisateur actuel.
  static Future<void> saveTokenToFirestore(String token, {String? userId}) async {
    try {
      // Si userId n'est pas fourni, on essaie de le récupérer depuis Firebase Auth
      // Pour l'instant, on stocke le token dans une collection séparée
      // qui sera liée à l'utilisateur lors de la connexion
      await _firestore
          .collection('fcm_tokens')
          .doc(token)
          .set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Met à jour le token FCM avec l'ID de l'utilisateur après connexion.
  static Future<void> updateTokenWithUserId(String token, String userId) async {
    try {
      await _firestore
          .collection('fcm_tokens')
          .doc(token)
          .update({
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating FCM token with userId: $e');
    }
  }

  /// Envoie une notification à un utilisateur spécifique.
  /// 
  /// Cette méthode ne lève jamais d'exception. Toutes les erreurs sont silencieusement ignorées.
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Sur le web, les notifications FCM peuvent ne pas être disponibles
      if (kIsWeb) {
        // Sur le web, on peut quand même sauvegarder la notification dans Firestore
        // mais on ne tente pas d'obtenir le token FCM
      }

      // Récupérer le token FCM de l'utilisateur (optionnel)
      try {
      final tokensSnapshot = await _firestore
          .collection('fcm_tokens')
          .where('userId', isEqualTo: userId)
            .get()
            .timeout(const Duration(seconds: 5));

      if (tokensSnapshot.docs.isEmpty) {
          // Pas de token FCM, mais on peut quand même sauvegarder la notification
        }
      } catch (e) {
        // Ignorer les erreurs de récupération du token
      }

      // Sauvegarder la notification dans Firestore
      // L'envoi réel via FCM nécessiterait Cloud Functions
      await _firestore
          .collection('notifications')
          .add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Ignorer silencieusement toutes les erreurs
      // (peut échouer si pas de connexion, permissions refusées, etc.)
    }
  }

  /// Gère les notifications reçues quand l'app est au premier plan.
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  /// Gère les notifications qui ont ouvert l'app.
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
  }

  /// Obtient le token FCM actuel.
  /// Retourne null sur le web ou en cas d'erreur.
  static Future<String?> getToken() async {
    try {
      // Sur le web, FCM nécessite une configuration spéciale avec service worker
      // Pour l'instant, on retourne null pour éviter les erreurs
      if (kIsWeb) {
        return null;
      }
    return await _messaging.getToken();
    } catch (e) {
      // Ignorer les erreurs (permissions non accordées, etc.)
      return null;
    }
  }
}

