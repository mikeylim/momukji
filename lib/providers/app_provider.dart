import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../models/chat_message.dart';
import '../models/filter_options.dart';
import '../services/gemini_service.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

/// Main application state provider using ChangeNotifier pattern.
///
/// Manages all app-wide state including:
/// - User location and address
/// - Chat messages and AI responses
/// - Restaurant search results
/// - Filter preferences
/// - Language/locale settings
///
/// Acts as the central coordinator between services and UI.
class AppProvider extends ChangeNotifier {
  // Services
  final GeminiService _geminiService = GeminiService();
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  // State variables
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  Position? _currentPosition;
  String? _currentAddress;
  List<Restaurant> _restaurants = [];
  final List<ChatMessage> _chatMessages = [];
  FilterOptions _filterOptions = FilterOptions();
  Restaurant? _selectedRestaurant;
  Locale _locale = const Locale('en');

  // Public getters for read-only access to state
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  List<Restaurant> get restaurants => _restaurants;
  List<ChatMessage> get chatMessages => _chatMessages;
  FilterOptions get filterOptions => _filterOptions;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  Locale get locale => _locale;

  /// Initializes the app provider on startup.
  ///
  /// Loads saved preferences, initializes Gemini AI,
  /// fetches user location, and adds welcome message.
  /// Safe to call multiple times - subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load saved language preference
      await _loadPreferences();

      // Initialize AI service
      await _geminiService.initialize();

      // Get user's current location
      _currentPosition = await _locationService.getCurrentLocation();
      _currentAddress = _locationService.currentAddress;

      // Add localized welcome message
      _chatMessages.add(ChatMessage.system(
        _locale.languageCode == 'ko'
            ? '안녕하세요! 모먹지입니다. 오늘 뭐 먹을지 고민이세요? 말씀해 주세요!'
            : "Hi! I'm Momukji, your food concierge. What are you in the mood to eat today?",
      ));

      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads saved user preferences from local storage.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'en';
    _locale = Locale(langCode);
  }

  /// Changes the app language and persists the setting.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }

  /// Refreshes the user's current location.
  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentLocation();
      _currentAddress = _locationService.currentAddress;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Geocodes an address and sets it as the current location.
  ///
  /// [address] is the street address or place name to search for.
  Future<void> searchLocationByAddress(String address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getLocationFromAddress(address);
      if (position != null) {
        _currentPosition = position;
        _currentAddress = address;
      } else {
        _error = 'Could not find location for: $address';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends a message to the AI and gets restaurant recommendations.
  ///
  /// [message] is the user's request (e.g., "I want Korean food").
  ///
  /// Flow:
  /// 1. Add user message to chat
  /// 2. Show loading indicator
  /// 3. If location available, search nearby restaurants
  /// 4. Send restaurant list to AI for analysis
  /// 5. Match AI recommendations with actual places
  /// 6. Add response to chat with recommendations
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isLoading = true;

    // Add user's message to chat
    _chatMessages.add(ChatMessage.user(message));
    notifyListeners();

    // Show loading indicator while processing
    final loadingMessage = ChatMessage.loading();
    _chatMessages.add(loadingMessage);
    notifyListeners();

    try {
      if (_currentPosition == null) {
        // No location - just chat without restaurant search
        final response = await _geminiService.chat(message, filters: _filterOptions);
        _chatMessages.removeLast(); // Remove loading
        _chatMessages.add(ChatMessage.assistant(response));
      } else {
        // Build search keyword from cuisine filters
        String? keyword;
        if (_filterOptions.cuisineTypes.isNotEmpty) {
          keyword = _filterOptions.cuisineTypes.join(' ');
        }

        // Search for nearby restaurants
        final nearbyRestaurants = await _placesService.getNearbyRestaurantsRaw(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          radius: _filterOptions.maxDistance != null
              ? (_filterOptions.maxDistance! * 1000).toInt()
              : 1500,
          keyword: keyword,
        );

        if (nearbyRestaurants.isEmpty) {
          _chatMessages.removeLast();
          _chatMessages.add(ChatMessage.assistant(
            _locale.languageCode == 'ko'
                ? '근처에 레스토랑을 찾을 수 없어요. 다른 위치를 검색해 보세요.'
                : "I couldn't find any restaurants nearby. Try searching in a different location.",
          ));
        } else {
          // Get AI recommendation based on nearby restaurants
          final recommendation = await _geminiService.getRestaurantRecommendation(
            userQuery: message,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            nearbyRestaurants: nearbyRestaurants,
            filters: _filterOptions,
          );

          // Extract recommended restaurant names
          final recommendedNames = (recommendation['recommendations'] as List?)
              ?.map((r) => r['name'] as String)
              .toList() ?? [];

          // Match AI recommendations to actual restaurant data
          final matchedRestaurants = <Restaurant>[];
          for (final name in recommendedNames) {
            final match = nearbyRestaurants.firstWhere(
              (r) => (r['name'] as String).toLowerCase().contains(name.toLowerCase()) ||
                     name.toLowerCase().contains((r['name'] as String).toLowerCase()),
              orElse: () => <String, dynamic>{},
            );
            if (match.isNotEmpty) {
              // Add AI's reason to the restaurant data
              final aiReason = (recommendation['recommendations'] as List?)
                  ?.firstWhere((r) => r['name'] == name, orElse: () => {})['reason'];
              match['ai_reason'] = aiReason;
              matchedRestaurants.add(Restaurant.fromJson(match));
            }
          }

          // Use matched recommendations or fallback to top 5 nearby
          _restaurants = matchedRestaurants.isNotEmpty
              ? matchedRestaurants
              : nearbyRestaurants.take(5).map((r) => Restaurant.fromJson(r)).toList();

          _chatMessages.removeLast();
          _chatMessages.add(ChatMessage.assistant(
            recommendation['message'] ?? 'Here are some recommendations for you!',
            recommendations: _restaurants,
          ));
        }
      }
    } catch (e) {
      _chatMessages.removeLast();
      _chatMessages.add(ChatMessage.assistant(
        _locale.languageCode == 'ko'
            ? '죄송합니다. 오류가 발생했습니다: $e'
            : 'Sorry, an error occurred: $e',
      ));
    } finally {
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Updates the active filter options.
  void updateFilters(FilterOptions filters) {
    _filterOptions = filters;
    notifyListeners();
  }

  /// Resets all filters to default values.
  void clearFilters() {
    _filterOptions = FilterOptions();
    notifyListeners();
  }

  /// Selects a restaurant for detailed view or map focus.
  void selectRestaurant(Restaurant? restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
  }

  /// Searches for restaurants by text query.
  Future<void> searchRestaurants(String query) async {
    if (_currentPosition == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _restaurants = await _placesService.textSearchRestaurants(
        query: query,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears chat history and resets the AI conversation.
  void clearChat() {
    _chatMessages.clear();
    _geminiService.resetChat();
    // Re-add welcome message
    _chatMessages.add(ChatMessage.system(
      _locale.languageCode == 'ko'
          ? '안녕하세요! 모먹지입니다. 오늘 뭐 먹을지 고민이세요? 말씀해 주세요!'
          : "Hi! I'm Momukji, your food concierge. What are you in the mood to eat today?",
    ));
    notifyListeners();
  }

  /// Clears the current error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
