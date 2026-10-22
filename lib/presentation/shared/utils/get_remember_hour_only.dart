import 'package:visioncare_app/models/medicines_time.dart';

String getRememberHourOnly(MedicinesTime notif) {
  switch (notif.typeRemember) {
    case 0:
      return notif.specificTime?.substring(0, 5) ?? 'Hora específica';
    case 1:
      return _foodIndexToLabel(notif.foods ?? 0);
    case 2:
      return _intervalIndexToLabel(notif.interval ?? 0);
    default:
      return 'Desconocido';
  }
}

String _foodIndexToLabel(int index) {
  switch (index) {
    case 0: return 'Desayuno';
    case 1: return 'Almuerzo';
    case 2: return 'Cena';
    case 3: return 'Sin hora';
    default: return 'Comida';
  }
}

String _intervalIndexToLabel(int index) {
  switch (index) {
    case 0: return 'Cada 4 horas';
    case 1: return 'Cada 6 horas';
    case 2: return 'Cada 8 horas';
    case 3: return 'Cada 12 horas';
    case 4: return 'Una vez al día';
    default: return 'Intervalo';
  }
}
