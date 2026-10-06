import 'package:visioncare_app/models/medicines_time.dart';

class Medicines {
  String? id;
  String? name;
  String? description;
  List<String>? sideEffects;
  List<String>? warnings;
  List<String>? instructions;
  String? userId;
  String? expirationDate;
  List<MedicinesTime>? notifications;
  
  Medicines({
    this.id,
    this.name,
    this.description,
    this.sideEffects,
    this.warnings,
    this.instructions,
    this.userId,
    this.notifications,
    this.expirationDate,
  });

  Medicines copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? sideEffects,
    List<String>? warnings,
    List<String>? instructions,
    String? userId,
    List<MedicinesTime>? notifications,
    String? expirationDate,
  }) {
    return Medicines(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sideEffects: sideEffects ?? this.sideEffects,
      warnings: warnings ?? this.warnings,
      instructions: instructions ?? this.instructions,
      userId: userId ?? this.userId,
      notifications: notifications ?? this.notifications,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  factory Medicines.fromMap(Map<String, dynamic> map) {
    return Medicines(
      id: map['id'] as String?,
      name: map['nombre'] as String?,
      description: map['description'] as String?,
      sideEffects: List<String>.from(map['sideEffects']?.split(',') ?? []),
      warnings: List<String>.from(map['warnings']?.split(',') ?? []),
      instructions: List<String>.from(map['instruccions']?.split(',') ?? []),
      userId: map['userId'] as String?,
      notifications: (map['medicineTimes'] as List<dynamic>?)
          ?.map((item) => MedicinesTime.fromMap(item as Map<String, dynamic>))
          .toList(),
      expirationDate: map['expirationDate'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'description': description,
      'sideEffects': sideEffects?.join(','), 
      'warnings': warnings?.join(','),
      'userId': userId,
      'instruccions': instructions?.join(','),
      'expirationDate': expirationDate,
    };
  }
}