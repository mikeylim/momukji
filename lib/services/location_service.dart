import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for handling device location and geocoding.
///
/// Manages location permissions, retrieves current position,
/// and converts between coordinates and addresses.
/// Uses singleton pattern for shared instance.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Cached current position from last location fetch.
  Position? _currentPosition;

  /// Cached human-readable address for current position.
  String? _currentAddress;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  /// Checks and requests location permissions.
  ///
  /// Returns true if location services are enabled and permission is granted.
  /// Automatically requests permission if currently denied (but not permanently).
  Future<bool> checkPermission() async {
    // Check if location services are enabled on the device
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if not yet granted
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    // User has permanently denied permission - must change in settings
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Gets the device's current location.
  ///
  /// Checks permissions first, then retrieves high-accuracy position.
  /// Also performs reverse geocoding to get a human-readable address.
  ///
  /// Returns null if permission is denied or an error occurs.
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // Minimum distance (m) before update
        ),
      );

      // Get address from coordinates
      await _getAddressFromCoordinates();

      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Reverse geocodes current position to get a street address.
  ///
  /// Updates [_currentAddress] with a formatted address string
  /// combining street, locality, and administrative area.
  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Build address from available components
        _currentAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      _currentAddress = null;
    }
  }

  /// Converts an address string to geographic coordinates.
  ///
  /// [address] is the street address or place name to geocode.
  /// Returns a Position object if successful, null otherwise.
  Future<Position?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return Position(
          latitude: locations[0].latitude,
          longitude: locations[0].longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      return null;
    }
  }

  /// Calculates the distance between two geographic points.
  ///
  /// Returns distance in kilometers using the Haversine formula.
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Geolocator returns meters, convert to kilometers
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }
}
