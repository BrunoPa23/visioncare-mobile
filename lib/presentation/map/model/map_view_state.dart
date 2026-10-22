import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visioncare_app/core/config/app_config.dart';

class MapViewState {
  final LatLng? userLocation;
  final Set<Marker> markers;
  final bool isLoading;
  final String? error;
  final String apiKey;

  MapViewState({
    required this.userLocation,
    required this.markers,
    required this.isLoading,
    required this.apiKey,
    this.error,
  });

  factory MapViewState.initial() => MapViewState(
        userLocation: null,
        markers: {},
        isLoading: true,
        apiKey: AppConfig.googleMapsApiKey,
      );

  MapViewState copyWith({
    LatLng? userLocation,
    Set<Marker>? markers,
    bool? isLoading,
    String? error,
  }) {
    return MapViewState(
      userLocation: userLocation ?? this.userLocation,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      apiKey: this.apiKey,
      error: error,
    );
  }
}