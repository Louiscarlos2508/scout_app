import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../core/errors/failures.dart';
import '../../../main.dart' as main_app;

/// Provider pour la gestion de l'état des branches.
class BranchProvider with ChangeNotifier {
  final BranchRepository repository;
  StreamSubscription<void>? _syncSubscription;

  BranchProvider({required this.repository}) {
    // Écouter les notifications de synchronisation des branches
    _syncSubscription = main_app.syncService?.branchesSynced.listen((_) {
      // Recharger les branches quand elles sont synchronisées
      loadAllBranches();
    });
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  List<Branch> _branches = [];
  bool _isLoading = false;
  String? _error;

  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge toutes les branches.
  Future<void> loadAllBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await repository.getAllBranches();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (branches) {
        _branches = branches;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Charge les branches d'une unité.
  Future<void> loadBranchesByUnit(String unitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await repository.getBranchesByUnit(unitId);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (branches) {
        _branches = branches;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Récupère une branche par son ID.
  Branch? getBranchById(String id) {
    try {
      return _branches.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}

