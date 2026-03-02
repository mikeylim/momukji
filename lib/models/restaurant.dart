class Restaurant {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final String? priceLevel;
  final List<String> types;
  final String? photoUrl;
  final bool? isOpen;
  final String? phoneNumber;
  final String? website;
  final List<String>? openingHours;
  final String? aiReason; // Why AI recommended this

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

  static String? _parsePriceLevel(dynamic level) {
    if (level == null) return null;
    int priceInt = level is int ? level : int.tryParse(level.toString()) ?? 0;
    return '\$' * (priceInt > 0 ? priceInt : 1);
  }

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

  String get typesDisplay {
    return types
        .where((t) => !t.contains('point_of_interest') && !t.contains('establishment'))
        .map((t) => t.replaceAll('_', ' '))
        .take(3)
        .join(', ');
  }
}
