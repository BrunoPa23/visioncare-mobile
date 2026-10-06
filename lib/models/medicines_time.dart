class MedicinesTime {
  String? id;
  String day;
  int typeRemember; // 0: specific_time, 1: foods, 2: interval
  int? foods;
  String? specificTime; // Format: "HH:mm:ss"
  int? interval;
  String medicineId;

  MedicinesTime({
    this.id,
    required this.day,
    required this.typeRemember,
    this.foods,
    this.specificTime,
    this.interval,
    required this.medicineId,
  });

  factory MedicinesTime.fromMap(Map<String, dynamic> map) {
    return MedicinesTime(
      id: map['id'] ?? '',
      day: map['day'] ?? '',
      typeRemember: map['typeRemember'] ?? 0,
      foods: map['foods'],
      specificTime: map['specificTime'],
      interval: map['interval'],
      medicineId: map['medicineId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'day': day,
      'typeRemember': typeRemember,
      'foods': foods,
      'specificTime': specificTime,
      'interval': interval,
    };
  }
}
