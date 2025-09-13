import 'package:flutter/material.dart';
import 'package:appfirst2025/services/auth_service.dart';
import 'package:appfirst2025/utils/auth_validation.dart'; // Import validation
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  // Form key để validate
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _showOptionalFields = false; // Để toggle hiển thị các field tùy chọn

  // Password strength state
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    // Listen to password changes để update strength indicator
    passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    passwordController.removeListener(_updatePasswordStrength);
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = AuthValidation.getPasswordStrength(passwordController.text);
    });
  }

  Future<void> register() async {
    // 🎯 Sử dụng AuthValidation để kiểm tra form
    final validationResult = AuthValidation.validateRegisterForm(
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      displayName: displayNameController.text.isNotEmpty ? displayNameController.text : null,
      phoneNumber: phoneController.text.isNotEmpty ? phoneController.text : null,
      termsAccepted: _termsAccepted,
      requireDisplayName: true, // Bắt buộc tên hiển thị
      requirePhoneNumber: false, // Phone tùy chọn
      requireTermsAcceptance: true, // Bắt buộc chấp nhận terms
    );

    if (!validationResult.isValid) {
      _showError(validationResult.firstError!);

      // Hiển thị tất cả lỗi nếu có nhiều
      if (validationResult.errors.length > 1) {
        _showAllErrors(validationResult.errors);
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final error = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (error != null) {
        _showError(error);
      } else {
        _showSuccess("Đăng ký thành công! Vui lòng đăng nhập.");

        // Chuyển về LoginPage sau delay ngắn
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print("Register error: $e");
      _showError("Đã xảy ra lỗi, vui lòng thử lại.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAllErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Lỗi đăng ký"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((error) => Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(error)),
              ],
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.music_video, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      "Create Account 🎶",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Display Name Field
                    TextFormField(
                      controller: displayNameController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => AuthValidation.validateDisplayName(value),
                      decoration: InputDecoration(
                        labelText: "Tên hiển thị *",
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => AuthValidation.validateEmail(value),
                      decoration: InputDecoration(
                        labelText: "Email *",
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      enabled: !_isLoading,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => AuthValidation.validatePassword(value),
                      decoration: InputDecoration(
                        labelText: "Mật khẩu *",
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white.withOpacity(0.7)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    // Password Strength Indicator
                    if (passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              "Độ mạnh: ",
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                            ),
                            Text(
                              _passwordStrength.displayName,
                              style: TextStyle(
                                color: _passwordStrength.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _passwordStrength == PasswordStrength.weak ? 0.33
                            : _passwordStrength == PasswordStrength.medium ? 0.66 : 1.0,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(_passwordStrength.color),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextFormField(
                      controller: confirmPasswordController,
                      enabled: !_isLoading,
                      obscureText: _obscureConfirmPassword,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => AuthValidation.validateConfirmPassword(value, passwordController.text),
                      decoration: InputDecoration(
                        labelText: "Xác nhận mật khẩu *",
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.7)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle Optional Fields
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showOptionalFields = !_showOptionalFields;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showOptionalFields ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          Text(
                            _showOptionalFields ? "Ẩn thông tin tùy chọn" : "Thêm thông tin tùy chọn",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Optional Fields
                    if (_showOptionalFields) ...[
                      const SizedBox(height: 10),

                      // Phone Number Field
                      TextFormField(
                        controller: phoneController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Số điện thoại (tùy chọn)",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Terms and Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.deepPurple,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () {
                              setState(() {
                                _termsAccepted = !_termsAccepted;
                              });
                            },
                            child: Text(
                              "Tôi đồng ý với điều khoản và điều kiện sử dụng",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Register Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Đang đăng ký...",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                          : const Text(
                        "Đăng ký",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Login Link
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Đã có tài khoản? Đăng nhập ngay",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}