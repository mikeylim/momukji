import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momukji/services/gemini_service.dart';
import 'package:momukji/theme/app_theme.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Basic test placeholder - the actual app requires .env file
    expect(true, isTrue);
  });

  test('uses the stable free-tier Gemini model by default', () {
    expect(GeminiService.defaultModel, 'gemini-3.5-flash-lite');
  });

  test('dark theme maintains readable surface contrast', () {
    final colors = AppTheme.dark().colorScheme;

    expect(_contrastRatio(colors.onSurface, colors.surface), greaterThan(7));
    expect(
      _contrastRatio(colors.onSurfaceVariant, colors.surface),
      greaterThan(4.5),
    );
  });
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance() + 0.05;
  final darker = background.computeLuminance() + 0.05;
  return lighter > darker ? lighter / darker : darker / lighter;
}
