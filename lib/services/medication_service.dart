import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/core/network/token_storage.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/models/medicines_time.dart';

final medicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService(ref.watch(apiClientProvider));
});

class MedicationService {
  final ApiClient _api;
  final FlutterSecureStorage _secureStorage;

  MedicationService(this._api, [this._secureStorage = const FlutterSecureStorage()]);

  Future<String> createMedication(Medicines medicine) async {
    try {
      final response = await _api.post('/api/medicine', data: medicine.toJson());
      debugPrint("Medicamento creado: ${response.data['id']}");
      return response.data['id'].toString();
    } on ApiException catch (e) {
      debugPrint("No se pudo crear el medicamento: ${e.statusCode} ${e.message}");
      return "Error";
    }
  }

  Future<String> createNotification(MedicinesTime medicinesTime) async {
    try {
      final response = await _api.post('/api/medicine-time', data: medicinesTime.toJson());
      debugPrint("Horario creado: ${response.data['id']}");
      return response.data['id'].toString();
    } on ApiException catch (e) {
      debugPrint("No se pudo crear el horario: ${e.statusCode} ${e.message}");
      return "Error";
    }
  }

  Future<List<Medicines>> getAllMedicationById() async {
    try {
      final id = await _secureStorage.read(key: SecureTokenStorage.userIdKey);
      final response = await _api.get('/api/medicine/user/$id');
      final List<dynamic> responseData = response.data;
      return responseData.map((item) => Medicines.fromMap(item)).toList();
    } on ApiException catch (e) {
      debugPrint("No se pudieron obtener los medicamentos: ${e.statusCode} ${e.message}");
      return [];
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      await _api.delete('/api/medicine/$id');
      debugPrint("Medicamento eliminado: $id");
      return true;
    } on ApiException catch (e) {
      debugPrint("No se pudo eliminar el medicamento: ${e.statusCode} ${e.message}");
      return false;
    }
  }
}
