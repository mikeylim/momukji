class FilterOptions {
  final List<String> cuisineTypes;
  final List<String> foodTypes;
  final List<String> dietaryRestrictions;
  final String? priceRange;
  final double? maxDistance; // in kilometers
  final bool openNow;
  final MealType? mealType;
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

enum MealType {
  breakfast,
  brunch,
  lunch,
  dinner,
  lateNight,
  snack;

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

enum DiningStyle {
  dineIn,
  takeout,
  delivery,
  driveThrough,
  any;

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

class PriceRanges {
  static const List<String> all = [
    '\$',
    '\$\$',
    '\$\$\$',
    '\$\$\$\$',
  ];

  static const Map<String, String> descriptions = {
    '\$': 'Budget-friendly',
    '\$\$': 'Moderate',
    '\$\$\$': 'Upscale',
    '\$\$\$\$': 'Fine Dining',
  };
}
