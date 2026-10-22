import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapService {
  // Cliente aparte del ApiClient: Google Places no usa el token de VisionCare
  final Dio _dio;

  MapService([Dio? dio]) : _dio = dio ?? Dio();

  Future<LocationData> getUserLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location service disabled');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission denied');
      }
    }

    return await location.getLocation();
  }

  Future<List<Map<String, dynamic>>> buscarFarmacias({
    required double lat,
    required double lng,
    required String apiKey,
  }) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '$lat,$lng',
          'radius': 2000,
          'type': 'pharmacy',
          'keyword': 'farmacia',
          'key': apiKey,
        },
      );
      final results = response.data['results'] as List<dynamic>;
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Error al obtener lugares: ${e.response?.statusCode ?? e.type}');
    }
  }

  Set<Marker> crearMarcadores(List<Map<String, dynamic>> farmacias) {
    return farmacias.map((f) {
      final location = f['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];
      final name = f['name'];
      final placeId = f['place_id'];

      return Marker(
        markerId: MarkerId(placeId),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: name),
      );
    }).toSet();
  }
}