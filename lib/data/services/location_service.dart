import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Position? _lastPosition;
  String? _lastLocationName;

  Position? get lastPosition => _lastPosition;
  String? get lastLocationName => _lastLocationName;

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    _lastPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return _lastPosition;
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.subLocality?.isNotEmpty == true) place.subLocality!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.administrativeArea?.isNotEmpty == true)
            place.administrativeArea!,
        ];
        _lastLocationName = parts.join(', ');
        return _lastLocationName!;
      }
    } catch (_) {
      // Geocoding failed, return coordinates
    }
    _lastLocationName = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    return _lastLocationName!;
  }
}
