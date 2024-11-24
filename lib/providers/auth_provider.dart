import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<void> login({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;
      _status = AuthStatus.authenticated;
    } on FirebaseAuthException catch (error) {
      _status = AuthStatus.unauthenticated;
      switch (error.code) {
        case 'invalid-email':
          _error = 'Alamat email tidak valid';
          break;
        case 'user-disabled':
          _error = 'Akun telah dinonaktifkan';
          break;
        case 'user-not-found':
          _error = 'Akun tidak ditemukan';
          break;
        case 'wrong-password':
          _error = 'Password salah';
          break;
        case 'INVALID_LOGIN_CREDENTIALS':
          _error = 'Email atau password salah';
          break;
        default:
          _error = 'Terjadi kesalahan ketika login';
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = 'Terjadi kesalahan ketika login';
    }

    notifyListeners();
  }

  Future<void> register({
  required String email,
  required String password,
  String? name,
}) async {
  try {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    if (!email.contains('@') || !email.contains('.')) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Alamat email tidak valid',
      );
    }

    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password minimal 6 karakter',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );


    if (name != null && name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
    }

    _user = credential.user;
    _status = AuthStatus.authenticated;
  } on FirebaseAuthException catch (error) {
    _status = AuthStatus.unauthenticated;
    switch (error.code) {
      case 'email-already-in-use':
        _error = 'Alamat email sudah terdaftar';
        break;
      case 'invalid-email':
        _error = 'Alamat email tidak valid';
        break;
      case 'operation-not-allowed':
        _error = 'Registrasi tidak diizinkan';
        break;
      case 'weak-password':
        _error = 'Password minimal 6 karakter';
        break;
      default:
        _error = 'Terjadi kesalahan saat registrasi';
    }
  } catch (e) {
    _status = AuthStatus.unauthenticated;
    _error = 'Terjadi kesalahan saat registrasi';
  }

  notifyListeners();
}

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat logout';
    }
    notifyListeners();
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      bool exists = signInMethods.isNotEmpty;
      
      _status = AuthStatus.unauthenticated;
      if (!exists) {
        _error = 'Email tidak terdaftar';
      }
      
      notifyListeners();
      return exists;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = 'Terjadi kesalahan saat memeriksa email';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(
        email: email,
      );

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = switch (e.code) {
        'invalid-email' => 'Format email tidak valid',
        'user-not-found' => 'Email tidak terdaftar',
        'too-many-requests' => 'Terlalu banyak permintaan. Coba lagi nanti',
        _ => 'Terjadi kesalahan. Silakan coba lagi'
      };
      notifyListeners();
      return false;

    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = 'Terjadi kesalahan yang tidak diketahui';
      notifyListeners();
      return false;
    }
  }
}
