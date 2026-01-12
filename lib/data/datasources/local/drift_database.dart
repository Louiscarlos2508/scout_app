import 'database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Gestionnaire centralisé pour la base de données Drift.
/// 
/// Utilise Drift uniquement sur mobile et desktop.
/// Sur le web, on utilise uniquement Firebase (pas de base de données locale).
class DriftDatabase {
  static AppDatabase? _database;

  /// Instance de la base de données (doit être initialisée avec init()).
  /// 
  /// Lance une exception sur le web car Drift n'est pas utilisé sur cette plateforme.
  static AppDatabase get database {
    if (kIsWeb) {
      throw UnsupportedError(
        'DriftDatabase is not supported on web. Use Firebase directly instead.',
      );
    }
    if (_database == null) {
      throw Exception(
        'DriftDatabase not initialized. Call DriftDatabase.init() first.',
      );
    }
    return _database!;
  }

  /// Initialise la base de données Drift.
  /// 
  /// Ne fait rien sur le web (Drift n'est pas utilisé sur cette plateforme).
  static Future<void> init() async {
    if (kIsWeb) {
      // Sur le web, on n'utilise pas Drift, uniquement Firebase
      return;
    }
    
    if (_database != null) {
      return; // Déjà initialisé
    }

    _database = AppDatabase();
  }

  /// Ferme la base de données Drift.
  static Future<void> close() async {
    if (kIsWeb) {
      return;
    }
    await _database?.close();
    _database = null;
  }

  /// Vérifie si Drift est initialisé.
  /// 
  /// Retourne toujours false sur le web.
  static bool get isInitialized => kIsWeb ? false : _database != null;
}

