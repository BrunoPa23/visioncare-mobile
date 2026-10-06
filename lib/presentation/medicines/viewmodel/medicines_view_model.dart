import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/services/medication_service.dart';

final getAllMedicinesProvider = FutureProvider<List<Medicines>>((ref) async {
  final medicinesService = MedicationService();
  debugPrint("🔴 RECOGIENDO MEDICINAS");
  final response = await medicinesService.getAllMedicationById();
  return response;
});

//A Boton para eliminar en el view model
final deletingMedicinesProvider = StateProvider<Map<String, AsyncValue<void>>>((ref) => {});

Future<void> deleteMedicine(WidgetRef ref, String medicineId) async {
  final map = ref.read(deletingMedicinesProvider);
  // Marcar como cargando
  ref.read(deletingMedicinesProvider.notifier).state = {
    ...map,
    medicineId: const AsyncValue.loading(),
  };

  try {
    final medicinesService = MedicationService();
    await medicinesService.deleteMedication(medicineId);
    // Borrar del estado de loading
    final newMap = Map<String, AsyncValue<void>>.from(ref.read(deletingMedicinesProvider));
    newMap.remove(medicineId);
    ref.read(deletingMedicinesProvider.notifier).state = newMap;

    // Refrescar lista
    ref.refresh(getAllMedicinesProvider);
  } catch (e, st) {
    // Marcar error
    ref.read(deletingMedicinesProvider.notifier).state = {
      ...ref.read(deletingMedicinesProvider),
      medicineId: AsyncValue.error(e, st),
    };
  }
}
