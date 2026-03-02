/// Data model representing a restaurant from Google Places API.
///
/// Contains all relevant information about a restaurant including
/// location, ratings, pricing, and AI-generated recommendation reasons.
class Restaurant {
  /// Unique identifier from Google Places (place_id).
  final String id;

  /// Display name of the restaurant.
  final String name;

  /// Full formatted address.
  final String address;

  /// Geographic latitude coordinate.
  final double latitude;

  /// Geographic longitude coordinate.
  final double longitude;

  /// Average user rating (1.0 - 5.0 scale).
  final double? rating;

  /// Total number of user reviews.
  final int? userRatingsTotal;

  /// Price level indicator (e.g., "$", "$$", "$$$").
  final String? priceLevel;

  /// List of place types from Google Places API.
  final List<String> types;

  /// URL for the restaurant's photo from Google Places.
  final String? photoUrl;

  /// Whether the restaurant is currently open.
  final bool? isOpen;

  /// Contact phone number.
  final String? phoneNumber;

  /// Restaurant website URL.
  final String? website;

  /// Weekly opening hours text.
  final List<String>? openingHours;

  /// AI-generated explanation for why this restaurant was recommended.
  final String? aiReason;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    this.types = const [],
    this.photoUrl,
    this.isOpen,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.aiReason,
  });

  /// Creates a Restaurant from Google Places API JSON response.
  ///
  /// Handles both nearby search and text search response formats,
  /// extracting location from nested geometry object.
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['place_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      latitude: json['geometry']?['location']?['lat']?.toDouble() ??
                json['latitude']?.toDouble() ?? 0.0,
      longitude: json['geometry']?['location']?['lng']?.toDouble() ??
                 json['longitude']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      priceLevel: _parsePriceLevel(json['price_level']),
      types: List<String>.from(json['types'] ?? []),
      photoUrl: json['photo_url'],
      isOpen: json['opening_hours']?['open_now'],
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      openingHours: json['opening_hours']?['weekday_text'] != null
          ? List<String>.from(json['opening_hours']['weekday_text'])
          : null,
      aiReason: json['ai_reason'],
    );
  }

  /// Converts numeric price level (0-4) to dollar sign representation.
  static String? _parsePriceLevel(dynamic level) {
    if (level == null) return null;
    int priceInt = level is int ? level : int.tryParse(level.toString()) ?? 0;
    return '\$' * (priceInt > 0 ? priceInt : 1);
  }

  /// Converts this restaurant to a JSON map for serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'price_level': priceLevel,
      'types': types,
      'photo_url': photoUrl,
      'is_open': isOpen,
      'phone_number': phoneNumber,
      'website': website,
      'opening_hours': openingHours,
      'ai_reason': aiReason,
    };
  }

  /// Returns a formatted string of restaurant types for display.
  ///
  /// Filters out generic types like "point_of_interest" and "establishment",
  /// replaces underscores with spaces, and limits to 3 types.
  String get typesDisplay {
    return types
        .where((t) => !t.contains('point_of_interest') && !t.contains('establishment'))
        .map((t) => t.replaceAll('_', ' '))
        .take(3)
        .join(', ');
  }
}
