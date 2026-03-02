import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../models/chat_message.dart';
import '../models/filter_options.dart';
import '../services/gemini_service.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class AppProvider extends ChangeNotifier {
  // Services
  final GeminiService _geminiService = GeminiService();
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  // State
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

  // Getters
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

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load saved preferences
      await _loadPreferences();

      // Initialize Gemini
      await _geminiService.initialize();

      // Get current location
      _currentPosition = await _locationService.getCurrentLocation();
      _currentAddress = _locationService.currentAddress;

      // Add welcome message
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

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'en';
    _locale = Locale(langCode);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }

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

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isLoading = true;

    // Add user message
    _chatMessages.add(ChatMessage.user(message));
    notifyListeners();

    // Add loading message
    final loadingMessage = ChatMessage.loading();
    _chatMessages.add(loadingMessage);
    notifyListeners();

    try {
      if (_currentPosition == null) {
        // Just chat without restaurant search
        final response = await _geminiService.chat(message, filters: _filterOptions);
        _chatMessages.removeLast();
        _chatMessages.add(ChatMessage.assistant(response));
      } else {
        // Build keyword from filters
        String? keyword;
        if (_filterOptions.cuisineTypes.isNotEmpty) {
          keyword = _filterOptions.cuisineTypes.join(' ');
        }

        // Get nearby restaurants with filters applied
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
          // Get AI recommendation
          final recommendation = await _geminiService.getRestaurantRecommendation(
            userQuery: message,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            nearbyRestaurants: nearbyRestaurants,
            filters: _filterOptions,
          );

          // Match recommended restaurants
          final recommendedNames = (recommendation['recommendations'] as List?)
              ?.map((r) => r['name'] as String)
              .toList() ?? [];

          final matchedRestaurants = <Restaurant>[];
          for (final name in recommendedNames) {
            final match = nearbyRestaurants.firstWhere(
              (r) => (r['name'] as String).toLowerCase().contains(name.toLowerCase()) ||
                     name.toLowerCase().contains((r['name'] as String).toLowerCase()),
              orElse: () => <String, dynamic>{},
            );
            if (match.isNotEmpty) {
              final aiReason = (recommendation['recommendations'] as List?)
                  ?.firstWhere((r) => r['name'] == name, orElse: () => {})['reason'];
              match['ai_reason'] = aiReason;
              matchedRestaurants.add(Restaurant.fromJson(match));
            }
          }

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

  void updateFilters(FilterOptions filters) {
    _filterOptions = filters;
    notifyListeners();
  }

  void clearFilters() {
    _filterOptions = FilterOptions();
    notifyListeners();
  }

  void selectRestaurant(Restaurant? restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
  }

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

  void clearChat() {
    _chatMessages.clear();
    _geminiService.resetChat();
    _chatMessages.add(ChatMessage.system(
      _locale.languageCode == 'ko'
          ? '안녕하세요! 모먹지입니다. 오늘 뭐 먹을지 고민이세요? 말씀해 주세요!'
          : "Hi! I'm Momukji, your food concierge. What are you in the mood to eat today?",
    ));
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
