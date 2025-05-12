import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/section_divider.dart';

class PageWithTabs extends StatefulWidget {
  final Widget? nullTab;
  final List<String> tabNames;
  final List<Widget> tabBodies;

  PageWithTabs({
    super.key,
    this.nullTab,
    required this.tabNames,
    required this.tabBodies,
  }) {
    assert(tabNames.length == tabBodies.length);
  }

  @override
  State<PageWithTabs> createState() => _PageWithTabsState();
}

class _PageWithTabsState extends State<PageWithTabs> {
  late int selectedTab = widget.nullTab == null ? 0 : -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _navigationBar(context),
        const SectionDivider(),
        _tabContent(context),
      ],
    );
  }

  Widget _navigationBar(BuildContext context) {
    List<Widget> buttons = [];

    for (int i = 0; i < widget.tabNames.length; i++) {
      late Widget button;
      final tabName = widget.tabNames[i];

      if (selectedTab == i) {
        button = FilledButton(
          onPressed: () {
            if (widget.nullTab != null) {
              setState(() => selectedTab = -1);
            }
          },
          child: Text(tabName),
        );
      } else {
        button = ElevatedButton(
          onPressed: () {
            setState(() => selectedTab = i);
          },
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

  Widget _tabContent(BuildContext context) {
    if (selectedTab == -1) {
      return widget.nullTab!;
    }
    return widget.tabBodies[selectedTab];
  }
}
