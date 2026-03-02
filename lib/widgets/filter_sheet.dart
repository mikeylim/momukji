import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/filter_options.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late List<String> _selectedCuisines;
  late List<String> _selectedFoodTypes;
  late List<String> _selectedDietary;
  String? _selectedPrice;
  double? _selectedDistance;
  bool _openNow = false;
  MealType? _selectedMealType;
  DiningStyle? _selectedDiningStyle;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final filters = provider.filterOptions;
    _selectedCuisines = List.from(filters.cuisineTypes);
    _selectedFoodTypes = List.from(filters.foodTypes);
    _selectedDietary = List.from(filters.dietaryRestrictions);
    _selectedPrice = filters.priceRange;
    _selectedDistance = filters.maxDistance;
    _openNow = filters.openNow;
    _selectedMealType = filters.mealType;
    _selectedDiningStyle = filters.diningStyle;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isKorean = provider.locale.languageCode == 'ko';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isKorean ? '필터' : 'Filters',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: Text(isKorean ? '초기화' : 'Clear All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Open Now Switch
                SwitchListTile(
                  title: Text(isKorean ? '현재 영업 중' : 'Open Now'),
                  value: _openNow,
                  onChanged: (value) => setState(() => _openNow = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),

                // Meal Type
                _buildSectionTitle(isKorean ? '식사 종류' : 'Meal Type'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealType.values.map((type) {
                    final isSelected = _selectedMealType == type;
                    return FilterChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMealType = selected ? type : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Dining Style
                _buildSectionTitle(isKorean ? '식사 형태' : 'Dining Style'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DiningStyle.values.map((style) {
                    final isSelected = _selectedDiningStyle == style;
                    return FilterChip(
                      label: Text(style.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDiningStyle = selected ? style : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Price Range
                _buildSectionTitle(isKorean ? '가격대' : 'Price Range'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PriceRanges.all.map((price) {
                    final isSelected = _selectedPrice == price;
                    return FilterChip(
                      label: Text(price),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPrice = selected ? price : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Distance
                _buildSectionTitle(isKorean ? '거리' : 'Distance'),
                Slider(
                  value: _selectedDistance ?? 5,
                  min: 0.5,
                  max: 20,
                  divisions: 39,
                  label: '${(_selectedDistance ?? 5).toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() => _selectedDistance = value);
                  },
                ),
                Text(
                  isKorean
                      ? '${(_selectedDistance ?? 5).toStringAsFixed(1)}km 이내'
                      : 'Within ${(_selectedDistance ?? 5).toStringAsFixed(1)}km',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Cuisine Types (by country/region)
                _buildSectionTitle(isKorean ? '국가별 요리' : 'Cuisine Types'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CuisineTypes.all.map((cuisine) {
                    final isSelected = _selectedCuisines.contains(cuisine);
                    return FilterChip(
                      label: Text(cuisine),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCuisines.add(cuisine);
                          } else {
                            _selectedCuisines.remove(cuisine);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Food Types (dishes/categories)
                _buildSectionTitle(isKorean ? '음식 종류' : 'Food Types'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FoodTypes.all.map((food) {
                    final isSelected = _selectedFoodTypes.contains(food);
                    return FilterChip(
                      label: Text(food),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFoodTypes.add(food);
                          } else {
                            _selectedFoodTypes.remove(food);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Dietary Restrictions
                _buildSectionTitle(isKorean ? '식이 제한' : 'Dietary Restrictions'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DietaryRestrictions.all.map((diet) {
                    final isSelected = _selectedDietary.contains(diet);
                    return FilterChip(
                      label: Text(diet),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDietary.add(diet);
                          } else {
                            _selectedDietary.remove(diet);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _applyFilters,
                  child: Text(isKorean ? '적용하기' : 'Apply Filters'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _selectedCuisines.clear();
      _selectedFoodTypes.clear();
      _selectedDietary.clear();
      _selectedPrice = null;
      _selectedDistance = null;
      _openNow = false;
      _selectedMealType = null;
      _selectedDiningStyle = null;
    });
  }

  void _applyFilters() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.updateFilters(FilterOptions(
      cuisineTypes: _selectedCuisines,
      foodTypes: _selectedFoodTypes,
      dietaryRestrictions: _selectedDietary,
      priceRange: _selectedPrice,
      maxDistance: _selectedDistance,
      openNow: _openNow,
      mealType: _selectedMealType,
      diningStyle: _selectedDiningStyle,
    ));
    Navigator.pop(context);
  }
}
