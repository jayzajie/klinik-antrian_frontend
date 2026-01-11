import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    _user = await AuthService.getMe();

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    print('AuthProvider.login called with email: $email');
    try {
      _isLoading = true;
      notifyListeners();

      print('Calling AuthService.login...');
      final response = await AuthService.login(email, password);
      print('AuthService.login response: $response');
      
      if (response['success']) {
        print('Login successful, calling checkAuth...');
        await checkAuth();
        print('Returning null (success)');
        return null;
      } else {
        print('Login failed: ${response['message']}');
        _isLoading = false;
        notifyListeners();
        return response['message'] ?? 'Login gagal';
      }
    } catch (e) {
      print('Login exception caught: $e');
      _isLoading = false;
      notifyListeners();
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Processed error message: $errorMessage');
      
      // Berikan pesan yang lebih user-friendly
      if (errorMessage.contains('Invalid credentials') || 
          errorMessage.contains('Unauthorized')) {
        return 'Email atau password salah';
      } else if (errorMessage.contains('valid email address')) {
        return 'Format email tidak valid';
      } else if (errorMessage.contains('SocketException') || 
                 errorMessage.contains('Failed host lookup')) {
        return 'Tidak dapat terhubung ke server';
      } else if (errorMessage.contains('TimeoutException')) {
        return 'Koneksi timeout, coba lagi';
      }
      
      final result = errorMessage.isEmpty ? 'Terjadi kesalahan, coba lagi' : errorMessage;
      print('Returning error: $result');
      return result;
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      
      if (response['success']) {
        await checkAuth();
        return null;
      } else {
        _isLoading = false;
        notifyListeners();
        return response['message'] ?? 'Registrasi gagal';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Berikan pesan yang lebih user-friendly
      if (errorMessage.contains('email has already been taken')) {
        return 'Email sudah terdaftar';
      } else if (errorMessage.contains('SocketException') || 
                 errorMessage.contains('Failed host lookup')) {
        return 'Tidak dapat terhubung ke server';
      } else if (errorMessage.contains('TimeoutException')) {
        return 'Koneksi timeout, coba lagi';
      }
      
      return errorMessage.isEmpty ? 'Terjadi kesalahan, coba lagi' : errorMessage;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = await AuthService.getMe();
    notifyListeners();
  }
}
