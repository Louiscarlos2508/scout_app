import 'package:flutter/foundation.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/branch_repository.dart';

/// Provider pour la gestion de l'état des branches.
class BranchProvider with ChangeNotifier {
  final BranchRepository repository;

  BranchProvider({required this.repository});

  List<Branch> _branches = [];
  bool _isLoading = false;
  String? _error;

  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Implémenter les méthodes de chargement des branches
}

