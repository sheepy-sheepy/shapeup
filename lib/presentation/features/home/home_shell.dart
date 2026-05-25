import 'package:flutter/material.dart';

import '../analytics/analytics_screen.dart';
import '../diary/diary_screen.dart';
import '../measurements/measurements_screen.dart';
import '../photos/photos_screen.dart';
import '../products/products_screen.dart';
import '../settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final Set<int> _visitedPages = {0};

  static const pages = [
    DiaryScreen(),
    MeasurementsScreen(),
    PhotosScreen(),
    ProductsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  static const destinations = [
    _HomeDestination(Icons.restaurant_outlined, Icons.restaurant, 'Дневник'),
    _HomeDestination(
      Icons.monitor_weight_outlined,
      Icons.monitor_weight,
      'Параметры',
    ),
    _HomeDestination(Icons.photo_outlined, Icons.photo, 'Фото'),
    _HomeDestination(Icons.fastfood_outlined, Icons.fastfood, 'Продукты'),
    _HomeDestination(Icons.show_chart_outlined, Icons.show_chart, 'Аналитика'),
    _HomeDestination(Icons.settings_outlined, Icons.settings, 'Настройки'),
  ];

  void _selectPage(int value) {
    if (value == index) return;

    setState(() {
      index = value;
      _visitedPages.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 760;
        final body = _Body(index: index, visitedPages: _visitedPages);

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: _selectPage,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _selectPage,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              for (final item in destinations)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                  tooltip: item.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.index,
    required this.visitedPages,
  });

  final int index;
  final Set<int> visitedPages;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: [
        for (var i = 0; i < _HomeShellState.pages.length; i++)
          if (visitedPages.contains(i) || i == index)
            _HomeShellState.pages[i]
          else
            const SizedBox.shrink(),
      ],
    );
  }
}

class _HomeDestination {
  const _HomeDestination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
