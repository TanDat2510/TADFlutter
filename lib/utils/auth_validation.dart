import 'package:flutter/material.dart';

class AuthValidation {
  // Validation cho Email
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return "Email không được để trống";
    }

    // Loại bỏ khoảng trắng
    email = email.trim();

    // Kiểm tra format email
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(email)) {
      return "Email không đúng định dạng";
    }

    // Kiểm tra độ dài
    if (email.length > 254) {
      return "Email quá dài";
    }

    return null; // Hợp lệ
  }

  // Validation cho Password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Mật khẩu không được để trống";
    }

    if (password.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }

    if (password.length > 128) {
      return "Mật khẩu quá dài (tối đa 128 ký tự)";
    }

    // Kiểm tra có ít nhất 1 chữ số
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Mật khẩu phải có ít nhất 1 chữ số";
    }

    // Kiểm tra có ít nhất 1 chữ cái
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      return "Mật khẩu phải có ít nhất 1 chữ cái";
    }

    return null; // Hợp lệ
  }

  // Validation cho Confirm Password
  static String? validateConfirmPassword(String? confirmPassword, String? originalPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return "Vui lòng xác nhận mật khẩu";
    }

    if (confirmPassword != originalPassword) {
      return "Mật khẩu xác nhận không khớp";
    }

    return null; // Hợp lệ
  }

  // Validation cho Display Name (cho register)
  static String? validateDisplayName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return "Tên hiển thị không được để trống";
    }

    displayName = displayName.trim();

    if (displayName.length < 2) {
      return "Tên hiển thị phải có ít nhất 2 ký tự";
    }

    if (displayName.length > 50) {
      return "Tên hiển thị quá dài (tối đa 50 ký tự)";
    }

    // Kiểm tra ký tự đặc biệt (chỉ cho phép chữ cái, số, khoảng trắng, dấu gạch ngang, gạch dưới)
    if (!RegExp(r'^[a-zA-ZÀ-ỹ0-9\s\-_]+$').hasMatch(displayName)) {
      return "Tên hiển thị chỉ được chứa chữ cái, số, khoảng trắng, dấu gạch ngang và gạch dưới";
    }

    return null; // Hợp lệ
  }

  // Validation tổng thể cho Login Form
  static ValidationResult validateLoginForm({
    required String email,
    required String password,
  }) {
    List<String> errors = [];

    // Validate email
    final emailError = validateEmail(email);
    if (emailError != null) {
      errors.add(emailError);
    }

    // Validate password (đơn giản hơn cho login)
    if (password.isEmpty) {
      errors.add("Mật khẩu không được để trống");
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      firstError: errors.isNotEmpty ? errors.first : null,
    );
  }

  // Validation tổng thể cho Register Form
  static ValidationResult validateRegisterForm({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
    String? phoneNumber,
    String? age,
    bool? termsAccepted,
    bool requireDisplayName = false,
    bool requirePhoneNumber = false,
    bool requireAge = false,
    bool requireTermsAcceptance = true,
  }) {
    List<String> errors = [];

    // Validate display name
    if (requireDisplayName || (displayName != null && displayName.isNotEmpty)) {
      final nameError = validateDisplayName(displayName);
      if (nameError != null) {
        errors.add(nameError);
      }
    }

    // Validate email
    final emailError = validateEmail(email);
    if (emailError != null) {
      errors.add(emailError);
    }

    // Validate password
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      errors.add(passwordError);
    }

    // Validate confirm password
    final confirmPasswordError = validateConfirmPassword(confirmPassword, password);
    if (confirmPasswordError != null) {
      errors.add(confirmPasswordError);
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      firstError: errors.isNotEmpty ? errors.first : null,
    );
  }

  // Utility methods
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }

  static bool isStrongPassword(String password) {
    // Mật khẩu mạnh: ít nhất 8 ký tự, có chữ hoa, chữ thường, số và ký tự đặc biệt
    if (password.length < 8) return false;

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters;
  }

  // Đánh giá độ mạnh của mật khẩu
  static PasswordStrength getPasswordStrength(String password) {
    if (password.length < 6) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Độ dài
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Có chữ hoa
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;

    // Có chữ thường
    if (RegExp(r'[a-z]').hasMatch(password)) score++;

    // Có số
    if (RegExp(r'[0-9]').hasMatch(password)) score++;

    // Có ký tự đặc biệt
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

// Class để trả về kết quả validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final String? firstError;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    this.firstError,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors)';
  }
}

// Enum cho độ mạnh mật khẩu
enum PasswordStrength {
  weak,
  medium,
  strong,
}

// Extension để có thể dễ dàng hiển thị
extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.weak:
        return 'Yếu';
      case PasswordStrength.medium:
        return 'Trung bình';
      case PasswordStrength.strong:
        return 'Mạnh';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }
}