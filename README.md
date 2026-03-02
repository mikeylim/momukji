# Momukji (모먹지)

An AI-powered food and restaurant recommendation app built with Flutter. "Momukji" (모먹지) is Korean for "What should I eat?"

## Features

- AI-powered restaurant recommendations using Google Gemini
- Location-based search with Google Maps & Places API
- Bilingual support (English & Korean)
- Quick Pick mode with mood and cuisine selection
- Advanced filtering options (cuisine type, food type, dietary restrictions, price range, etc.)
- Interactive chat interface for personalized recommendations

## Screenshots

*Coming soon*

## Prerequisites

- Flutter SDK (3.10.4 or higher)
- Android Studio / Xcode
- Google Cloud Platform account (for API keys)

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/momukji.git
cd momukji
```

### 2. Get API Keys

You'll need two API keys from Google:

#### Google Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key

#### Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API
4. Create an API key and copy it

### 3. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and add your actual API keys
nano .env  # or use any text editor
```

Your `.env` file should look like:
```
GEMINI_API_KEY=your_actual_gemini_key
GOOGLE_MAPS_API_KEY=your_actual_maps_key
```

### 4. Configure Platform-Specific API Keys

#### Android
Edit `android/app/src/main/AndroidManifest.xml` and replace the API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

#### iOS
Edit `ios/Runner/AppDelegate.swift` and replace the API key:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 5. Install Dependencies

```bash
flutter pub get
```

### 6. Run the App

```bash
# For Android
flutter run

# For iOS
cd ios && pod install && cd ..
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── filter_options.dart
│   ├── restaurant.dart
│   └── chat_message.dart
├── providers/             # State management
│   └── app_provider.dart
├── screens/               # App screens
│   ├── home_screen.dart
│   └── map_screen.dart
├── services/              # API services
│   ├── gemini_service.dart
│   ├── places_service.dart
│   └── location_service.dart
├── widgets/               # Reusable widgets
│   ├── filter_sheet.dart
│   ├── chat_widget.dart
│   ├── restaurant_card.dart
│   └── location_bar.dart
└── l10n/                  # Localization
```

## Security Notes

- **NEVER** commit `.env` or any file containing API keys
- The `.gitignore` is configured to exclude sensitive files
- Always use `.env.example` as a template for others to set up their own keys
- Consider restricting your API keys in Google Cloud Console (by app package name, bundle ID, or IP)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- AI powered by [Google Gemini](https://deepmind.google/technologies/gemini/)
- Maps by [Google Maps Platform](https://developers.google.com/maps)
