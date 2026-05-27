import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../domain/entities/local_entities.dart';

class CsvProductsPanel extends StatelessWidget {
  const CsvProductsPanel({
    super.key,
    required this.children,
    this.title = 'Готовая база продуктов',
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _FoodSectionPanel(
      title: title,
      backgroundColor: Colors.white.withValues(alpha: 0.68),
      borderColor: Colors.white.withValues(alpha: 0.48),
      children: children,
    );
  }
}

class CustomProductsPanel extends StatelessWidget {
  const CustomProductsPanel({
    super.key,
    required this.children,
    this.title = 'Свои продукты',
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _FoodSectionPanel(
      title: title,
      backgroundColor: const Color(0xFFEAF7EC).withValues(alpha: 0.74),
      borderColor: const Color(0xFFB8E6C2).withValues(alpha: 0.70),
      children: children,
    );
  }
}

class CustomRecipesPanel extends StatelessWidget {
  const CustomRecipesPanel({
    super.key,
    required this.children,
    this.title = 'Свои рецепты',
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _FoodSectionPanel(
      title: title,
      backgroundColor: const Color(0xFFEAF4FF).withValues(alpha: 0.74),
      borderColor: const Color(0xFFBBD8F4).withValues(alpha: 0.70),
      children: children,
    );
  }
}

class _FoodSectionPanel extends StatelessWidget {
  const _FoodSectionPanel({
    required this.title,
    required this.backgroundColor,
    required this.borderColor,
    required this.children,
  });

  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: title),
          ...children,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
}

class CsvFoodNameLabel extends StatelessWidget {
  const CsvFoodNameLabel({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return _FoodNameLabel(
      name: name,
      backgroundColor: Colors.white.withValues(alpha: 0.86),
      borderColor: Colors.white.withValues(alpha: 0.70),
    );
  }
}

class CustomProductNameLabel extends StatelessWidget {
  const CustomProductNameLabel({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return _FoodNameLabel(
      name: name,
      backgroundColor: const Color(0xFFDDF3E2).withValues(alpha: 0.90),
      borderColor: const Color(0xFFB8E6C2).withValues(alpha: 0.82),
    );
  }
}

class CustomRecipeNameLabel extends StatelessWidget {
  const CustomRecipeNameLabel({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return _FoodNameLabel(
      name: name,
      backgroundColor: const Color(0xFFDDEEFF).withValues(alpha: 0.90),
      borderColor: const Color(0xFFBBD8F4).withValues(alpha: 0.82),
    );
  }
}

class CustomProductTile extends StatelessWidget {
  const CustomProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  final CustomProduct product;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CustomProductNameLabel(name: product.name),
      subtitle: Text(
        kbzhuPer100Text(
          calories: product.calories,
          proteins: product.proteins,
          fats: product.fats,
          carbs: product.carbs,
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}

class CsvFoodTile extends StatelessWidget {
  const CsvFoodTile({
    super.key,
    required this.food,
    this.onTap,
    this.trailing,
  });

  final Food food;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CsvFoodNameLabel(name: food.name),
      subtitle: Text(
        kbzhuPer100Text(
          calories: food.calories,
          proteins: food.proteins,
          fats: food.fats,
          carbs: food.carbs,
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}

class _FoodNameLabel extends StatelessWidget {
  const _FoodNameLabel({
    required this.name,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String name;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
