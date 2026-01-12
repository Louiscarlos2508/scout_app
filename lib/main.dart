import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/datasources/local/drift_database.dart';
import 'data/datasources/local/member_local_datasource.dart';
import 'data/datasources/local/attendance_local_datasource.dart';
import 'data/datasources/remote/member_remote_datasource.dart';
import 'data/datasources/remote/attendance_remote_datasource.dart';
import 'core/services/realtime_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/firebase_messaging_background_handler.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/di/providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Service de synchronisation global
RealtimeSyncService? _syncService;

/// Getter pour accéder au service de synchronisation global
RealtimeSyncService? get syncService => _syncService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase avec les options de la plateforme
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurer le handler pour les notifications en arrière-plan (uniquement sur mobile/desktop)
  // Sur le web, Firebase Messaging nécessite un service worker et une configuration plus complexe
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Initialiser le service de notifications
    await NotificationService.initialize();
  }
  
  // Initialiser Drift uniquement sur mobile/desktop (pas sur le web)
  // Sur le web, on utilise uniquement Firebase
  if (!kIsWeb) {
    await DriftDatabase.init();
    
    // Initialiser le service de synchronisation en temps réel (bidirectionnel)
    // Note: Les branches sont codées en dur et ne sont pas synchronisées depuis Firestore
    // Synchronisation bidirectionnelle :
    // - Firestore → Local : Écoute les changements Firestore en temps réel
    // - Local → Firestore : Synchronise périodiquement les données non synchronisées (toutes les 30s)
    _syncService = RealtimeSyncService(
      memberLocalDataSource: MemberLocalDataSourceImpl(),
      attendanceLocalDataSource: AttendanceLocalDataSourceImpl(),
      memberRemoteDataSource: MemberRemoteDataSourceImpl(),
      attendanceRemoteDataSource: AttendanceRemoteDataSourceImpl(),
    );
    
    // Démarrer la synchronisation en temps réel (membres et sessions uniquement)
    _syncService!.startSync().catchError((e) {
      // Ignorer les erreurs de synchronisation au démarrage (peut échouer si pas connecté)
    });
  }
  
  runApp(const ScoutPresenceApp());
}

class ScoutPresenceApp extends StatelessWidget {
  const ScoutPresenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Builder(
        builder: (context) {
          // ✅ CONTEXTE CORRECT (sous MultiProvider)
          final authProvider = context.watch<AuthProvider>();

          return MaterialApp.router(
            title: 'ScoutPresence',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.createRouter(authProvider),
            // Localizations pour DatePicker et autres widgets Material
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr', 'FR'), // Français
              Locale('en', 'US'), // Anglais (fallback)
            ],
            locale: const Locale('fr', 'FR'),
          );
        },
      ),
    );
  }
}
