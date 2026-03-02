/// Contains all filter criteria for restaurant searches.
///
/// Used to refine AI recommendations and Places API queries
/// based on user preferences like cuisine type, price, and dietary needs.
class FilterOptions {
  /// Selected cuisine types by country/region (e.g., Korean, Italian).
  final List<String> cuisineTypes;

  /// Selected food categories (e.g., Pizza, Sushi, BBQ).
  final List<String> foodTypes;

  /// Dietary restrictions to consider (e.g., Vegetarian, Gluten-Free).
  final List<String> dietaryRestrictions;

  /// Price range filter (e.g., "$", "$$", "$$$").
  final String? priceRange;

  /// Maximum search radius in kilometers.
  final double? maxDistance;

  /// Whether to only show currently open restaurants.
  final bool openNow;

  /// Type of meal being sought (breakfast, lunch, dinner, etc.).
  final MealType? mealType;

  /// Preferred dining style (dine-in, takeout, delivery).
  final DiningStyle? diningStyle;

  FilterOptions({
    this.cuisineTypes = const [],
    this.foodTypes = const [],
    this.dietaryRestrictions = const [],
    this.priceRange,
    this.maxDistance,
    this.openNow = false,
    this.mealType,
    this.diningStyle,
  });

  /// Creates a copy with optionally modified fields.
  FilterOptions copyWith({
    List<String>? cuisineTypes,
    List<String>? foodTypes,
    List<String>? dietaryRestrictions,
    String? priceRange,
    double? maxDistance,
    bool? openNow,
    MealType? mealType,
    DiningStyle? diningStyle,
  }) {
    return FilterOptions(
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      foodTypes: foodTypes ?? this.foodTypes,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      priceRange: priceRange ?? this.priceRange,
      maxDistance: maxDistance ?? this.maxDistance,
      openNow: openNow ?? this.openNow,
      mealType: mealType ?? this.mealType,
      diningStyle: diningStyle ?? this.diningStyle,
    );
  }

  /// Returns true if any filters are currently active.
  bool get hasFilters {
    return cuisineTypes.isNotEmpty ||
        foodTypes.isNotEmpty ||
        dietaryRestrictions.isNotEmpty ||
        priceRange != null ||
        maxDistance != null ||
        openNow ||
        mealType != null ||
        diningStyle != null;
  }

  /// Converts active filters to a human-readable string for AI prompts.
  ///
  /// Used to enhance user queries with filter context when
  /// requesting recommendations from Gemini.
  String toPromptString() {
    List<String> parts = [];

    if (cuisineTypes.isNotEmpty) {
      parts.add('Cuisine preferences: ${cuisineTypes.join(", ")}');
    }
    if (foodTypes.isNotEmpty) {
      parts.add('Food types: ${foodTypes.join(", ")}');
    }
    if (dietaryRestrictions.isNotEmpty) {
      parts.add('Dietary restrictions: ${dietaryRestrictions.join(", ")}');
    }
    if (priceRange != null) {
      parts.add('Price range: $priceRange');
    }
    if (maxDistance != null) {
      parts.add('Within ${maxDistance}km');
    }
    if (openNow) {
      parts.add('Must be open now');
    }
    if (mealType != null) {
      parts.add('Meal type: ${mealType!.displayName}');
    }
    if (diningStyle != null) {
      parts.add('Dining style: ${diningStyle!.displayName}');
    }

    return parts.join('. ');
  }

  void clear() {
    // Returns a new empty FilterOptions
  }
}

/// Types of meals for time-based filtering.
enum MealType {
  breakfast,
  brunch,
  lunch,
  dinner,
  lateNight,
  snack;

  /// Returns a user-friendly display name for the meal type.
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.brunch:
        return 'Brunch';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.lateNight:
        return 'Late Night';
      case MealType.snack:
        return 'Snack';
    }
  }
}

/// Dining style preferences for how to consume the meal.
enum DiningStyle {
  dineIn,
  takeout,
  delivery,
  driveThrough,
  any;

  /// Returns a user-friendly display name for the dining style.
  String get displayName {
    switch (this) {
      case DiningStyle.dineIn:
        return 'Dine In';
      case DiningStyle.takeout:
        return 'Takeout';
      case DiningStyle.delivery:
        return 'Delivery';
      case DiningStyle.driveThrough:
        return 'Drive Through';
      case DiningStyle.any:
        return 'Any';
    }
  }
}

/// Available cuisine types organized by country/region.
class CuisineTypes {
  static const List<String> all = [
    'Korean',
    'Japanese',
    'Chinese',
    'Thai',
    'Vietnamese',
    'Indian',
    'Italian',
    'Mexican',
    'American',
    'French',
    'Mediterranean',
    'Greek',
    'Middle Eastern',
    'Brazilian',
    'Spanish',
    'German',
    'British',
    'Canadian',
    'African',
    'Caribbean',
    'Fusion',
  ];
}

/// Available food types organized by dish/category.
class FoodTypes {
  static const List<String> all = [
    'Pizza',
    'Burgers',
    'Sushi',
    'Ramen',
    'BBQ',
    'Seafood',
    'Steakhouse',
    'Fried Chicken',
    'Tacos',
    'Noodles',
    'Soup',
    'Salad',
    'Sandwich',
    'Fast Food',
    'Dessert',
    'Cafe',
    'Bakery',
  ];
}

/// Common dietary restrictions and preferences.
class DietaryRestrictions {
  static const List<String> all = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
    'Nut-Free',
    'Dairy-Free',
    'Shellfish-Free',
    'Egg-Free',
    'Soy-Free',
    'Low-Carb',
    'Keto',
    'Paleo',
  ];
}

/// Price range options with corresponding descriptions.
class PriceRanges {
  /// All available price range symbols.
  static const List<String> all = [
    '\$',
    '\$\$',
    '\$\$\$',
    '\$\$\$\$',
  ];

  /// Human-readable descriptions for each price level.
  static const Map<String, String> descriptions = {
    '\$': 'Budget-friendly',
    '\$\$': 'Moderate',
    '\$\$\$': 'Upscale',
    '\$\$\$\$': 'Fine Dining',
  };
}
