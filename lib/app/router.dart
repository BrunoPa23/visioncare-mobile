import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/presentation/home/view/home_page.dart';
import 'package:visioncare_app/presentation/information/view/information_page.dart';
import 'package:visioncare_app/presentation/information/view/instructions_page.dart';
import 'package:visioncare_app/presentation/information/view/search_page.dart';
import 'package:visioncare_app/presentation/information/view/side_effects_page.dart';
import 'package:visioncare_app/presentation/information/view/warnings_page.dart';
import 'package:visioncare_app/presentation/login/view/login_page.dart';
import 'package:visioncare_app/presentation/map/view/map_page.dart';
import 'package:visioncare_app/presentation/medicines/view/medicines_page.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_days.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_food.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_iterations.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_time.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_type.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_created.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_input_medication.dart';
import 'package:visioncare_app/presentation/register/view/register_page.dart';
import 'package:visioncare_app/presentation/scanning/view/results_page.dart';
import 'package:visioncare_app/presentation/scanning/view/scanning_page.dart';
import 'package:visioncare_app/presentation/settings/view/speech_settings_page.dart';
import 'package:visioncare_app/presentation/settings/view/text_settings_page.dart';
import 'package:visioncare_app/presentation/startup/startup_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const StartupPage(),
    ),
    GoRoute(
      path: '/textSettings',
      builder: (context, state) => const TextSettingsPage(),
    ),
    GoRoute(
      path: '/speechSettings',
      builder: (context, state) => const SpeechSettingsPage(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const HomePage(),
        transitionDuration: const Duration(seconds: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/medicines',
      builder: (context, state) => const MedicinesPage(),
    ),
    GoRoute(
      path: '/notifications/choose-days',
      builder: (context, state) => const NotificationsChooseDays(),
    ),
    GoRoute(
      path: '/notifications/choose-food',
      builder: (context, state) => const NotificationsChooseFood(),
    ),
    GoRoute(
      path: '/notifications/choose-iterations',
      builder: (context, state) => const NotificationsChooseIterations(),
    ),
    GoRoute(
      path: '/notifications/choose-time',
      builder: (context, state) => const NotificationsChooseTime(),
    ),
    GoRoute(
      path: '/notifications/choose-type',
      builder: (context, state) => const NotificationsChooseType(),
    ),
    GoRoute(
      path: '/notifications/input-medication',
      builder: (context, state) => const NotificationsInputMedication(),
    ),
    GoRoute(
      path: '/notifications/created',
      builder: (context, state) => const NotificationsCreated(),
    ),
    GoRoute(
      path: '/scanning',
      builder: (context, state) => const ScanningPage(), 
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapPage()
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage()
    ),
    GoRoute(
      path: '/information',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final searchQuery = args?['searchQuery'] as String? ?? '';
        return InformationPage(searchQuery: searchQuery);  
      },
    ),
    GoRoute(
      path: '/side-effects',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final searchQuery = args?['searchQuery'] as String? ?? '';
        return SideEffectsPage(searchQuery: searchQuery);
      }, 
    ),
    GoRoute(
      path: '/warnings',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final searchQuery = args?['searchQuery'] as String? ?? '';
        return WarningsPage(searchQuery: searchQuery);
      },
    ),
    GoRoute(
      path: '/instructions',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final searchQuery = args?['searchQuery'] as String? ?? '';
        return InstructionsPage(searchQuery: searchQuery);
      },
    ),
    GoRoute(
      path: '/vision-results',
      builder: (context, state) {
        final imageFile = state.extra as XFile;
        return ResultsPage(imageFile: imageFile);
      },
    )
  ],
);