# ScoutPresence

Application mobile de gestion administrative des groupes scouts avec fonctionnalité offline-first.

**Version :** 1.0.0+1  
**Dernière mise à jour :** 12 janvier 2025

## 🎯 Vision du Projet

Digitaliser la gestion administrative des groupes scouts via une application mobile performante capable de fonctionner sans connexion internet (Offline-first).

## 📋 Structure Hiérarchique

L'application respecte la structure spécifique des groupes scouts :

```
Groupe Scout
  └── Unités
      └── Branches
          ├── Louveteaux (7-12 ans) - Jaune
          ├── Éclaireurs (13-16 ans) - Vert
          ├── Sinikié (17-20 ans) - Orange
          └── Routiers (21-25 ans) - Rouge
```

## 👥 Rôles Utilisateurs (Chefs)

### Chef d'Unité
- Accès complet à toutes les branches de son unité
- Peut gérer tous les membres et présences de l'unité

### Chef Assistant
- Accès restreint à sa branche spécifique
- Peut gérer uniquement les membres et présences de sa branche

## ✨ Fonctionnalités MVP

### A. Gestion des Éléments (Membres)

#### Stockage Hybride
- **Local** : Stockage dans Drift Database (SQLite avec support multi-plateforme)
- **Cloud** : Synchronisation avec Firebase Firestore
- **Offline-first** : Fonctionnement complet sans internet, synchronisation automatique dès reconnexion

#### Fiche Profil
- Nom et Prénom
- Date de naissance
- Contacts parents (avec bouton d'appel direct)

#### Fiche Sanitaire
- Allergies
- Maladies
- Traitements en cours
- Groupe sanguin
- Notes médicales

### B. Gestion des Présences

#### Listes par Branche
- Filtrage par unité et branche
- Affichage des membres avec leur statut

#### Sessions
- Création de rencontres :
  - Hebdomadaire
  - Mensuelle
  - Activité spéciale

#### Pointage Rapide
- Toggle Présent/Absent pour chaque membre
- Interface intuitive et rapide

### C. Mode Hors-Ligne

- Prise de présence possible en forêt/camp sans internet grâce à Drift
- Synchronisation automatique dès que le téléphone retrouve du réseau
- Aucune perte de données

## 🛠️ Spécifications Techniques

### Frontend & Mobile

- **Framework** : Flutter 3.10.4 (Dart)
- **Gestion d'état** : Provider 6.1.5+1
- **Base de données locale** : Drift Database 2.30.0 (SQLite avec support multi-plateforme)
- **Architecture** : Clean Architecture avec séparation des couches (Domain, Data, Presentation)
- **Routing** : Go Router 14.8.1

### Backend (Firebase)

- **Authentification** : Firebase Auth 5.7.0 (Email/Mot de passe, Google Sign-In)
- **Base de données Cloud** : Cloud Firestore 5.6.12 (Stockage centralisé)
- **Stockage** : Firebase Storage 12.4.10 (Photos de profil)
- **Notifications** : Firebase Messaging 15.2.10 (Notifications push)
- **Synchronisation** : RealtimeSyncService (Synchronisation bidirectionnelle en temps réel)

## 📦 Installation

### Prérequis

- Flutter SDK (version 3.10.4 ou supérieure)
- Dart SDK
- Un projet Firebase configuré

### Étapes d'installation

1. Cloner le repository :
```bash
git clone <url-du-repo>
cd scout_app
```

2. Installer les dépendances :
```bash
flutter pub get
```

3. Configurer Firebase :
   - Ajouter les fichiers de configuration Firebase (`google-services.json` pour Android, `GoogleService-Info.plist` pour iOS)
   - Configurer Firebase dans votre projet Flutter

4. Générer le code Drift :
   - Exécutez `dart run build_runner build --delete-conflicting-outputs`
   - Les fichiers générés seront créés automatiquement

5. Configurer les utilisateurs initiaux :
   - Voir [scripts/README.md](scripts/README.md) pour créer les utilisateurs de développement
   - Voir [FIRESTORE_SETUP.md](FIRESTORE_SETUP.md) pour la configuration Firestore complète

6. Lancer l'application :
```bash
flutter run
```

### Plateformes Supportées

- ✅ Android
- ✅ iOS
- ✅ Web (Firebase uniquement, pas de stockage local)
- ✅ Linux
- ✅ macOS
- ✅ Windows

## 📁 Structure du Projet

```
lib/
├── core/                    # Code partagé transversal
│   ├── constants/          # Constantes globales
│   ├── errors/             # Gestion d'erreurs
│   ├── network/            # Vérification réseau
│   ├── utils/              # Utilitaires
│   └── extensions/         # Extensions Dart
│
├── domain/                 # Couche métier (business logic pure)
│   ├── entities/          # Entités du domaine
│   ├── repositories/      # Interfaces des repositories
│   └── usecases/         # Cas d'utilisation
│
├── data/                  # Couche données
│   ├── datasources/      # Sources de données (local/remote)
│   ├── models/           # Modèles de données avec sérialisation
│   └── repositories/     # Implémentations des repositories
│
└── presentation/          # Couche présentation (MVP pattern)
    ├── providers/        # State management
    ├── screens/          # Écrans de l'application
    ├── widgets/          # Widgets réutilisables
    ├── routes/           # Configuration du routage
    └── theme/            # Thème et styles
```

Pour plus de détails sur l'architecture, consultez [ARCHITECTURE.md](ARCHITECTURE.md).

## 🗄️ Schéma de Données

### Collection Members
- `id` : Identifiant unique
- `firstName` : Prénom
- `lastName` : Nom
- `dateOfBirth` : Date de naissance
- `branchId` : ID de la branche
- `parentPhone` : Téléphone des parents
- `medicalInfo` : Informations médicales
- `lastSync` : Date de dernière synchronisation

### Collection Attendance
- `id` : Identifiant unique
- `date` : Date de la session
- `type` : Type de session (hebdomadaire, mensuelle, spéciale)
- `branchId` : ID de la branche
- `presentMemberIds` : Liste des IDs des membres présents
- `absentMemberIds` : Liste des IDs des membres absents
- `lastSync` : Date de dernière synchronisation

## 🔄 Synchronisation

L'application utilise une stratégie **offline-first** :

- **Stockage local** : Drift Database (SQLite) sur mobile/desktop
- **Synchronisation** : Bidirectionnelle en temps réel via `RealtimeSyncService`
- **Fonctionnement offline** : Toutes les opérations fonctionnent sans internet
- **Synchronisation automatique** : Dès la reconnexion, les données sont synchronisées avec Firestore

### Détails Techniques

- **Firestore → Local** : Écoute des changements Firestore en temps réel
- **Local → Firestore** : Synchronisation périodique des données non synchronisées (toutes les 30 secondes)
- **Résolution de conflits** : Stratégie Last-Write-Wins (dernière écriture gagne)
- **Support Web** : Utilise uniquement Firebase (pas de stockage local Drift)

## 🚀 Évolutions Futures

- Suivi de la progression et badges
- Gestion des cotisations
- Export PDF des listes de présence
- Statistiques et rapports
- Mode multi-groupes pour les chefs

## 📚 Documentation Complémentaire

- [ARCHITECTURE.md](ARCHITECTURE.md) - Documentation détaillée de l'architecture
- [FIRESTORE_SETUP.md](FIRESTORE_SETUP.md) - Configuration Firestore et règles de sécurité
- [AUDIT.md](AUDIT.md) - Rapport d'audit complet du projet (12 janvier 2025)
- [scripts/README.md](scripts/README.md) - Scripts d'initialisation et création d'utilisateurs

## 📄 Licence

[À définir]

## 👨‍💻 Contribution

Les contributions sont les bienvenues ! Veuillez consulter le guide de contribution dans [ARCHITECTURE.md](ARCHITECTURE.md).

## 🔍 État du Projet

Pour un audit complet du projet, consultez [AUDIT.md](AUDIT.md) (12 janvier 2025).
