import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/models/medicines.dart';

final medicineProvider = StateNotifierProvider<MedicineNotifier, Medicines?>((ref) {
  return MedicineNotifier();
});

class MedicineNotifier extends StateNotifier<Medicines?> {
  MedicineNotifier() : super(null);

  Medicines? get medicine => state;

  void setMedicine(Medicines newMedicine) {
    state = newMedicine;
  }

  void updateInstructions(List<String> instructions) {
    if (state != null) {
      state = state!.copyWith(instructions: instructions);
    }
  }

  void updateSideEffects(List<String> sideEffects) {
    if (state != null) {
      state = state!.copyWith(sideEffects: sideEffects);
    }
  }

  void updateWarnings(List<String> warnings) {
    if (state != null) {
      state = state!.copyWith(warnings: warnings);
    }
  }

  void updateUserId(String userId) {
    if (state != null) {
      state = state!.copyWith(userId: userId);
    }
  }

  String? getName(){
    return state?.name;
  }

  void clearMedicine() {
    state = null;
  }
}