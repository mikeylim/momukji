import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant.dart';

class PlacesService {
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService() => _instance;
  PlacesService._internal();

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<Restaurant>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1500, // meters
    String? keyword,
    String? type,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your_google_maps_api_key_here') {
      throw Exception('GOOGLE_MAPS_API_KEY not configured');
    }

    final params = {
      'location': '$latitude,$longitude',
      'radius': radius.toString(),
      'type': 'restaurant',
      'key': _apiKey,
    };

    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }

    final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((r) => Restaurant.fromJson(r)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  Future<List<Restaurant>> textSearchRestaurants({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 5000,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your_google_maps_api_key_here') {
      throw Exception('GOOGLE_MAPS_API_KEY not configured');
    }

    final params = {
      'query': '$query restaurant',
      'type': 'restaurant',
      'key': _apiKey,
    };

    if (latitude != null && longitude != null) {
      params['location'] = '$latitude,$longitude';
      params['radius'] = radius.toString();
    }

    final uri = Uri.parse('$_baseUrl/textsearch/json').replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((r) => Restaurant.fromJson(r)).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  Future<Restaurant?> getPlaceDetails(String placeId) async {
    if (_apiKey.isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY not configured');
    }

    final params = {
      'place_id': placeId,
      'fields': 'place_id,name,formatted_address,geometry,rating,user_ratings_total,'
          'price_level,types,opening_hours,formatted_phone_number,website,photos',
      'key': _apiKey,
    };

    final uri = Uri.parse('$_baseUrl/details/json').replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];
          // Add photo URL if available
          if (result['photos'] != null && (result['photos'] as List).isNotEmpty) {
            final photoRef = result['photos'][0]['photo_reference'];
            result['photo_url'] = getPhotoUrl(photoRef);
          }
          return Restaurant.fromJson(result);
        } else {
          return null;
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get place details: $e');
    }
  }

  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  Future<List<Map<String, dynamic>>> getNearbyRestaurantsRaw({
    required double latitude,
    required double longitude,
    int radius = 1500,
    String? keyword,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your_google_maps_api_key_here') {
      throw Exception('GOOGLE_MAPS_API_KEY not configured');
    }

    final params = {
      'location': '$latitude,$longitude',
      'radius': radius.toString(),
      'type': 'restaurant',
      'key': _apiKey,
    };

    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }

    final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }
}
