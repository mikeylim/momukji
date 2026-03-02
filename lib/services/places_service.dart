import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant.dart';

/// Service for interacting with Google Places API.
///
/// Provides methods to search for restaurants, get place details,
/// and retrieve photos. Uses singleton pattern for shared instance.
class PlacesService {
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService() => _instance;
  PlacesService._internal();

  /// API key loaded from environment variables.
  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Base URL for Google Places API endpoints.
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Searches for restaurants near a given location.
  ///
  /// [latitude] and [longitude] specify the search center.
  /// [radius] is the search radius in meters (default 1500m).
  /// [keyword] optionally filters results by text search.
  ///
  /// Returns a list of [Restaurant] objects matching the criteria.
  /// Throws an exception if the API key is not configured or the request fails.
  Future<List<Restaurant>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1500,
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

  /// Searches for restaurants using a text query.
  ///
  /// More flexible than nearby search, allowing natural language queries
  /// like "Italian restaurant" or "sushi near downtown".
  ///
  /// [query] is the search text.
  /// [latitude], [longitude], and [radius] optionally bias results to an area.
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

    // Add location bias if coordinates provided
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

  /// Fetches detailed information about a specific place.
  ///
  /// Returns more data than search results, including phone number,
  /// website, opening hours, and photos.
  ///
  /// [placeId] is the unique Google Places identifier.
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

  /// Generates a URL for a place photo.
  ///
  /// [photoReference] is the reference string from Places API.
  /// [maxWidth] limits the image width (default 400px).
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  /// Searches for nearby restaurants and returns raw JSON data.
  ///
  /// Used by the AI recommendation system to analyze restaurant data
  /// before creating [Restaurant] objects with AI-generated reasons.
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
