import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as ref;
import 'package:timezone/timezone.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/models/medicines_time.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/medicine_provider.dart';
import 'package:visioncare_app/services/medication_service.dart';
import 'package:visioncare_app/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

final notificationsViewModelProvider = ChangeNotifierProvider<NotificationsViewModel>(
  (ref) => NotificationsViewModel(ref.read(notificationServiceProvider)),
);

enum TypeTimeNotification {
  meals,
  specificTime,
  twoOrMoreTimes,
}

class NotificationsViewModel extends ChangeNotifier {
  TypeTimeNotification? selectedType;
  final NotificationService notificationService;
  final MedicationService medicationService = MedicationService();

  NotificationsViewModel(this.notificationService);

  
  setSelectedType(TypeTimeNotification type) {
    selectedType = type;
    notifyListeners();
  }

  List<String> selectedDays = [];
  List<String> selectedFoods = [];

  // Boolean flags for each day of the week
  bool isMondaySelected = false;
  bool isTuesdaySelected = false;
  bool isWednesdaySelected = false; 
  bool isThursdaySelected = false;
  bool isFridaySelected = false;
  bool isSaturdaySelected = false;
  bool isSundaySelected = false;

  //Boolean flags for each food
  bool isBreakfastSelected = false;
  bool isLunchSelected = false;
  bool isDinnerSelected = false;

  //Boolean flags for each iteration
  bool isEvery4HoursSelected = false;
  bool isEvery6HoursSelected = false;
  bool isEvery8HoursSelected = false;
  bool isEvery12HoursSelected = false;

  TimeOfDay selectedTime = TimeOfDay.now();

  bool? isLoading = false;
  bool? isError = false;

  TextEditingController medicationNameController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();


  void setSelectedTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void toggleDaySelection(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }

    switch (day) {
      case "Lunes":
        isMondaySelected = !isMondaySelected;
        break;
      case "Martes":
        isTuesdaySelected = !isTuesdaySelected;
        break;
      case "Miercoles":
        isWednesdaySelected = !isWednesdaySelected;
        break;
      case "Jueves":
        isThursdaySelected = !isThursdaySelected;
        break;
      case "Viernes":
        isFridaySelected = !isFridaySelected;
        break;
      case "Sabado":
        isSaturdaySelected = !isSaturdaySelected;
        break;
      case "Domingo":
        isSundaySelected = !isSundaySelected;
        break;
    }

    debugPrint("Selected days: $selectedDays");
    notifyListeners();
  }

  void toggleFoodSelection(String food) {
    if (selectedFoods.contains(food)) {
      selectedFoods.remove(food);
    } else {
      selectedFoods.add(food);
    }

    switch (food) {
      case "Desayuno":
        isBreakfastSelected = !isBreakfastSelected;
        break;
      case "Almuerzo":
        isLunchSelected = !isLunchSelected;
        break;
      case "Cena":
        isDinnerSelected = !isDinnerSelected;
        break;
    }

    debugPrint("Selected foods: $selectedFoods");
    notifyListeners();
  }

  void toggleIterationSelection(String iteration) {
    switch (iteration) {
      case "Cada 4 horas":
        isEvery4HoursSelected = !isEvery4HoursSelected;
        if (isEvery4HoursSelected) {
          isEvery6HoursSelected = false;
          isEvery8HoursSelected = false;
          isEvery12HoursSelected = false;
        }
        break;
      case "Cada 6 horas":
        isEvery6HoursSelected = !isEvery6HoursSelected;
        if (isEvery6HoursSelected) {
          isEvery4HoursSelected = false;
          isEvery8HoursSelected = false;
          isEvery12HoursSelected = false;
        }
        break;
      case "Cada 8 horas":
        isEvery8HoursSelected = !isEvery8HoursSelected;
        if (isEvery8HoursSelected) {
          isEvery4HoursSelected = false;
          isEvery6HoursSelected = false;
          isEvery12HoursSelected = false;
        }
        break;
      case "Cada 12 horas":
        isEvery12HoursSelected = !isEvery12HoursSelected;
        if (isEvery12HoursSelected) {
          isEvery4HoursSelected = false;
          isEvery6HoursSelected = false;
          isEvery8HoursSelected = false;
        }
        break;
    }
    notifyListeners();
  }

  void createNotification(BuildContext context, WidgetRef ref) async {


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
      final medicine = ref.read(medicineProvider.notifier);
      late Medicines medicineToCreate;
      var userId = await _secureStorage.read(key: 'UserId');
      debugPrint("User ID: $userId");
      
      medicine.updateUserId(userId!);

      isLoading = true;
      notifyListeners();

      context.pushReplacement('/notifications/created');

      if(medicine.medicine == null) {
        medicineToCreate = await createMedicationModel(userId!);
        debugPrint("Creating medication model: ${medicineToCreate.toJson()}");
      }
      else {
        medicineToCreate = medicine.medicine!;
        debugPrint("Using existing medication model: ${medicineToCreate.toJson()}");
      }

      final medicationId = await medicationService.createMedication(medicineToCreate);

      if (medicationId == "Error") {
        isError = true;
        isLoading = false;
        notifyListeners();
        return;
      }

      final now = DateTime.now();
      final tzNow = tz.TZDateTime.from(now, tz.local);

      List<TZDateTime> notificationTimes = [];
      List<MedicinesTime> notificationsToSend = [];

      // Hora específica
      if (selectedType == TypeTimeNotification.specificTime) {
        for (var day in selectedDays) {
          final weekday = _getWeekdayFromString(day);
          final date = _nextInstanceOfWeekday(weekday, selectedTime);
          notificationTimes.add(date);

          notificationsToSend.add(
            MedicinesTime(
              medicineId: medicationId,
              day: day,
              typeRemember: 0,
              specificTime: "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00",
            ),
          );
        }
      }

      // Por comidas
      else if (selectedType == TypeTimeNotification.meals) {
        Map<String, int> mealHours = {
          'Desayuno': 8,
          'Almuerzo': 13,
          'Cena': 20,
        };

        Map<String, int> foodEnumValues = {
          'Desayuno': 0,
          'Almuerzo': 1,
          'Cena': 2,
        };

        for (var day in selectedDays) {
          final weekday = _getWeekdayFromString(day);

          for (var food in selectedFoods) {
            final hour = mealHours[food] ?? 8;
            final date = _nextInstanceOfWeekday(weekday, TimeOfDay(hour: hour, minute: 0));
            notificationTimes.add(date);

            notificationsToSend.add(
              MedicinesTime(
                medicineId: medicationId,
                day: day,
                typeRemember: 1,
                foods: foodEnumValues[food],
              ),
            );
          }
        }
      }

      // Por intervalo
      else if (selectedType == TypeTimeNotification.twoOrMoreTimes) {
        int intervalHours = isEvery4HoursSelected
            ? 4
            : isEvery6HoursSelected
                ? 6
                : isEvery8HoursSelected
                    ? 8
                    : 12;

        int intervalEnum = _intervalToEnum(intervalHours);

        for (var day in selectedDays) {
          final weekday = _getWeekdayFromString(day);

          for (int i = 0; i < 24; i += intervalHours) {
            final now = tz.TZDateTime.now(tz.local);
            final time = TimeOfDay(hour: (now.hour + i) % 24, minute: 0);
            final date = _nextInstanceOfWeekday(weekday, time);
            notificationTimes.add(date);

            notificationsToSend.add(
              MedicinesTime(
                medicineId: medicationId,
                day: day,
                typeRemember: 2,
                interval: intervalEnum,
              ),
            );
          }
        }
      }

      // Guardar en backend + FlutterLocalNotifications
      for (int i = 0; i < notificationsToSend.length; i++) {
        final n = notificationsToSend[i];
        final backendNotificationId = await medicationService.createNotification(n);

        if (backendNotificationId != "Error") {
          await notificationService.scheduleNotification(
            id: backendNotificationId,
            title: 'No olvides tomar tu medicamento',
            body: 'Debes tomar: ${medicineToCreate.name}',
            scheduledTimeTZ: notificationTimes[i],
          );
        }
      }

      isLoading = false;
      notifyListeners();

      });
  }


  int _getWeekdayFromString(String day) {
  switch (day) {
    case 'Lunes':
      return DateTime.monday;
    case 'Martes':
      return DateTime.tuesday;
    case 'Miercoles':
      return DateTime.wednesday;
    case 'Jueves':
      return DateTime.thursday;
    case 'Viernes':
      return DateTime.friday;
    case 'Sabado':
      return DateTime.saturday;
    case 'Domingo':
      return DateTime.sunday;
    default:
      return DateTime.monday;
  }
}

  TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    final now = TZDateTime.now(local);
    TZDateTime scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Avanza hasta el próximo día deseado
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
  
  int _intervalToEnum(int hours) {
    switch (hours) {
      case 4:
        return 0;
      case 6:
        return 1;
      case 8:
        return 2;
      case 12:
        return 3;
      default:
        return 0;
    }
  }

  void instantNotification()  {
    notificationService.showInstantNotification();
  }

  Future<Medicines> createMedicationModel(String userId) async {
    return Medicines(
      name: medicationNameController.text,
      description: null,
      sideEffects: null,
      warnings: null,
      instructions: null,
      userId: userId
    );
  }

  void resetState(){
    selectedType = null;
    selectedDays.clear();
    selectedFoods.clear();
    isMondaySelected = false;
    isTuesdaySelected = false;
    isWednesdaySelected = false; 
    isThursdaySelected = false;
    isFridaySelected = false;
    isSaturdaySelected = false;
    isSundaySelected = false;
    isBreakfastSelected = false;
    isLunchSelected = false;
    isDinnerSelected = false;
    isEvery4HoursSelected = false;
    isEvery6HoursSelected = false;
    isEvery8HoursSelected = false;
    isEvery12HoursSelected = false;
    selectedTime = TimeOfDay.now();
    medicationNameController.clear();
  }
}
