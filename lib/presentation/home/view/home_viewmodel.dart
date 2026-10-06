import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visioncare_app/presentation/medicines/viewmodel/medicines_view_model.dart';
import 'package:visioncare_app/services/auth_service.dart';

final homeViewmodelProvider = ChangeNotifierProvider<HomeViewmodel>((ref) {
  return HomeViewmodel();
});

class HomeViewmodel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<void> signOut(BuildContext context, ref) async {
    final result = await _authService.signOut();
    if (result) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
        ref.invalidate(getAllMedicinesProvider); 
      });
    }
    notifyListeners();
  }
}