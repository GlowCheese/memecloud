import 'package:flutter/material.dart';

class TabsNavigator extends StatelessWidget {
  /// must be between 1 and 1;
  final int variation;
  late final List<int> selectedTabs;
  final List<String> tabNames;
  final void Function(int tabIdx)? onTabSelect;

  TabsNavigator({
    super.key,
    required this.variation,
    required this.tabNames,
    List<int>? selectedTabs,
    this.onTabSelect,
  }) : selectedTabs = selectedTabs ?? [];

  @override
  Widget build(BuildContext context) {
    return _variation1(context);
  }

  Widget _variation1(BuildContext context) {
    List<Widget> buttons = [];

    for (int i = 0; i < tabNames.length; i++) {
      late Widget button;
      final tabName = tabNames[i];

      if (selectedTabs.contains(i)) {
        button = FilledButton(
          onPressed: () => onTabSelect?.call(i),
          child: Text(tabName),
        );
      } else {
        button = ElevatedButton(
          onPressed: () => onTabSelect?.call(i),
          child: Text(tabName),
        );
      }

      buttons.add(
        Padding(padding: const EdgeInsets.only(right: 10), child: button),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5, top: 10),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: buttons,
        ),
      ),
    );
  }
}
