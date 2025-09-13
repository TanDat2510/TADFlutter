import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng ký
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (_) {
      return 'Đã xảy ra lỗi không xác định.';
    }
  }

  // Đăng nhập
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (_) {
      return 'Đã xảy ra lỗi không xác định.';
    }
  }

  // Đăng xuất
  Future<void> logout() async => await _auth.signOut();

  // Getters
  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Private method xử lý lỗi
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản.';
      case 'wrong-password':
        return 'Sai mật khẩu.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng đợi.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập không được cho phép.';
      default:
        return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }
}