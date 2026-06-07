import 'package:flutter/material.dart';

class DropdownMenuWidget extends StatelessWidget {
  const DropdownMenuWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
