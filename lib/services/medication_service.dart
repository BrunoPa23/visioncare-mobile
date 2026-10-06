import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/models/medicines_time.dart';
import 'package:visioncare_app/core/config/app_config.dart';

class MedicationService {
  //${AppConfig.apiBaseUrl}/api/medicine
  final String baseUrl = "${AppConfig.apiBaseUrl}/api";

  Future<String> createMedication(Medicines medicine) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/medicine"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(medicine.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint("Medication created successfully: ${responseData['id']}");

        return responseData['id'].toString();
      } else {
        debugPrint("Failed to create medication: ${response.statusCode} - ${response.body}");
        return "Error";
      }
      
    } catch (e) {
      debugPrint("Exception creating medication: $e");
      return "Error";
    }
  }

  Future<String> createNotification(MedicinesTime medicinesTime) async {
    debugPrint("Creating notification with data: ${medicinesTime.toJson()}");
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/medicine-time"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(medicinesTime.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint("Notification created successfully: ${responseData['id']}");

        return responseData['id'].toString();
      } else {
        debugPrint("Failed to create notification: ${response.statusCode} - ${response.body}");
        return "Error";
      }
      
    } catch (e) {
      debugPrint("Exception creating notification: $e");
      return "Error";
    }
  }

  Future<List<Medicines>> getAllMedicationById() async {
    try {
      var _secureStorage = FlutterSecureStorage();
      final id = await _secureStorage.read(key: 'UserId');
      final response = await http.get(Uri.parse("$baseUrl/medicine/user/$id"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<Medicines> medications = responseData.map((item) => Medicines.fromMap(item)).toList();
        //Print medications and content
        for (var medication in medications) {
          debugPrint("Medication: ${medication.name}, ID: ${medication.id}, descripcion: ${medication.description} ,Notifications: ${medication.notifications?.map((e) => e.toJson()).toList()}");
        }
        return medications;
      } else {
        debugPrint("Failed to fetch medications: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Exception fetching medications: $e");
      return [];
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/medicine/$id"));
      if (response.statusCode == 204) {
        debugPrint("Medication deleted successfully: $id");
        return true;
      } else {
        debugPrint("Failed to delete medication: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception deleting medication: $e");
      return false;
    }
  }
}