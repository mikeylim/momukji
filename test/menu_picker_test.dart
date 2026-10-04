import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momukji/models/menu_catalog.dart';
import 'package:momukji/providers/app_provider.dart';
import 'package:momukji/widgets/menu_picker_sheet.dart';
import 'package:momukji/widgets/spin_wheel.dart';

void main() {
  test('the catalog offers varied choices from every cuisine', () {
    expect(MenuCatalog.cuisines, hasLength(18));
    expect(MenuCatalog.allDishes, hasLength(270));

    for (final cuisine in MenuCatalog.cuisines) {
      expect(cuisine.dishes, hasLength(MenuCatalog.dishesPerCuisine));
      expect(
        cuisine.dishes.map((dish) => dish.name).toSet(),
        hasLength(MenuCatalog.dishesPerCuisine),
      );
      expect(
        cuisine.dishes.every((dish) => dish.koreanName.isNotEmpty),
        isTrue,
      );
    }

    expect(
      MenuCatalog.allDishes.map((pick) => pick.searchQuery).toSet(),
      hasLength(270),
    );
  });

  test('a menu pick builds a specific restaurant search', () {
    final korean = MenuCatalog.cuisines.first;
    final bibimbap = korean.dishes.first;
    final cuisine = MenuSelection.cuisine(korean, false);
    final dish = MenuSelection.dish(korean, bibimbap, true);

    expect(cuisine.searchQuery, 'Korean');
    expect(dish.searchQuery, 'Bibimbap Korean');
    expect(dish.label, '비빔밥 · 한식');
  });

  test('restaurant search explains when location is unavailable', () async {
    final provider = AppProvider();

    await provider.searchRestaurants('Bibimbap Korean');

    expect(provider.error, contains('Set your location'));
    expect(provider.restaurants, isEmpty);
  });

  testWidgets('the dish wheel includes all fifteen choices', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MenuPickerSheet(isKorean: false))),
    );

    expect(find.text('Spin cuisine'), findsOneWidget);
    expect(find.text('Pick cuisine'), findsOneWidget);
    expect(find.text('Spin dish'), findsOneWidget);

    await tester.tap(find.text('Spin dish'));
    await tester.pumpAndSettle();

    final wheel = tester.widget<SpinWheel>(find.byType(SpinWheel));
    expect(wheel.items, hasLength(MenuCatalog.dishesPerCuisine));
    expect(wheel.items.first.wheelLabel, '1');
    expect(wheel.items.last.wheelLabel, '15');
    expect(find.byType(Chip), findsNWidgets(MenuCatalog.dishesPerCuisine));
    expect(
      find.textContaining('15 dishes in each of 18 categories'),
      findsOneWidget,
    );

    final firstCuisine = wheel.items.first.label;
    await tester.ensureVisible(find.text('Another category'));
    await tester.tap(find.text('Another category'));
    await tester.pumpAndSettle();
    final nextWheel = tester.widget<SpinWheel>(find.byType(SpinWheel));
    expect(nextWheel.items, hasLength(MenuCatalog.dishesPerCuisine));
    expect(nextWheel.items.first.label, isNot(firstCuisine));

    await tester.ensureVisible(find.text('Pick cuisine'));
    await tester.tap(find.text('Pick cuisine'));
    await tester.pumpAndSettle();
    expect(find.text('Find restaurants'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a cuisine returns a usable search selection', (
    tester,
  ) async {
    MenuSelection? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                choice = await showModalBottomSheet<MenuSelection>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const MenuPickerSheet(isKorean: false),
                );
              },
              child: const Text('Open picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick cuisine'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<MenuCuisine>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Korean').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find restaurants'));
    await tester.pumpAndSettle();

    expect(choice?.searchQuery, 'Korean');
    expect(choice?.label, 'Korean');
  });

  testWidgets('spinning a dish returns a dish from the catalog', (
    tester,
  ) async {
    MenuSelection? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                choice = await showModalBottomSheet<MenuSelection>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const MenuPickerSheet(isKorean: false),
                );
              },
              child: const Text('Open picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spin dish'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SpinWheel));
    await tester.tap(find.text('SPIN'));
    await tester.pump();
    expect(find.text('Spinning...'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(choice?.dish, isNotNull);
    expect(choice?.searchQuery, isNotEmpty);
    expect(
      MenuCatalog.allDishes.any(
        (pick) => pick.cuisine == choice?.cuisine && pick.dish == choice?.dish,
      ),
      isTrue,
    );
  });
}
