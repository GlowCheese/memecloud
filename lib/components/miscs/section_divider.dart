import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Divider(
        color: Colors.white.withAlpha(156),
        thickness: 1,
        indent: 30,
        endIndent: 30,
      ),
    );
  }
}
