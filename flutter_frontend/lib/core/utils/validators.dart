bool isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email jest wymagany';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Nieprawidłowy format email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Hasło jest wymagane';
    if (value.length < 8) return 'Hasło musi mieć co najmniej 8 znaków';
    return null;
  }

  static String? requiredField(String? value, String fieldName) {
    return value?.isEmpty ?? true ? '$fieldName jest wymagany' : null;
  }
}