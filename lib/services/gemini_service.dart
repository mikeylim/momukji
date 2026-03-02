import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/filter_options.dart';

/// Service for interacting with Google's Gemini AI.
///
/// Handles AI-powered chat conversations and restaurant recommendations.
/// Maintains a chat session for context-aware responses.
/// Uses singleton pattern for shared instance.
class GeminiService {
  /// The Gemini generative model instance.
  late GenerativeModel _model;

  /// Active chat session for maintaining conversation context.
  late ChatSession _chat;

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Initializes the Gemini model with API key and configuration.
  ///
  /// Must be called before any other methods. Safe to call multiple times;
  /// subsequent calls are no-ops if already initialized.
  ///
  /// Throws an exception if the API key is not configured in .env file.
  Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey == 'your_gemini_api_key_here') {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,  // Balanced creativity
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.text(_systemPrompt),
    );

    _chat = _model.startChat(history: []);
    _isInitialized = true;
  }

  /// System prompt defining the AI's personality and behavior.
  static const String _systemPrompt = '''
You are Momukji, a friendly and knowledgeable AI food concierge. Your name means "what should I eat?" in Korean.

Your role is to help users decide what to eat by:
1. Understanding their cravings, preferences, and constraints
2. Recommending specific types of cuisine or dishes
3. Helping them narrow down their options based on mood, dietary needs, occasion, etc.

When the user describes what they want, analyze their request and provide helpful suggestions.
Be conversational, warm, and enthusiastic about food.

When you have enough information to make restaurant recommendations, format your response with:
- A brief friendly message about your recommendations
- The type of cuisine or food you're recommending and why

Keep responses concise but helpful. Ask clarifying questions if the user's request is vague.
''';

  /// Sends a message to the AI and gets a response.
  ///
  /// [userMessage] is the user's input text.
  /// [filters] optionally adds filter context to the message.
  ///
  /// Returns the AI's response text.
  Future<String> chat(String userMessage, {FilterOptions? filters}) async {
    await initialize();

    // Append filter information to message if filters are active
    String enhancedMessage = userMessage;
    if (filters != null && filters.hasFilters) {
      enhancedMessage += '\n\nUser preferences: ${filters.toPromptString()}';
    }

    try {
      final response = await _chat.sendMessage(Content.text(enhancedMessage));
      return response.text ?? 'I apologize, I could not generate a response.';
    } catch (e) {
      throw Exception('Failed to get response from Gemini: $e');
    }
  }

  /// Analyzes nearby restaurants and recommends the best matches.
  ///
  /// [userQuery] is what the user is looking for.
  /// [latitude] and [longitude] are the user's location.
  /// [nearbyRestaurants] is the raw Places API data to analyze.
  /// [filters] optionally adds preference context.
  ///
  /// Returns a JSON map with:
  /// - "message": friendly recommendation message
  /// - "recommendations": list of {name, reason} objects
  /// - "follow_up_question": optional follow-up to refine search
  Future<Map<String, dynamic>> getRestaurantRecommendation({
    required String userQuery,
    required double latitude,
    required double longitude,
    required List<Map<String, dynamic>> nearbyRestaurants,
    FilterOptions? filters,
  }) async {
    await initialize();

    // Format restaurant list for AI analysis
    final restaurantList = nearbyRestaurants
        .map((r) {
          return '''
- ${r['name']} (${r['types']?.join(', ') ?? 'Restaurant'})
  Rating: ${r['rating'] ?? 'N/A'} | Price: ${r['price_level'] != null ? '\$' * r['price_level'] : 'N/A'}
  Address: ${r['vicinity'] ?? r['formatted_address'] ?? 'N/A'}
  ${r['opening_hours']?['open_now'] == true ? 'Currently Open' : 'Hours Unknown'}
''';
        })
        .join('\n');

    String filterInfo = '';
    if (filters != null && filters.hasFilters) {
      filterInfo =
          '\n\nUser preferences/restrictions: ${filters.toPromptString()}';
    }

    final prompt =
        '''
Based on the user's request and the list of nearby restaurants, recommend the best options.

User's request: "$userQuery"$filterInfo

Nearby restaurants:
$restaurantList

Please analyze the user's request and the available restaurants, then provide:
1. Your top 3 recommendations from the list
2. A brief explanation for each recommendation

Respond in JSON format:
{
  "message": "Your friendly recommendation message",
  "recommendations": [
    {
      "name": "Restaurant Name",
      "reason": "Why this is a good choice for the user"
    }
  ],
  "follow_up_question": "Optional follow-up question to refine recommendations"
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // Extract JSON from response (may be wrapped in markdown code blocks)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }

      // Fallback if no JSON found
      return {
        'message': text,
        'recommendations': [],
        'follow_up_question': null,
      };
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  /// Generates a quick food suggestion based on mood and preferences.
  ///
  /// [mood] describes how the user is feeling.
  /// [cuisinePreferences] is a list of preferred cuisines.
  /// [dietaryRestrictions] is a list of dietary needs.
  ///
  /// Returns a short, enthusiastic suggestion (1-2 sentences).
  Future<String> getQuickSuggestion({
    required String mood,
    required List<String> cuisinePreferences,
    required List<String> dietaryRestrictions,
  }) async {
    await initialize();

    final prompt =
        '''
I'm feeling $mood and I want something to eat.
${cuisinePreferences.isNotEmpty ? 'I like: ${cuisinePreferences.join(", ")}' : ''}
${dietaryRestrictions.isNotEmpty ? 'Dietary needs: ${dietaryRestrictions.join(", ")}' : ''}

Give me a quick, enthusiastic food suggestion! Keep it to 1-2 sentences.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'How about trying something new today?';
    } catch (e) {
      throw Exception('Failed to get suggestion: $e');
    }
  }

  /// Resets the chat session to start a fresh conversation.
  ///
  /// Clears conversation history while keeping the model initialized.
  void resetChat() {
    if (_isInitialized) {
      _chat = _model.startChat(history: []);
    }
  }
}
