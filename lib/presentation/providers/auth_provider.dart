import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/logout.dart';
import '../../domain/usecases/auth/get_current_user.dart';

/// Provider pour la gestion de l'état d'authentification.
class AuthProvider with ChangeNotifier {
  final Login login;
  final Logout logout;
  final GetCurrentUser getCurrentUser;

  AuthProvider({
    required this.login,
    required this.logout,
    required this.getCurrentUser,
  });

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

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
    final result = await getCurrentUser();
    result.fold(
      (failure) => _error = failure.message,
      (user) => _currentUser = user,
    );
    notifyListeners();
  }
}

