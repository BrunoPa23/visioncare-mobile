import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visioncare_app/presentation/map/model/MapViewState.dart';
import 'package:visioncare_app/services/map_service.dart';

final mapViewModelProvider =
    StateNotifierProvider<MapViewModel, MapViewState>((ref) {
  return MapViewModel(MapService());
});

class MapViewModel extends StateNotifier<MapViewState> {
  final MapService _mapService;

  MapViewModel(this._mapService) : super(MapViewState.initial()) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final location = await _mapService.getUserLocation();
      final latLng = LatLng(location.latitude!, location.longitude!);
      debugPrint("🔴 LATITUD: ${latLng.latitude}");

      final farmacias = await _mapService.buscarFarmacias(
        lat: latLng.latitude,
        lng: latLng.longitude,
        apiKey: state.apiKey,
      );

      debugPrint("🔴 FARMACIAS: ${farmacias.length}");

      final markers = _mapService.crearMarcadores(farmacias);

      state = state.copyWith(
        userLocation: latLng,
        markers: markers,
        isLoading: false,
      );
    } catch (e) {

      debugPrint("🔴 ERROR AL CARGAR DATOS: $e");
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}