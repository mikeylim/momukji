import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/chat_widget.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/location_bar.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  'Momukji',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '모먹지',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () => _showLanguageDialog(context, provider),
                tooltip: 'Language',
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterSheet(context),
                    tooltip: 'Filters',
                  ),
                  if (provider.filterOptions.hasFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              const LocationBar(),
              if (provider.filterOptions.hasFilters)
                _buildActiveFiltersBar(context, provider),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    const ChatWidget(),
                    const QuickSelectWidget(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: provider.locale.languageCode == 'ko' ? '채팅' : 'Chat',
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(Icons.restaurant_menu),
                label: provider.locale.languageCode == 'ko' ? '빠른 선택' : 'Quick Pick',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language / 언어'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Icon(
                provider.locale.languageCode == 'en'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                provider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('한국어'),
              leading: Icon(
                provider.locale.languageCode == 'ko'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                provider.setLocale(const Locale('ko'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }

  Widget _buildActiveFiltersBar(BuildContext context, AppProvider provider) {
    final isKorean = provider.locale.languageCode == 'ko';
    final filters = provider.filterOptions;

    List<String> activeFilters = [];
    if (filters.cuisineTypes.isNotEmpty) {
      activeFilters.addAll(filters.cuisineTypes.take(2));
      if (filters.cuisineTypes.length > 2) {
        activeFilters.add('+${filters.cuisineTypes.length - 2}');
      }
    }
    if (filters.foodTypes.isNotEmpty) {
      activeFilters.addAll(filters.foodTypes.take(2));
      if (filters.foodTypes.length > 2) {
        activeFilters.add('+${filters.foodTypes.length - 2}');
      }
    }
    if (filters.dietaryRestrictions.isNotEmpty) {
      activeFilters.add(filters.dietaryRestrictions.first);
    }
    if (filters.priceRange != null) {
      activeFilters.add(filters.priceRange!);
    }
    if (filters.openNow) {
      activeFilters.add(isKorean ? '영업중' : 'Open');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: activeFilters.map((filter) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )).toList(),
            ),
          ),
          TextButton(
            onPressed: () => provider.clearFilters(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isKorean ? '초기화' : 'Clear',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickSelectWidget extends StatefulWidget {
  const QuickSelectWidget({super.key});

  @override
  State<QuickSelectWidget> createState() => _QuickSelectWidgetState();
}

class _QuickSelectWidgetState extends State<QuickSelectWidget> {
  String? _selectedMood;
  final Set<String> _selectedCuisines = {};

  static const List<(String, String, String)> _moods = [
    ('Hungry', '배고파요', 'I\'m really hungry, need something filling'),
    ('Light Meal', '가볍게', 'Looking for something light'),
    ('Special', '특별한 날', 'Special occasion restaurant'),
    ('Solo', '혼밥', 'Good place to eat alone'),
    ('Group', '모임', 'Good for a group'),
  ];

  static const List<(String, String, IconData)> _cuisines = [
    ('Korean', '한식', Icons.rice_bowl),
    ('Japanese', '일식', Icons.set_meal),
    ('Chinese', '중식', Icons.ramen_dining),
    ('Italian', '양식', Icons.local_pizza),
    ('Mexican', '멕시칸', Icons.lunch_dining),
    ('Thai', '태국', Icons.soup_kitchen),
    ('Indian', '인도', Icons.restaurant),
    ('Greek', '그리스', Icons.kebab_dining),
    ('Canadian', '캐나다', Icons.local_dining),
    ('Fast Food', '패스트푸드', Icons.fastfood),
    ('Desserts', '디저트', Icons.icecream),
  ];

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }

  void _findRestaurants(AppProvider provider, bool isKorean) {
    final List<String> queryParts = [];

    // Add mood to query
    if (_selectedMood != null) {
      final mood = _moods.firstWhere((m) => m.$1 == _selectedMood);
      queryParts.add(isKorean ? mood.$2 : mood.$3);
    }

    // Add cuisines to query
    if (_selectedCuisines.isNotEmpty) {
      final cuisineNames = _selectedCuisines.map((c) {
        final cuisine = _cuisines.firstWhere((cu) => cu.$1 == c);
        return isKorean ? cuisine.$2 : cuisine.$1;
      }).join(', ');
      queryParts.add(isKorean
          ? '$cuisineNames 음식'
          : '$cuisineNames food');
    }

    // Build final query
    String query;
    if (queryParts.isEmpty) {
      query = isKorean ? '주변 맛집 추천해줘' : 'Recommend nearby restaurants';
    } else {
      query = isKorean
          ? '${queryParts.join(", ")} 추천해줘'
          : 'Recommend ${queryParts.join(", ")}';
    }

    provider.sendMessage(query);
  }

  void _clearSelections() {
    setState(() {
      _selectedMood = null;
      _selectedCuisines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isKorean = provider.locale.languageCode == 'ko';
        final hasSelections = _selectedMood != null || _selectedCuisines.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isKorean ? '오늘 기분은?' : "What's your mood?",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (hasSelections)
                    TextButton(
                      onPressed: _clearSelections,
                      child: Text(isKorean ? '초기화' : 'Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMoodChips(isKorean),
              const SizedBox(height: 24),

              // Cuisine Section
              Text(
                isKorean ? '음식 종류' : 'Cuisine Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildCuisineChips(isKorean),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFilterSheet(context),
                      icon: const Icon(Icons.tune),
                      label: Text(isKorean ? '상세 필터' : 'More Filters'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: provider.isLoading
                          ? null
                          : () => _findRestaurants(provider, isKorean),
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(isKorean ? '맛집 찾기' : 'Find Restaurants'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Loading Section
              if (provider.isLoading)
                _buildLoadingSection(context, isKorean),

              // Results Section
              if (!provider.isLoading && provider.restaurants.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isKorean ? '추천 식당' : 'Recommendations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: Text(isKorean ? '지도 보기' : 'View Map'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...provider.restaurants.map(
                  (restaurant) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RestaurantCard(restaurant: restaurant),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodChips(bool isKorean) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _moods.map((mood) {
        final isSelected = _selectedMood == mood.$1;
        return FilterChip(
          label: Text(isKorean ? mood.$2 : mood.$1),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedMood = selected ? mood.$1 : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCuisineChips(bool isKorean) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _cuisines.map((cuisine) {
        final isSelected = _selectedCuisines.contains(cuisine.$1);
        return FilterChip(
          avatar: Icon(cuisine.$3, size: 18),
          label: Text(isKorean ? cuisine.$2 : cuisine.$1),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCuisines.add(cuisine.$1);
              } else {
                _selectedCuisines.remove(cuisine.$1);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildLoadingSection(BuildContext context, bool isKorean) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitThreeBounce(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
          const SizedBox(height: 24),
          Text(
            isKorean ? 'AI가 맛집을 찾고 있어요...' : 'AI is finding restaurants...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKorean ? '잠시만 기다려주세요' : 'Please wait a moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
