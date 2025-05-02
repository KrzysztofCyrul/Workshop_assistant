bool isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}

class Validators {
    static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }
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

    static String? Function(String?) phone() {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Telefon jest wymagany';
      } else if (value.length > 20) {
        return 'Telefon nie może mieć więcej niż 20 znaków';
      }
      return null;
    };
  }

  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final year = int.tryParse(value);
    if (year == null) {
      return 'Wprowadź poprawny rok';
    }
    
    if (year < 1900 || year > DateTime.now().year) {
      return 'Wprowadź rok między 1900 a ${DateTime.now().year}';
    }
    
    return null;
  }

  static String? validateVin(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length != 17) {
      return 'VIN powinien mieć 17 znaków';
    }
    
    return null;
  }

  static String? validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final mileage = int.tryParse(value);
    if (mileage == null || mileage < 0) {
      return 'Wprowadź poprawny przebieg';
    }
    
    return null;
  }
}