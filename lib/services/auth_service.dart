import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    final response = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
    });

    if (response['success']) {
      await ApiService.saveToken(response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['success']) {
      await ApiService.saveToken(response['data']['token']);
    }

    return response;
  }

  static Future<User?> getMe() async {
    try {
      final response = await ApiService.get('/me');
      if (response['success']) {
        return User.fromJson(response['data']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (e) {
      // ignore
    }
    await ApiService.removeToken();
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final response = await ApiService.put('/profile', {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    });

    return response;
  }
}
