class ValidationService {
  // RFC 5322 compliant email regex
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  // Name regex: 2-50 chars, letters and spaces only
  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s]{2,50}$");

  // Phone regex: 10 digits (Indian format as requested)
  static final RegExp _phoneRegex = RegExp(r"^[0-9]{10}$");

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    if (!_nameRegex.hasMatch(name.trim())) {
      return 'Name must be 2-50 characters (letters only)';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(phone.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Returns strength score 0-1
  static double getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    double score = 0.0;
    if (password.length >= 8) score += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) score += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.2;
    
    return score;
  }

  static String? validateResourceTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title is required';
    }
    if (title.length < 5) {
      return 'Title must be at least 5 characters';
    }
    if (title.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String sanitizeInput(String input) {
    // Basic sanitization to prevent XSS/Injection
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }
}
