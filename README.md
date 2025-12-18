# ScoutPresence

Application mobile de gestion administrative des groupes scouts avec fonctionnalité offline-first.

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
- **Local** : Stockage dans Isar Database (NoSQL haute performance)
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

- Prise de présence possible en forêt/camp sans internet grâce à Isar
- Synchronisation automatique dès que le téléphone retrouve du réseau
- Aucune perte de données

## 🛠️ Spécifications Techniques

### Frontend & Mobile

- **Framework** : Flutter (Dart)
- **Gestion d'état** : Provider (ou Riverpod)
- **Base de données locale** : Isar Database (NoSQL haute performance)
- **Architecture** : Clean Architecture avec séparation des couches (Domain, Data, Presentation)

### Backend (Firebase)

- **Authentification** : Firebase Auth (Email/Mot de passe)
- **Base de données Cloud** : Cloud Firestore (Stockage centralisé)
- **Fonctions** : Cloud Functions pour la synchronisation et les notifications

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

4. Configurer Isar :
   - Les schémas Isar seront générés automatiquement lors du build

5. Lancer l'application :
```bash
flutter run
```

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

## 🚀 Évolutions Futures

- Suivi de la progression et badges
- Gestion des cotisations
- Export PDF des listes de présence
- Statistiques et rapports
- Notifications push
- Mode multi-groupes pour les chefs

## 📄 Licence

[À définir]

## 👨‍💻 Contribution

Les contributions sont les bienvenues ! Veuillez consulter le guide de contribution dans [ARCHITECTURE.md](ARCHITECTURE.md).

## 📞 Contact

[À définir]
