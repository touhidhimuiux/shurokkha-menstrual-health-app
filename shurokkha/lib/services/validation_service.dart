/// Email and Password Validation Service
/// 
/// Provides reusable validation methods for email and password
/// across the entire application.

class ValidationService {
  /// Validates email format (Gmail only)
  /// 
  /// Requirements:
  /// - Must contain @ symbol
  /// - Must end with @gmail.com
  /// - Can contain: letters, numbers, dots, underscores, hyphens
  /// 
  /// Examples:
  /// - user@gmail.com ✓
  /// - john.doe@gmail.com ✓
  /// - user_name123@gmail.com ✓
  /// - user@yahoo.com ✗ (not Gmail)
  /// - user (missing @gmail.com) ✗
  static bool isValidGmailEmail(String email) {
    if (email.isEmpty) return false;
    
    final gmailRegex = RegExp(
      r'^[a-zA-Z0-9._%-]+@gmail\.com$',
      caseSensitive: false,
    );
    
    return gmailRegex.hasMatch(email.trim());
  }

  /// Validates password requirements
  /// 
  /// Requirements:
  /// - Minimum 6 characters
  /// - No maximum length (but reasonable for UX)
  /// 
  /// Examples:
  /// - "123456" ✓ (exactly 6)
  /// - "MyPassword123" ✓ (13 characters)
  /// - "12345" ✗ (only 5)
  /// - "" ✗ (empty)
  static bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  /// Validates full name (not empty)
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  /// Validates if passwords match
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword && password.isNotEmpty;
  }

  /// Sanitize email (lowercase and trim)
  static String sanitizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  /// Sanitize name (trim whitespace)
  static String sanitizeName(String name) {
    return name.trim();
  }

  /// Get validation error message for email
  static String getEmailErrorMessage(String email) {
    if (email.isEmpty) {
      return 'Please enter your Gmail address';
    }
    if (!email.contains('@')) {
      return 'Email must contain @ symbol';
    }
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      return 'Please use a Gmail address (example@gmail.com)';
    }
    if (!isValidGmailEmail(email)) {
      return 'Please enter a valid Gmail address format';
    }
    return 'Email is valid';
  }

  /// Get validation error message for password
  static String getPasswordErrorMessage(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return 'Password is valid';
  }

  /// Get validation error message for name
  static String getNameErrorMessage(String name) {
    if (name.isEmpty) {
      return 'Please enter your full name';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return 'Name is valid';
  }

  /// Validate all signup fields
  /// Returns error message if any field is invalid, empty string if all valid
  static String validateSignupForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreeToTerms,
  }) {
    // Check name
    if (!isValidName(name)) {
      return getNameErrorMessage(name);
    }

    // Check email
    if (!isValidGmailEmail(email)) {
      return getEmailErrorMessage(email);
    }

    // Check password
    if (!isValidPassword(password)) {
      return getPasswordErrorMessage(password);
    }

    // Check passwords match
    if (!passwordsMatch(password, confirmPassword)) {
      return 'Passwords do not match';
    }

    // Check terms agreement
    if (!agreeToTerms) {
      return 'Please agree to the terms and conditions';
    }

    return ''; // All valid
  }

  /// Validate all login fields
  /// Returns error message if any field is invalid, empty string if all valid
  static String validateLoginForm({
    required String email,
    required String password,
  }) {
    // Check email
    if (!isValidGmailEmail(email)) {
      return getEmailErrorMessage(email);
    }

    // Check password
    if (password.isEmpty) {
      return 'Please enter your password';
    }

    return ''; // All valid
  }

  /// Validate password reset email
  /// Returns error message if invalid, empty string if valid
  static String validatePasswordResetEmail(String email) {
    if (!isValidGmailEmail(email)) {
      return getEmailErrorMessage(email);
    }
    return ''; // Valid
  }
}
