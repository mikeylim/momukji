import 'dart:math';

import 'package:flutter/material.dart';

import '../models/menu_catalog.dart';
import 'spin_wheel.dart';

enum MenuPickMode { spinCuisine, chooseCuisine, surpriseDish }

class MenuSelection {
  final MenuCuisine cuisine;
  final MenuDish? dish;
  final bool isKorean;

  const MenuSelection.cuisine(this.cuisine, this.isKorean) : dish = null;

  const MenuSelection.dish(this.cuisine, this.dish, this.isKorean);

  String get label => dish == null
      ? cuisine.label(isKorean)
      : '${dish!.label(isKorean)} · ${cuisine.label(isKorean)}';

  String get searchQuery {
    if (dish == null) return cuisine.name;
    if (cuisine.name == 'Fast Food' || cuisine.name == 'Desserts') {
      return dish!.name;
    }
    return '${dish!.name} ${cuisine.name}';
  }
}

/// Three ways to choose what to eat, with one Places search after selection.
class MenuPickerSheet extends StatefulWidget {
  final bool isKorean;

  const MenuPickerSheet({super.key, required this.isKorean});

  @override
  State<MenuPickerSheet> createState() => _MenuPickerSheetState();
}

class _MenuPickerSheetState extends State<MenuPickerSheet> {
  final Random _random = Random();
  MenuPickMode _mode = MenuPickMode.spinCuisine;
  MenuCuisine? _chosenCuisine;
  MenuCuisine? _dishCuisine;
  late MenuCuisine _activeDishCuisine;
  late List<MenuCuisine> _wheelCuisines;
  late List<MenuPick> _wheelDishes;
  int _wheelVersion = 0;

  @override
  void initState() {
    super.initState();
    _wheelCuisines = MenuCatalog.sampleCuisines(_random);
    _activeDishCuisine =
        MenuCatalog.cuisines[_random.nextInt(MenuCatalog.cuisines.length)];
    _wheelDishes = _dishesFor(_activeDishCuisine);
  }

  void _setMode(MenuPickMode mode) {
    setState(() {
      _mode = mode;
      _wheelVersion++;
      if (mode == MenuPickMode.spinCuisine) {
        _wheelCuisines = MenuCatalog.sampleCuisines(_random);
      } else if (mode == MenuPickMode.surpriseDish) {
        _setDishChoices();
      }
    });
  }

  List<MenuPick> _dishesFor(MenuCuisine cuisine) => [
    for (final dish in cuisine.dishes) MenuPick(cuisine, dish),
  ];

  void _setDishChoices() {
    _activeDishCuisine =
        _dishCuisine ??
        MenuCatalog.cuisines[_random.nextInt(MenuCatalog.cuisines.length)];
    _wheelDishes = _dishesFor(_activeDishCuisine);
  }

  void _anotherCuisine() {
    setState(() {
      // Avoid showing the same category twice in a row.
      final currentIndex = MenuCatalog.cuisines.indexOf(_activeDishCuisine);
      final offset = 1 + _random.nextInt(MenuCatalog.cuisines.length - 1);
      _activeDishCuisine = MenuCatalog
          .cuisines[(currentIndex + offset) % MenuCatalog.cuisines.length];
      _wheelDishes = _dishesFor(_activeDishCuisine);
      _wheelVersion++;
    });
  }

  void _returnCuisine(MenuCuisine cuisine) {
    Navigator.of(context).pop(MenuSelection.cuisine(cuisine, widget.isKorean));
  }

  void _returnDish(MenuPick pick) {
    Navigator.of(
      context,
    ).pop(MenuSelection.dish(pick.cuisine, pick.dish, widget.isKorean));
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = widget.isKorean;
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final wheelSize = min(size.width - 64, 300.0);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: size.height * 0.84,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                isKorean ? '오늘 뭐 먹지?' : 'What should I eat?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _modeChip(
                          MenuPickMode.spinCuisine,
                          isKorean ? '요리 돌리기' : 'Spin cuisine',
                          Icons.casino,
                        ),
                        _modeChip(
                          MenuPickMode.chooseCuisine,
                          isKorean ? '요리 고르기' : 'Pick cuisine',
                          Icons.touch_app,
                        ),
                        _modeChip(
                          MenuPickMode.surpriseDish,
                          isKorean ? '메뉴 돌리기' : 'Spin dish',
                          Icons.restaurant_menu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_mode == MenuPickMode.chooseCuisine)
                      _buildCuisineChooser(isKorean)
                    else ...[
                      if (_mode == MenuPickMode.surpriseDish) ...[
                        Text(
                          isKorean
                              ? '${MenuCatalog.cuisines.length}가지 종류마다 ${MenuCatalog.dishesPerCuisine}가지 메뉴가 있어요.'
                              : '${MenuCatalog.dishesPerCuisine} dishes in each of ${MenuCatalog.cuisines.length} categories.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<MenuCuisine?>(
                          initialValue: _dishCuisine,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: isKorean
                                ? '요리 종류 (선택 사항)'
                                : 'Cuisine (optional)',
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<MenuCuisine?>(
                              value: null,
                              child: Text(
                                isKorean
                                    ? '모든 요리 (종류 랜덤 선택)'
                                    : 'All cuisines (random category)',
                              ),
                            ),
                            ...MenuCatalog.cuisines.map(
                              (cuisine) => DropdownMenuItem<MenuCuisine?>(
                                value: cuisine,
                                child: Text(cuisine.label(isKorean)),
                              ),
                            ),
                          ],
                          onChanged: (cuisine) {
                            setState(() {
                              _dishCuisine = cuisine;
                              _setDishChoices();
                              _wheelVersion++;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_activeDishCuisine.label(isKorean)} · ${_wheelDishes.length} ${isKorean ? '가지 메뉴' : 'dishes'}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_dishCuisine == null)
                          TextButton.icon(
                            onPressed: _anotherCuisine,
                            icon: const Icon(Icons.shuffle),
                            label: Text(
                              isKorean ? '다른 요리 종류 보기' : 'Another category',
                            ),
                          ),
                      ] else ...[
                        Text(
                          isKorean
                              ? '${MenuCatalog.cuisines.length}가지 요리 중 8개를 랜덤으로 보여줘요.'
                              : '8 random choices from ${MenuCatalog.cuisines.length} cuisines.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Center(
                        child: SpinWheel(
                          key: ValueKey('$_mode-$_wheelVersion'),
                          size: wheelSize,
                          isKorean: isKorean,
                          items: _mode == MenuPickMode.spinCuisine
                              ? [
                                  for (
                                    var i = 0;
                                    i < _wheelCuisines.length;
                                    i++
                                  )
                                    SpinWheelItem(
                                      label: _wheelCuisines[i].label(isKorean),
                                      value: '$i',
                                      color: WheelColors.getColor(i),
                                    ),
                                ]
                              : [
                                  for (var i = 0; i < _wheelDishes.length; i++)
                                    SpinWheelItem(
                                      label: _wheelDishes[i].dish.label(
                                        isKorean,
                                      ),
                                      wheelLabel: '${i + 1}',
                                      value: '$i',
                                      color: WheelColors.getColor(i),
                                    ),
                                ],
                          onResult: (item) {
                            if (!mounted) return;
                            final index = int.parse(item.value);
                            if (_mode == MenuPickMode.spinCuisine) {
                              _returnCuisine(_wheelCuisines[index]);
                            } else {
                              _returnDish(_wheelDishes[index]);
                            }
                          },
                        ),
                      ),
                      if (_mode == MenuPickMode.surpriseDish) ...[
                        const SizedBox(height: 16),
                        Text(
                          isKorean ? '휠 번호별 메뉴' : 'Dishes on the wheel',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < _wheelDishes.length; i++)
                              Chip(
                                label: Text(
                                  '${i + 1}. ${_wheelDishes[i].dish.label(isKorean)}',
                                ),
                              ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Text(
                          isKorean
                              ? '다시 열면 새로운 후보가 나와요.'
                              : 'Open again for a new set of choices.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(MenuPickMode mode, String label, IconData icon) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: _mode == mode,
      onSelected: (_) => _setMode(mode),
    );
  }

  Widget _buildCuisineChooser(bool isKorean) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isKorean
              ? '원하는 요리를 골라 근처 식당을 찾아보세요.'
              : 'Choose a cuisine to find nearby restaurants.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<MenuCuisine>(
          initialValue: _chosenCuisine,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: isKorean ? '요리 종류' : 'Cuisine',
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final cuisine in MenuCatalog.cuisines)
              DropdownMenuItem(
                value: cuisine,
                child: Text(cuisine.label(isKorean)),
              ),
          ],
          onChanged: (cuisine) => setState(() => _chosenCuisine = cuisine),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _chosenCuisine == null
              ? null
              : () => _returnCuisine(_chosenCuisine!),
          icon: const Icon(Icons.search),
          label: Text(isKorean ? '식당 찾기' : 'Find restaurants'),
        ),
      ],
    );
  }
}
