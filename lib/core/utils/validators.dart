/// Validateurs pour les formulaires.
class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    // Format burkinabé : 8 chiffres (ex: 70 12 34 56, 76 12 34 56)
    // Pas besoin de code pays (+226)
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-]'), '');
    final phoneRegex = RegExp(r'^[0-9]{8}$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Format invalide (8 chiffres, ex: 70 12 34 56)';
    }
    return null;
  }

  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'La date est requise';
    }
    if (value.isAfter(DateTime.now())) {
      return 'La date ne peut pas être dans le futur';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }
}

