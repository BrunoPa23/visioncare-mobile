import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';


class MapService {
  Future<LocationData> getUserLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception('Location service disabled');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
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
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=2000'
      '&type=pharmacy'
      '&keyword=farmacia'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener lugares: ${response.body}');
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