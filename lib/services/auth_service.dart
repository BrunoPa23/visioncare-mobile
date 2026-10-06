import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:visioncare_app/models/user.dart';
import 'package:visioncare_app/core/config/app_config.dart';

class AuthService {
  final String apiUrl;
  final Dio _dio;
  final CookieJar _cookieJar;
  final FlutterSecureStorage _secureStorage;

  AuthService({this.apiUrl = '${AppConfig.apiBaseUrl}/vc/v1'})
      : _dio = Dio(),
        _cookieJar = CookieJar(),
        _secureStorage = FlutterSecureStorage() {
    _dio.interceptors.add(CookieManager(_cookieJar)); 
  }

  Future<bool> checkTokenExpired() async {
    var authToken = await _secureStorage.read(key: 'AuthToken');
    var refreshToken = await _secureStorage.read(key: 'RefreshToken');
    bool isExpired = JwtDecoder.isExpired(authToken!);
    debugPrint('🔴 Token $authToken expired: ${JwtDecoder.getExpirationDate(authToken)}, is expired? $isExpired, duration: ${JwtDecoder.getRemainingTime(authToken)}');
    return isExpired;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$apiUrl/authentication/sign-in',
        options: Options(
          headers: {
            'Accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        await _saveCookies();
        await getProfile();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error during sign-in: $e');
      return false;
    }
  }

  Future<void> _saveCookies() async {
    List<Cookie> cookies = await _cookieJar.loadForRequest(Uri.parse('$apiUrl'));
    
    for (var cookie in cookies) {
      await _secureStorage.write(key: cookie.name, value: cookie.value);
    }
  }

  Future<void> _loadCookies() async {
    List<Cookie> cookies = [];
    
    var authToken = await _secureStorage.read(key: 'AuthToken');
    var refreshToken = await _secureStorage.read(key: 'RefreshToken');
    
    if (authToken != null) cookies.add(Cookie('AuthToken', authToken));
    if (refreshToken != null) cookies.add(Cookie('RefreshToken', refreshToken));

    _cookieJar.saveFromResponse(Uri.parse('$apiUrl'), cookies);
  }

  Future<bool> isUserLoggedIn() async {
    _loadCookies();
    final response = await _dio.get('$apiUrl/auth-user/me');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getProfile() async {
    await _loadCookies();
    try {
      final response = await _dio.get('$apiUrl/auth-user/me');
      if (response.statusCode == 200) {
        final userData = response.data;

        final userId = userData['id'] as String?;

        await _secureStorage.write(key: 'UserId', value: userId!);

        // Leer para corroborar
        final storedUserId = await _secureStorage.read(key: 'UserId');

        if (storedUserId != null && storedUserId == userId) {
          debugPrint('✅ UserId guardado correctamente en Secure Storage: $storedUserId');
        } else {
          debugPrint('❌ Error al guardar el UserId en Secure Storage');
        }

      } else {
        throw Exception('Failed to fetch profile');
      }
      
    } catch (e) {
      throw Exception('Error while fetching profile: $e');
    }
  }

  Future<bool> refreshToken() async {
    await _loadCookies();
    try {
      final response = await _dio.post(
        '$apiUrl/authentication/refresh-token', 
        options: Options(
          headers: {'Accept': '*/*'},
        ),
      );

      if (response.statusCode == 200) {
        _saveCookies();
        return true;

      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> signOut() async {
    await _loadCookies();
    await refreshToken();

    try {
      final response = await _dio.post(
        '$apiUrl/authentication/sign-out',
        options: Options(
          headers: {'Accept': '*/*'},
        ),
      );

      if (response.statusCode == 200) {
        await _secureStorage.delete(key: 'AuthToken');
        await _secureStorage.delete(key: 'RefreshToken');
        _cookieJar.deleteAll(); 

        return true;
      } else {
      
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(User user) async {
    try {
      final response = await _dio.post(
        '$apiUrl/authentication/sign-up',
        options: Options(
          headers: {
            'Accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode(user.toJson()),
      );

      debugPrint('🔵 Sign-up response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final result = await login(user.email!, user.password!);
        return result;
      } else {
        return false;
      }
    } catch (e) {
      print('Error during sign-up: $e');
      return false;
    }
  }
}
