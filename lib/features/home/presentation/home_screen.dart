import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/features/analytics/presentation/analytics_screen.dart';
import 'package:shapeup/features/diary/presentation/diary_screen.dart';
import 'package:shapeup/features/measurements/presentation/measurements_screen.dart';
import 'package:shapeup/features/photos/presentation/photos_screen.dart';
import 'package:shapeup/features/products/presentation/products_screen.dart';
import 'package:shapeup/features/settings/presentation/settings_screen.dart';
import 'package:shapeup/features/home/presentation/widgets/home_body_widget.dart';
import 'package:shapeup/features/home/domain/entities/home_destination_view_entity.dart';
import 'package:shapeup/features/home/providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int index;
  late final Set<int> _visitedPages;

  @override
  void initState() {
    super.initState();
    final navigation = ref.read(homeNavigationUseCaseProvider);
    index = navigation.initialIndex;
    _visitedPages = {navigation.initialIndex};
  }

  static const pages = [
    DiaryScreen(),
    MeasurementsScreen(),
    PhotosScreen(),
    ProductsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  static const destinations = [
    HomeDestinationViewEntity(icon: Icons.restaurant_outlined, selectedIcon: Icons.restaurant, label: 'Дневник'),
    HomeDestinationViewEntity(
      icon: Icons.monitor_weight_outlined,
      selectedIcon: Icons.monitor_weight,
      label: 'Параметры',
    ),
    HomeDestinationViewEntity(icon: Icons.photo_outlined, selectedIcon: Icons.photo, label: 'Фото'),
    HomeDestinationViewEntity(icon: Icons.fastfood_outlined, selectedIcon: Icons.fastfood, label: 'Продукты'),
    HomeDestinationViewEntity(icon: Icons.show_chart_outlined, selectedIcon: Icons.show_chart, label: 'Аналитика'),
    HomeDestinationViewEntity(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Настройки'),
  ];

  void _selectPage(int value) {
    final navigation = ref.read(homeNavigationUseCaseProvider);

    if (!navigation.canSelectPage(
      currentIndex: index,
      selectedIndex: value,
    )) {
      return;
    }

    final nextVisitedPages = navigation.visitedPagesAfterSelect(
      visitedPages: _visitedPages,
      selectedIndex: value,
    );

    setState(() {
      index = value;
      _visitedPages
        ..clear()
        ..addAll(nextVisitedPages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 760;
        final body = HomeBodyWidget(
          index: index,
          visitedPages: _visitedPages,
          pages: pages,
        );

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

