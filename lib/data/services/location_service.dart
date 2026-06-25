import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Position? _lastPosition;
  String? _lastLocationName;
  String? _lastCityName;

  Position? get lastPosition => _lastPosition;
  String? get lastLocationName => _lastLocationName;
  String? get lastCityName => _lastCityName;

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

        // Also extract just the city name
        _lastCityName = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea ?? place.administrativeArea ?? '');

        return _lastLocationName!;
      }
    } catch (_) {
      // Geocoding failed, fallback to a named city instead of coordinates
    }
    _lastLocationName = 'Kota Bandung';
    _lastCityName = 'Kota Bandung';
    return _lastLocationName!;
  }

  /// Returns just the city / locality name (for compact AppBar display).
  Future<String> getCityName(double latitude, double longitude) async {
    if (_lastCityName != null) return _lastCityName!;

    // If we haven't fetched location name yet, do it
    await getLocationName(latitude, longitude);
    return _lastCityName ?? 'Lokasi';
  }
}
