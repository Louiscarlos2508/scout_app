/// Script pour créer les utilisateurs initiaux dans Firestore.
/// 
/// Utilisation:
/// ```bash
/// dart scripts/create_initial_users.dart
/// ```
/// 
/// Note: Ce script nécessite Firebase CLI configuré ou peut être exécuté
/// via Firebase Functions ou directement depuis l'application en mode admin.

import 'dart:io';

/// Liste des utilisateurs initiaux pour le développement.
final initialUsers = [
  {
    'id': 'admin-user-1',
    'email': 'admin@scoutapp.com',
    'firstName': 'Admin',
    'lastName': 'Principal',
    'role': 'admin',
    'unitId': 'unit-1',
    'branchId': null,
  },
  {
    'id': 'leader-user-1',
    'email': 'chef@scoutapp.com',
    'firstName': 'Jean',
    'lastName': 'Dupont',
    'role': 'unitLeader',
    'unitId': 'unit-1',
    'branchId': null,
  },
  {
    'id': 'assistant-user-1',
    'email': 'assistant@scoutapp.com',
    'firstName': 'Marie',
    'lastName': 'Martin',
    'role': 'assistantLeader',
    'unitId': 'unit-1',
    'branchId': 'branch-louveteaux-1',
  },
  {
    'id': 'assistant-user-2',
    'email': 'assistant2@scoutapp.com',
    'firstName': 'Pierre',
    'lastName': 'Bernard',
    'role': 'assistantLeader',
    'unitId': 'unit-1',
    'branchId': 'branch-eclaireurs-1',
  },
];

/// Génère un document JSON pour Firestore.
String generateFirestoreDocument(Map<String, dynamic> user) {
  final buffer = StringBuffer();
  buffer.writeln('Document ID: ${user['id']}');
  buffer.writeln('Collection: users');
  buffer.writeln('Fields:');
  buffer.writeln('  - id: ${user['id']}');
  buffer.writeln('  - email: ${user['email']}');
  buffer.writeln('  - firstName: ${user['firstName']}');
  buffer.writeln('  - lastName: ${user['lastName']}');
  buffer.writeln('  - role: ${user['role']}');
  buffer.writeln('  - unitId: ${user['unitId']}');
  if (user['branchId'] != null) {
    buffer.writeln('  - branchId: ${user['branchId']}');
  }
  buffer.writeln('');
  return buffer.toString();
}

/// Génère un script Firebase pour créer les utilisateurs.
String generateFirebaseScript() {
  final buffer = StringBuffer();
  buffer.writeln('#!/bin/bash');
  buffer.writeln('# Script pour créer les utilisateurs initiaux dans Firestore');
  buffer.writeln('# Utilisation: bash scripts/create_initial_users.sh');
  buffer.writeln('');
  
  for (final user in initialUsers) {
    final userId = user['id'];
    buffer.writeln('echo "Création de l\'utilisateur: $userId"');
    buffer.writeln('firebase firestore:set users/$userId \\');
    buffer.writeln('  id=${user['id']} \\');
    buffer.writeln('  email=${user['email']} \\');
    buffer.writeln('  firstName=${user['firstName']} \\');
    buffer.writeln('  lastName=${user['lastName']} \\');
    buffer.writeln('  role=${user['role']} \\');
    buffer.writeln('  unitId=${user['unitId']}');
    if (user['branchId'] != null) {
      buffer.writeln('  branchId=${user['branchId']}');
    }
    buffer.writeln('');
  }
  
  return buffer.toString();
}

void main() {
  print('=== Génération des utilisateurs initiaux ===\n');
  
  print('📋 Liste des utilisateurs à créer:\n');
  for (final user in initialUsers) {
    print(generateFirestoreDocument(user));
  }
  
  print('📝 Instructions pour créer ces utilisateurs:\n');
  print('1. Via Firebase Console:');
  print('   - Aller dans Firestore Database');
  print('   - Créer la collection "users"');
  print('   - Ajouter chaque document avec les champs indiqués ci-dessus\n');
  
  print('2. Via Firebase CLI:');
  print('   - Exécuter: firebase firestore:set users/{userId} {champs}');
  print('   - Exemple:');
  print('     firebase firestore:set users/admin-user-1 \\');
  print('       id=admin-user-1 \\');
  print('       email=admin@scoutapp.com \\');
  print('       firstName=Admin \\');
  print('       lastName=Principal \\');
  print('       role=admin \\');
  print('       unitId=unit-1\n');
  
  print('3. Via l\'application (en tant qu\'admin):');
  print('   - Utiliser l\'interface d\'administration');
  print('   - Créer les utilisateurs manuellement\n');
  
  print('⚠️  IMPORTANT:');
  print('   - Créer d\'abord les utilisateurs dans Firebase Authentication');
  print('   - Utiliser les mêmes emails que dans les documents Firestore');
  print('   - Les mots de passe par défaut pour le développement:');
  print('     - admin@scoutapp.com: Admin123!');
  print('     - chef@scoutapp.com: Chef123!');
  print('     - assistant@scoutapp.com: Assistant123!');
  print('     - assistant2@scoutapp.com: Assistant123!\n');
}
