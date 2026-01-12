import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/services/notification_service.dart';
import '../datasources/remote/firebase_service.dart';
import '../models/user_model.dart';

/// Implémentation du repository Auth avec Firebase Auth et Firestore.
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  User? _currentUser;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return Left(
          AuthenticationFailure('Email et mot de passe requis'),
        );
      }

      // Authentifier avec Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Left(AuthenticationFailure('Échec de la connexion'));
      }

      // Récupérer les données utilisateur depuis Firestore
      final userDoc = await FirebaseService.getDocument(
        FirestoreConstants.usersCollection,
        firebaseUser.uid,
      );

      if (userDoc == null || !userDoc.exists) {
        // Si l'utilisateur n'existe pas dans Firestore, déconnecter de Firebase Auth
        await _firebaseAuth.signOut();
        return Left(AuthenticationFailure('Compte non trouvé. Veuillez vous inscrire.'));
      }

      // Convertir le document Firestore en User
      final userData = userDoc.data();
      if (userData == null) {
        await _firebaseAuth.signOut();
        return Left(AuthenticationFailure('Données utilisateur invalides.'));
      }
      
      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);
      
      // Ne pas bloquer la connexion si l'utilisateur est en attente
      // Le router gérera la redirection vers l'écran d'attente
      _currentUser = userModel;

      return Right(userModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Erreur de connexion';
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'user-disabled':
          message = 'Compte utilisateur désactivé';
          break;
        default:
          message = e.message ?? 'Erreur de connexion';
      }
      return Left(AuthenticationFailure(message));
    } catch (e) {
      return Left(AuthenticationFailure('Erreur: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Erreur lors de la déconnexion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser == null) {
        _currentUser = null;
        return const Right(null);
      }

      // Si on a déjà l'utilisateur en cache, le retourner
      if (_currentUser != null && _currentUser!.id == firebaseUser.uid) {
        return Right(_currentUser);
      }

      // Sinon, récupérer depuis Firestore
      final userDoc = await FirebaseService.getDocument(
        FirestoreConstants.usersCollection,
        firebaseUser.uid,
      );

      if (userDoc == null || !userDoc.exists) {
        _currentUser = null;
        return const Right(null);
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);
      _currentUser = userModel;

      // Enregistrer le token FCM pour cet utilisateur (uniquement sur mobile/desktop)
      try {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await NotificationService.updateTokenWithUserId(fcmToken, firebaseUser.uid);
        }
      } catch (e) {
        // Ignorer les erreurs FCM (peut échouer sur le web ou si les permissions ne sont pas accordées)
        // Ne pas bloquer l'authentification pour cela
      }

      return Right(userModel);
    } catch (e) {
      return Left(AuthenticationFailure('Erreur: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null;
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.usersCollection,
      );

      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch users: ${e.toString()}');
    }
  }

  @override
  Future<User> updateUserRole(String userId, UserRole newRole) async {
    try {
      // Récupérer l'utilisateur actuel
      final userDoc = await FirebaseService.getDocument(
        FirestoreConstants.usersCollection,
        userId,
      );

      if (userDoc == null || !userDoc.exists) {
        throw ServerException('Utilisateur non trouvé');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      // Mettre à jour le rôle
      final updatedUser = User(
        id: userModel.id,
        email: userModel.email,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        phoneNumber: userModel.phoneNumber,
        dateOfBirth: userModel.dateOfBirth,
        role: newRole,
        status: userModel.status,
        unitId: userModel.unitId,
        branchId: userModel.branchId,
        photoUrl: userModel.photoUrl,
      );

      final updatedUserModel = UserModel.fromEntity(updatedUser);
      await FirebaseService.updateData(
        FirestoreConstants.usersCollection,
        userId,
        updatedUserModel.toJson(),
      );

      // Mettre à jour l'utilisateur actuel si c'est lui
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }

      return updatedUser;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update user role: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseService.deleteData(
        FirestoreConstants.usersCollection,
        userId,
      );

      // Déconnecter si l'utilisateur supprimé est l'utilisateur actuel
      if (_currentUser?.id == userId) {
        await _firebaseAuth.signOut();
        _currentUser = null;
      }
    } catch (e) {
      throw ServerException('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<Either<Failure, User>> createUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await FirebaseService.setData(
        FirestoreConstants.usersCollection,
        user.id,
        userModel.toJson(),
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to create user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Left(ServerFailure('Failed to create user in Firebase Auth'));
      }

      // IMPORTANT: L'inscription publique ne peut jamais créer un compte admin
      // Seuls les admins existants peuvent créer d'autres admins via le panneau d'administration
      // Le rôle initial n'a pas d'importance car l'admin choisira le rôle (unitLeader ou assistantLeader)
      // lors de l'approbation. On utilise unitLeader comme valeur par défaut pour correspondre
      // au dialog d'approbation, mais ce sera remplacé par l'admin.
      final user = User(
        id: firebaseUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        role: UserRole.unitLeader, // Rôle temporaire, sera changé par l'admin lors de l'approbation
        status: UserStatus.pending, // Toujours en attente de validation par un admin
        unitId: unitId,
        branchId: branchId,
      );

      final userModel = UserModel.fromEntity(user);
      await FirebaseService.setData(
        FirestoreConstants.usersCollection,
        firebaseUser.uid,
        userModel.toJson(),
      );

      _currentUser = user;
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Erreur lors de l\'inscription';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Cet email est déjà utilisé';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'weak-password':
          message = 'Mot de passe trop faible';
          break;
        default:
          message = e.message ?? message;
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure('Erreur: ${e.toString()}'));
    }
  }

  @override
  Future<List<User>> getPendingUsers() async {
    try {
      final docs = await FirebaseService.getCollection(
        FirestoreConstants.usersCollection,
      );

      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }).where((user) => 
        // Filtrer uniquement les utilisateurs en attente qui ne sont PAS des admins
        // Les admins ne doivent jamais apparaître dans la liste des demandes en attente
        user.status == UserStatus.pending && user.role != UserRole.admin
      ).toList();
    } catch (e) {
      throw ServerException('Failed to fetch pending users: ${e.toString()}');
    }
  }

  @override
  Future<Either<Failure, User>> approveUser(
    String userId,
    UserRole role, {
    String? unitId,
    String? branchId,
  }) async {
    try {
      // Récupérer l'utilisateur actuel
      final userDoc = await FirebaseService.getDocument(
        FirestoreConstants.usersCollection,
        userId,
      );

      if (userDoc == null || !userDoc.exists) {
        return Left(ServerFailure('Utilisateur non trouvé'));
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      // Mettre à jour le statut, le rôle, l'unité et la branche
      // Si unitId ou branchId sont fournis, les utiliser, sinon garder les valeurs existantes
      final approvedUser = User(
        id: userModel.id,
        email: userModel.email,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        phoneNumber: userModel.phoneNumber,
        dateOfBirth: userModel.dateOfBirth,
        role: role,
        status: UserStatus.approved,
        unitId: unitId ?? userModel.unitId,
        branchId: branchId ?? userModel.branchId,
        photoUrl: userModel.photoUrl,
      );

      final approvedUserModel = UserModel.fromEntity(approvedUser);
      await FirebaseService.updateData(
        FirestoreConstants.usersCollection,
        userId,
        approvedUserModel.toJson(),
      );

      // Retourner le UserModel au lieu du User pour maintenir la cohérence des types
      return Right(approvedUserModel);
    } catch (e) {
      return Left(ServerFailure('Failed to approve user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return Left(AuthenticationFailure('Connexion Google annulée'));
      }

      // Obtenir les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer un nouveau credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Une fois connecté, retourner le UserCredential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return Left(AuthenticationFailure('Échec de la connexion Google'));
      }

      // Vérifier si l'utilisateur existe déjà dans Firestore
      final userDoc = await FirebaseService.getDocument(
        FirestoreConstants.usersCollection,
        firebaseUser.uid,
      );

      if (userDoc == null || !userDoc.exists) {
        // Créer un utilisateur temporaire avec statut pending et informations incomplètes
        // IMPORTANT: L'inscription via Google ne peut jamais créer un compte admin
        // Le rôle initial n'a pas d'importance car l'admin choisira le rôle (unitLeader ou assistantLeader)
        // lors de l'approbation. On utilise unitLeader comme valeur par défaut.
        final displayName = firebaseUser.displayName ?? '';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final tempUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          firstName: firstName,
          lastName: lastName,
          phoneNumber: '', // À compléter
          dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // À compléter
          role: UserRole.unitLeader, // Rôle temporaire, sera changé par l'admin lors de l'approbation
          status: UserStatus.pending, // En attente de complément d'informations
          unitId: '', // À compléter
          branchId: '', // À compléter
        );

        final tempUserModel = UserModel.fromEntity(tempUser);
        await FirebaseService.setData(
          FirestoreConstants.usersCollection,
          firebaseUser.uid,
          tempUserModel.toJson(),
        );

        _currentUser = tempUser;

        // Enregistrer le token FCM pour cet utilisateur (uniquement sur mobile/desktop)
        try {
        final fcmToken = await NotificationService.getToken();
        if (fcmToken != null) {
          await NotificationService.updateTokenWithUserId(fcmToken, firebaseUser.uid);
          }
        } catch (e) {
          // Ignorer les erreurs FCM (peut échouer sur le web ou si les permissions ne sont pas accordées)
          // Ne pas bloquer l'authentification pour cela
        }

        return Right(tempUser);
      }

      // Convertir le document Firestore en User
      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      // Vérifier si les informations sont complètes
      if (userModel.phoneNumber.isEmpty ||
          userModel.unitId.isEmpty ||
          userModel.branchId.isEmpty) {
        // Informations incomplètes, retourner l'utilisateur pour compléter
        _currentUser = userModel;
        return Right(userModel);
      }

      // Les admins ont toujours accès, même s'ils sont en pending
      // Ne pas bloquer les admins
      if (userModel.status == UserStatus.pending && userModel.role != UserRole.admin) {
        return Left(AuthenticationFailure('Votre compte est en attente de validation par un administrateur.'));
      }

      _currentUser = userModel;

      // Enregistrer le token FCM pour cet utilisateur (uniquement sur mobile/desktop)
      try {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await NotificationService.updateTokenWithUserId(fcmToken, firebaseUser.uid);
        }
      } catch (e) {
        // Ignorer les erreurs FCM (peut échouer sur le web ou si les permissions ne sont pas accordées)
        // Ne pas bloquer l'authentification pour cela
      }

      return Right(userModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Erreur de connexion Google';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Un compte existe déjà avec cet email mais avec un autre fournisseur';
          break;
        case 'invalid-credential':
          message = 'Les identifiants fournis sont invalides';
          break;
        case 'operation-not-allowed':
          message = 'La connexion Google n\'est pas activée';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé';
          break;
        default:
          message = e.message ?? message;
      }
      return Left(AuthenticationFailure(message));
    } catch (e) {
      return Left(AuthenticationFailure('Erreur: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> completeGoogleUserInfo({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  }) async {
    try {
      // Récupérer l'utilisateur actuel
      final userDoc = await FirebaseService.getDocument(
        FirestoreConstants.usersCollection,
        userId,
      );

      if (userDoc == null || !userDoc.exists) {
        return Left(ServerFailure('Utilisateur non trouvé'));
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentUserModel = UserModel.fromJson(userData);

      // Mettre à jour avec les nouvelles informations
      // IMPORTANT: Cette méthode préserve le rôle existant de l'utilisateur
      // Comme l'inscription crée toujours un assistantLeader, personne ne peut devenir admin via cette méthode
      // Les admins sont automatiquement approuvés, les autres sont en pending
      final updatedUser = User(
        id: userId,
        email: currentUserModel.email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        role: currentUserModel.role, // Préserve le rôle existant (toujours assistantLeader pour les nouvelles inscriptions)
        status: currentUserModel.role == UserRole.admin 
            ? UserStatus.approved  // Les admins sont automatiquement approuvés
            : UserStatus.pending,  // Les autres sont en attente de validation
        unitId: unitId,
        branchId: branchId,
        photoUrl: currentUserModel.photoUrl,
      );

      final updatedUserModel = UserModel.fromEntity(updatedUser);
      await FirebaseService.updateData(
        FirestoreConstants.usersCollection,
        userId,
        updatedUserModel.toJson(),
      );

      _currentUser = updatedUser;

      // Enregistrer le token FCM pour cet utilisateur (uniquement sur mobile/desktop)
      try {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await NotificationService.updateTokenWithUserId(fcmToken, userId);
        }
      } catch (e) {
        // Ignorer les erreurs FCM (peut échouer sur le web ou si les permissions ne sont pas accordées)
        // Ne pas bloquer l'authentification pour cela
      }

      return Right(updatedUser);
    } catch (e) {
      return Left(ServerFailure('Failed to complete user info: ${e.toString()}'));
    }
  }
}

