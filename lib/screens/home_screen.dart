import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/menu_catalog.dart';
import '../providers/app_provider.dart';
import '../widgets/chat_widget.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/location_bar.dart';
import '../widgets/menu_picker_sheet.dart';
import '../widgets/shake_detector.dart';
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '모먹지',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  provider.setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
                tooltip: Theme.of(context).brightness == Brightness.dark
                    ? 'Use light theme'
                    : 'Use dark theme',
              ),
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
                  children: [const ChatWidget(), const QuickSelectWidget()],
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
                label: provider.locale.languageCode == 'ko'
                    ? '빠른 선택'
                    : 'Quick Pick',
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
                color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.primary,
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
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
              children: activeFilters
                  .map(
                    (filter) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
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

/// Quick selection widget for choosing restaurants based on mood and cuisine.
///
/// Provides an interactive interface with:
/// - Mood selection chips (hungry, light meal, special occasion, etc.)
/// - Cuisine type selection chips with icons
/// - Cuisine and dish wheel with a 216-option menu catalog
/// - "Shake to Surprise" feature using device accelerometer
/// - Direct Places searches for picker results and AI recommendations
class QuickSelectWidget extends StatefulWidget {
  const QuickSelectWidget({super.key});

  @override
  State<QuickSelectWidget> createState() => _QuickSelectWidgetState();
}

class _QuickSelectWidgetState extends State<QuickSelectWidget> {
  final ScrollController _scrollController = ScrollController();

  /// Currently selected mood (null if none selected).
  String? _selectedMood;

  /// Set of selected cuisine types (supports multiple selection).
  final Set<String> _selectedCuisines = {};

  /// Last menu selection made through the three-way picker.
  MenuSelection? _menuSelection;

  /// Available mood options: (English name, Korean name, description for AI query).
  static const List<(String, String, String)> _moods = [
    ('Hungry', '배고파요', 'I\'m really hungry, need something filling'),
    ('Light Meal', '가볍게', 'Looking for something light'),
    ('Special', '특별한 날', 'Special occasion restaurant'),
    ('Solo', '혼밥', 'Good place to eat alone'),
    ('Group', '모임', 'Good for a group'),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Opens the detailed filter bottom sheet for advanced filtering options.
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

  /// Opens the menu picker and searches for the selected cuisine or dish.
  Future<void> _showSpinWheel(
    BuildContext context,
    AppProvider provider,
    bool isKorean,
  ) async {
    final choice = await showModalBottomSheet<MenuSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) => MenuPickerSheet(isKorean: isKorean),
    );
    if (!mounted || choice == null) return;

    setState(() {
      _menuSelection = choice;
      _selectedMood = null;
      _selectedCuisines
        ..clear()
        ..add(choice.cuisine.name);
    });
    await provider.searchRestaurants(choice.searchQuery);
    if (mounted && _scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  /// Builds and sends a search query based on current selections.
  ///
  /// Combines selected mood and cuisine types into a natural language
  /// query that is sent to the AI for restaurant recommendations.
  /// If no selections are made, sends a generic recommendation request.
  void _findRestaurants(AppProvider provider, bool isKorean) {
    if (_menuSelection != null) {
      provider.searchRestaurants(_menuSelection!.searchQuery);
      return;
    }

    final List<String> queryParts = [];

    // Add mood description to query (uses detailed English description or Korean name)
    if (_selectedMood != null) {
      final mood = _moods.firstWhere((m) => m.$1 == _selectedMood);
      queryParts.add(isKorean ? mood.$2 : mood.$3);
    }

    // Add selected cuisine types to query
    if (_selectedCuisines.isNotEmpty) {
      final cuisineNames = _selectedCuisines
          .map((c) {
            final cuisine = MenuCatalog.cuisines.firstWhere(
              (cu) => cu.name == c,
            );
            return cuisine.label(isKorean);
          })
          .join(', ');
      queryParts.add(isKorean ? '$cuisineNames 음식' : '$cuisineNames food');
    }

    // Build final query - defaults to generic recommendation if nothing selected
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

  /// Resets all mood and cuisine selections to their initial state.
  void _clearSelections() {
    setState(() {
      _selectedMood = null;
      _selectedCuisines.clear();
      _menuSelection = null;
    });
  }

  /// Handles device shake gesture for random cuisine selection.
  ///
  /// Picks a random cuisine from the available list, updates the selection,
  /// and shows a snackbar with an option to search for restaurants.
  /// Does nothing if a search is already in progress.
  void _onShake(BuildContext context, AppProvider provider, bool isKorean) {
    // Prevent triggering while already loading
    if (provider.isLoading) return;

    // Pick a random cuisine from the list
    final random = Random();
    final randomCuisine =
        MenuCatalog.cuisines[random.nextInt(MenuCatalog.cuisines.length)];
    final cuisineName = randomCuisine.label(isKorean);

    // Update selection
    setState(() {
      _selectedCuisines.clear();
      _selectedCuisines.add(randomCuisine.name);
      _menuSelection = null;
    });

    // Show feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shuffle, color: Colors.white),
            const SizedBox(width: 12),
            Text(isKorean ? '🎲 $cuisineName 선택됨!' : '🎲 $cuisineName picked!'),
          ],
        ),
        action: SnackBarAction(
          label: isKorean ? '맛집 찾기' : 'Find',
          onPressed: () => _findRestaurants(provider, isKorean),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isKorean = provider.locale.languageCode == 'ko';
        final hasSelections =
            _selectedMood != null || _selectedCuisines.isNotEmpty;

        return ShakeDetector(
          onShake: () => _onShake(context, provider, isKorean),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shake hint card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.vibration,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isKorean ? '흔들어서 랜덤 선택!' : 'Shake for random pick!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    onTap: provider.isLoading
                        ? null
                        : () => _showSpinWheel(context, provider, isKorean),
                    leading: const Icon(Icons.casino),
                    title: Text(
                      isKorean ? '메뉴 돌리기 또는 고르기' : 'Spin or pick a menu',
                    ),
                    subtitle: Text(
                      isKorean
                          ? '요리 종류나 메뉴를 정하고 식당 찾기'
                          : 'Choose a cuisine or dish, then find restaurants',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 20),

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
                const SizedBox(height: 16),

                if (_menuSelection != null) ...[
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _menuSelection!.dish == null
                                ? Icons.restaurant
                                : Icons.restaurant_menu,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _menuSelection!.label,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (_menuSelection!.dish != null)
                                  Text(
                                    isKorean
                                        ? '식당 메뉴에 있는지 방문 전에 확인해 주세요.'
                                        : 'Check the restaurant menu before visiting.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(isKorean ? '맛집 찾기' : 'Find Restaurants'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Loading Section
                if (provider.isLoading) _buildLoadingSection(context, isKorean),

                if (!provider.isLoading &&
                    _menuSelection != null &&
                    provider.error != null) ...[
                  Text(
                    provider.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (!provider.isLoading &&
                    _menuSelection != null &&
                    provider.error == null &&
                    provider.restaurants.isEmpty) ...[
                  Text(
                    isKorean
                        ? '근처에서 일치하는 식당을 찾지 못했어요. 다시 돌려보세요.'
                        : 'No matching restaurants nearby. Try another spin.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],

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
          ),
        );
      },
    );
  }

  /// Builds the mood selection chips row.
  ///
  /// Only one mood can be selected at a time (single selection).
  /// Tapping an already-selected chip deselects it.
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
              _menuSelection = null;
            });
          },
        );
      }).toList(),
    );
  }

  /// Builds the cuisine selection chips with icons.
  ///
  /// Supports multiple selection - users can select multiple cuisines.
  /// Each chip displays a cuisine-appropriate icon.
  Widget _buildCuisineChips(bool isKorean) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MenuCatalog.cuisines.map((cuisine) {
        final isSelected = _selectedCuisines.contains(cuisine.name);
        return FilterChip(
          avatar: Icon(cuisine.icon, size: 18),
          label: Text(cuisine.label(isKorean)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _menuSelection = null;
              if (selected) {
                _selectedCuisines.add(cuisine.name);
              } else {
                _selectedCuisines.remove(cuisine.name);
              }
            });
          },
        );
      }).toList(),
    );
  }

  /// Builds the loading indicator section shown while AI searches.
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
            _menuSelection == null
                ? (isKorean
                      ? 'AI가 맛집을 찾고 있어요...'
                      : 'AI is finding restaurants...')
                : (isKorean
                      ? '근처 식당을 찾고 있어요...'
                      : 'Finding nearby restaurants...'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKorean ? '잠시만 기다려주세요' : 'Please wait a moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
