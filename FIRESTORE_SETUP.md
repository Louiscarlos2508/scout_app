# Configuration Firestore pour ScoutPresence

Ce document décrit la configuration et le déploiement des règles de sécurité Firestore, ainsi que la création des utilisateurs initiaux.

## 📋 Table des matières

1. [Règles de sécurité Firestore](#règles-de-sécurité-firestore)
2. [Déploiement des règles](#déploiement-des-règles)
3. [Création des utilisateurs initiaux](#création-des-utilisateurs-initiaux)
4. [Synchronisation bidirectionnelle](#synchronisation-bidirectionnelle)
5. [Gestion des conflits](#gestion-des-conflits)

## 🔒 Règles de sécurité Firestore

Les règles de sécurité sont définies dans `firestore.rules` à la racine du projet.

### Structure des règles

Les règles suivent cette hiérarchie d'accès :

- **Admin** : Accès complet à toutes les collections
- **Chef d'Unité** : Accès à toutes les branches de son unité
- **Chef Assistant** : Accès uniquement à sa branche spécifique

### Collections protégées

#### `users`
- **Lecture** : Admin ou utilisateur lui-même
- **Création** : Admin uniquement
- **Mise à jour** : Admin ou utilisateur lui-même (sauf le rôle)
- **Suppression** : Admin uniquement

#### `members`
- **Lecture/Écriture** : Utilisateurs avec accès à la branche du membre

#### `attendance`
- **Lecture/Écriture** : Utilisateurs avec accès à la branche de la session

#### `branches`, `units`, `groups`
- **Lecture** : Tous les utilisateurs authentifiés
- **Écriture** : Admin et Chef d'Unité (pour leur unité)

## 🚀 Déploiement des règles

### Prérequis

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter à Firebase
firebase login
```

### Déploiement

```bash
# Déployer uniquement les règles Firestore
firebase deploy --only firestore:rules
```

### Test des règles

Utilisez l'émulateur Firebase pour tester les règles localement :

```bash
# Démarrer l'émulateur
firebase emulators:start --only firestore

# Tester les règles
firebase emulators:exec --only firestore "flutter test"
```

## 👥 Création des utilisateurs initiaux

### Option 1: Via Firebase Console (Recommandé)

1. **Créer les utilisateurs dans Firebase Authentication:**
   - Aller dans Firebase Console > Authentication > Users
   - Cliquer sur "Add user"
   - Ajouter les utilisateurs avec leurs emails et mots de passe

2. **Créer les documents Firestore:**
   - Aller dans Firestore Database
   - Créer la collection `users`
   - Pour chaque utilisateur créé dans Auth, créer un document avec l'UID comme ID du document
   - Ajouter les champs suivants :

#### Admin User
- Document ID: `[UID de Firebase Auth]`
- Fields:
  ```
  id: "admin-user-1"
  email: "admin@scoutapp.com"
  firstName: "Admin"
  lastName: "Principal"
  role: "admin"
  unitId: "unit-1"
  ```

#### Chef d'Unité
- Document ID: `[UID de Firebase Auth]`
- Fields:
  ```
  id: "leader-user-1"
  email: "chef@scoutapp.com"
  firstName: "Jean"
  lastName: "Dupont"
  role: "unitLeader"
  unitId: "unit-1"
  ```

#### Chef Assistant
- Document ID: `[UID de Firebase Auth]`
- Fields:
  ```
  id: "assistant-user-1"
  email: "assistant@scoutapp.com"
  firstName: "Marie"
  lastName: "Martin"
  role: "assistantLeader"
  unitId: "unit-1"
  branchId: "branch-louveteaux-1"
  ```

### Option 2: Via Firebase CLI

Voir `scripts/README.md` pour les commandes détaillées.

### Option 3: Via le script Dart

```bash
dart scripts/create_initial_users.dart
```

## 🔄 Synchronisation bidirectionnelle

La synchronisation bidirectionnelle est implémentée dans `lib/core/services/realtime_sync_service.dart`.

**Note :** Le projet utilise maintenant `RealtimeSyncService` (synchronisation en temps réel) au lieu de `SyncService` (synchronisation manuelle).

### Fonctionnement

Le `RealtimeSyncService` implémente une synchronisation bidirectionnelle en temps réel :

1. **Firestore → Local** : Écoute les changements Firestore en temps réel et met à jour Drift automatiquement
2. **Local → Firestore** : Synchronise périodiquement les données non synchronisées (toutes les 30 secondes)
3. **Détection** : Identifie les données non synchronisées (`lastSync == null`)
4. **Upload** : Envoie les données locales non synchronisées vers Firestore
5. **Résolution** : Résout les conflits selon la stratégie Last-Write-Wins

### Initialisation

Le service est initialisé automatiquement dans `main.dart` au démarrage de l'application (uniquement sur mobile/desktop, pas sur le web).

```dart
// Dans main.dart
if (!kIsWeb) {
  _syncService = RealtimeSyncService(
    memberLocalDataSource: MemberLocalDataSourceImpl(),
    attendanceLocalDataSource: AttendanceLocalDataSourceImpl(),
    memberRemoteDataSource: MemberRemoteDataSourceImpl(),
    attendanceRemoteDataSource: AttendanceRemoteDataSourceImpl(),
  );
  await _syncService!.startSync();
}
```

**Note :** Sur le web, la synchronisation en temps réel se fait directement via les listeners Firestore dans les providers.

## ⚔️ Gestion des conflits

La stratégie **Last-Write-Wins** (LWW) est utilisée pour résoudre les conflits.

### Algorithme

1. Comparer les `lastSync` des deux versions (locale et distante)
2. Si une version n'a pas de `lastSync`, utiliser l'autre
3. Si les deux ont un `lastSync`, utiliser la version avec le timestamp le plus récent
4. Mettre à jour Firestore avec la version gagnante
5. Mettre à jour le cache local avec la version résolue

### Exemple

```
Version locale  : lastSync = 2024-01-15 10:00:00
Version distante: lastSync = 2024-01-15 11:00:00

Résultat: Version distante gagne (plus récente)
```

## 📝 Notes importantes

- **Les IDs Firestore doivent correspondre aux UIDs Firebase Auth** pour les utilisateurs
- **Le champ `lastSync`** est utilisé pour la détection de conflits et doit être mis à jour à chaque modification
- **La synchronisation est automatique** lors des opérations CRUD si une connexion est disponible
- **En mode offline**, les données sont sauvegardées localement et synchronisées dès la reconnexion

## 🔍 Vérification

Pour vérifier que tout fonctionne :

1. **Tester les règles** : Utiliser l'émulateur Firebase
2. **Tester la synchronisation** : Créer/modifier des membres en mode offline puis reconnecter
3. **Tester les conflits** : Modifier le même membre depuis deux appareils différents
