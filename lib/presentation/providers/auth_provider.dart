import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../core/errors/failures.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/logout.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/signup.dart';
import '../../domain/usecases/auth/sign_in_with_google.dart';
import '../../domain/usecases/auth/complete_google_user_info.dart';

/// Provider pour la gestion de l'état d'authentification.
class AuthProvider with ChangeNotifier {
  final Login login;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final SignUp signUpUseCase;
  final SignInWithGoogle signInWithGoogleUseCase;
  final CompleteGoogleUserInfo completeGoogleUserInfoUseCase;

  AuthProvider({
    required this.login,
    required this.logout,
    required this.getCurrentUser,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
    required this.completeGoogleUserInfoUseCase,
  });

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  /// Met à jour l'utilisateur actuel (utilisé par les listeners en temps réel).
  void updateCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await login(email, password);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    final result = await logout();
    result.fold(
      (failure) => _error = failure.message,
      (_) => _currentUser = null,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
    final result = await getCurrentUser();
    result.fold(
        (failure) {
          _error = failure.message;
          _currentUser = null;
        },
        (user) {
          _currentUser = user;
          _error = null;
        },
    );
    } catch (e) {
      _error = 'Erreur lors de la vérification de l\'authentification: ${e.toString()}';
      _currentUser = null;
    } finally {
      _isLoading = false;
    notifyListeners();
    }
  }

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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signUpUseCase.call(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      unitId: unitId,
      branchId: branchId,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  Future<Either<Failure, User>> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signInWithGoogleUseCase.call();

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  Future<Either<Failure, User>> completeGoogleUserInfo({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String unitId,
    required String branchId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await completeGoogleUserInfoUseCase.call(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      unitId: unitId,
      branchId: branchId,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }
}

