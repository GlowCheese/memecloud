import 'package:flutter/material.dart';


class PageWithTabs {
  final Widget? nullTab;
  final List<String> tabNames;
  final List<Widget> tabBodies;

  late int selectedTab;
  final void Function(int tabIdx) onTabSelect;

  PageWithTabs({
    this.nullTab,
    required this.tabNames,
    required this.tabBodies,
    required this.onTabSelect
  }) {
    selectedTab = nullTab == null ? 0 : 1;
    assert(tabNames.length == tabBodies.length);
  }

  Widget navigationBar(BuildContext context) {
    List<Widget> buttons = [];

    for (int i = 0; i < tabNames.length; i++) {
      late Widget button;
      final tabName = tabNames[i];

      if (selectedTab == i) {
        button = FilledButton(
          onPressed: () => onTabSelect(i),
          child: Text(tabName),
        );
      } else {
        button = ElevatedButton(
          onPressed: () => onTabSelect(i),
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

  Widget tabContent(BuildContext context) {
    if (selectedTab == -1) {
      return nullTab!;
    }
    return tabBodies[selectedTab];
  }
}
