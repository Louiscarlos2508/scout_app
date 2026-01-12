# Scripts d'Initialisation

Ce dossier contient des scripts utilitaires pour initialiser et configurer l'application.

## Création des Utilisateurs Initiaux

### Option 1: Via Firebase Console (Recommandé pour le développement)

1. **Créer les utilisateurs dans Firebase Authentication:**
   - Aller dans Firebase Console > Authentication
   - Ajouter des utilisateurs avec email/mot de passe:
     - `admin@scoutapp.com` / `Admin123!`
     - `chef@scoutapp.com` / `Chef123!`
     - `assistant@scoutapp.com` / `Assistant123!`
     - `assistant2@scoutapp.com` / `Assistant123!`

2. **Créer les documents Firestore:**
   - Aller dans Firestore Database
   - Créer la collection `users`
   - Ajouter chaque document avec les données suivantes:

#### Admin User
```json
{
  "id": "admin-user-1",
  "email": "admin@scoutapp.com",
  "firstName": "Admin",
  "lastName": "Principal",
  "role": "admin",
  "unitId": "unit-1"
}
```

#### Chef d'Unité
```json
{
  "id": "leader-user-1",
  "email": "chef@scoutapp.com",
  "firstName": "Jean",
  "lastName": "Dupont",
  "role": "unitLeader",
  "unitId": "unit-1"
}
```

#### Chef Assistant 1
```json
{
  "id": "assistant-user-1",
  "email": "assistant@scoutapp.com",
  "firstName": "Marie",
  "lastName": "Martin",
  "role": "assistantLeader",
  "unitId": "unit-1",
  "branchId": "branch-louveteaux-1"
}
```

#### Chef Assistant 2
```json
{
  "id": "assistant-user-2",
  "email": "assistant2@scoutapp.com",
  "firstName": "Pierre",
  "lastName": "Bernard",
  "role": "assistantLeader",
  "unitId": "unit-1",
  "branchId": "branch-eclaireurs-1"
}
```

### Option 2: Via Firebase CLI

```bash
# Créer l'utilisateur admin
firebase firestore:set users/admin-user-1 \
  id=admin-user-1 \
  email=admin@scoutapp.com \
  firstName=Admin \
  lastName=Principal \
  role=admin \
  unitId=unit-1

# Créer le chef d'unité
firebase firestore:set users/leader-user-1 \
  id=leader-user-1 \
  email=chef@scoutapp.com \
  firstName=Jean \
  lastName=Dupont \
  role=unitLeader \
  unitId=unit-1

# Créer le premier assistant
firebase firestore:set users/assistant-user-1 \
  id=assistant-user-1 \
  email=assistant@scoutapp.com \
  firstName=Marie \
  lastName=Martin \
  role=assistantLeader \
  unitId=unit-1 \
  branchId=branch-louveteaux-1

# Créer le deuxième assistant
firebase firestore:set users/assistant-user-2 \
  id=assistant-user-2 \
  email=assistant2@scoutapp.com \
  firstName=Pierre \
  lastName=Bernard \
  role=assistantLeader \
  unitId=unit-1 \
  branchId=branch-eclaireurs-1
```

### Option 3: Via le Script Dart

```bash
dart scripts/create_initial_users.dart
```

Ce script affiche les instructions pour créer les utilisateurs manuellement.

## Déploiement des Règles Firestore

```bash
firebase deploy --only firestore:rules
```

## Notes Importantes

- **Les IDs dans Firestore doivent correspondre aux UIDs Firebase Auth**
- **Pour le développement, vous pouvez utiliser des IDs simples, mais en production, utilisez les UIDs Firebase Auth réels**
- **Assurez-vous que les règles Firestore sont déployées avant de créer les utilisateurs**
