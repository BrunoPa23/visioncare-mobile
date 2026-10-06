import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/presentation/map/viewmodel/MapViewModel.dart';
import 'package:visioncare_app/presentation/shared/widgets/loading/app_loading_indicator.dart';
import 'package:visioncare_app/presentation/shared/widgets/text/app_title_text.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: AppLoadingIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    if (state.userLocation == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: Text('Ubicación no disponible')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: FittedBox(child: const AppTitleText('FARMACIAS')), 
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: state.userLocation!,
          zoom: 14,
          
        ),
        markers: state.markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}