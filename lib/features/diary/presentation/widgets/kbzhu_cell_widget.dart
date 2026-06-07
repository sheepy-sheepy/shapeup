import 'package:flutter/material.dart';

class KbzhuCellWidget extends StatelessWidget {
  const KbzhuCellWidget({super.key, 
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            style: style,
          ),
        ),
      ),
    );
  }
}
