import 'package:flutter/material.dart';

class HomeBodyWidget extends StatelessWidget {
  const HomeBodyWidget({
    super.key,
    required this.index,
    required this.visitedPages,
    required this.pages,
  });

  final int index;
  final Set<int> visitedPages;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: [
        for (var i = 0; i < pages.length; i++)
          if (visitedPages.contains(i) || i == index)
            pages[i]
          else
            const SizedBox.shrink(),
      ],
    );
  }
}
