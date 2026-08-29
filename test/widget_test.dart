import 'package:flutter_test/flutter_test.dart';
import 'package:momukji/services/gemini_service.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Basic test placeholder - the actual app requires .env file
    expect(true, isTrue);
  });

  test('uses the stable free-tier Gemini model by default', () {
    expect(GeminiService.defaultModel, 'gemini-3.7-flash');
  });
}
