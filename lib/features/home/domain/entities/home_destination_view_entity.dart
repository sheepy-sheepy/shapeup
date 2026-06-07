import 'package:flutter/material.dart';

class HomeDestinationViewEntity {
  const HomeDestinationViewEntity({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
