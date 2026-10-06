import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/services/auth_service.dart';

final startupViewmodelProvider = ChangeNotifierProvider<StartupViewmodel>((ref) {
  return StartupViewmodel();
});

class StartupViewmodel extends ChangeNotifier{
  final AuthService _authService = AuthService();
  
  Future<void> checkAuth(BuildContext context) async{
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'AuthToken');

    if (token == null) {
      context.go('/login');
      return;
    } 

    bool isTokenExpired = await _authService.checkTokenExpired();


    if (isTokenExpired) {
      if(await _authService.refreshToken()){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint("🔴 Token Refresh as it was expired");
          context.go('/home');
          return;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint("🔴 Token Refresh unsuccessful, redirecting to login");
          context.go('/login');
          return;
        });
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("🔴 Token is valid, redirecting to home");
        context.go('/home');
        return;
      });
    }
  }
}