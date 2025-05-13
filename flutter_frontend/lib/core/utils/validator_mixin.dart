mixin ValidatorMixin {
  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    return null;
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName musi być liczbą';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    final numberError = validateNumber(value, fieldName);
    if (numberError != null) {
      return numberError;
    }
    if (double.parse(value!) <= 0) {
      return '$fieldName musi być większe od zera';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email nie może być pusty';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Nieprawidłowy format email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // Phone can be empty
    final phoneRegex = RegExp(r'^\+?[\d\s-]{9,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Nieprawidłowy format numeru telefonu';
    }
    return null;
  }
}
