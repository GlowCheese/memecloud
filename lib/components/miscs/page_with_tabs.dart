import 'package:flutter/material.dart';

class PageWithTabs extends StatefulWidget {
  /// must be between 1 and 1;
  final int variation;
  final double? height;
  final bool hasNullTab;
  final List<String> tabNames;
  final List<Widget> tabBodies;
  final Widget Function(Widget tabsNavigator, Widget tabContent) widgetBuilder;

  PageWithTabs({
    super.key,
    required this.variation,
    this.height,
    Widget? nullTab,
    required this.tabNames,
    required this.tabBodies,
    required this.widgetBuilder,
  }) : hasNullTab = nullTab != null {
    assert(tabNames.length == tabBodies.length);
    if (hasNullTab) tabBodies.add(nullTab!);
  }

  @override
  State<PageWithTabs> createState() => _PageWithTabsState();
}

class _PageWithTabsState extends State<PageWithTabs> {
  late int? selectedTab = widget.hasNullTab ? null : 0;

  void onCurrentTabSelect() {
    if (!widget.hasNullTab) return;
    setState(() => selectedTab = null);
  }

  void onAnotherTabSelect(int i) {
    setState(() => selectedTab = i);
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetBuilder(
      _TabsNavigator(
        variation: widget.variation,
        tabNames: widget.tabNames,
        selectedTab: selectedTab,
        onCurrentTabSelect: onCurrentTabSelect,
        onAnotherTabSelect: onAnotherTabSelect,
      ),
      tabContent(context),
    );
  }

  Widget tabContent(BuildContext context) {
    if (widget.height == null) {
      if (selectedTab == null) {
        return widget.tabBodies.last;
      }
      return widget.tabBodies[selectedTab!];
    }

    return SizedBox(
      height: widget.height,
      child: IndexedStack(
        index: selectedTab ?? widget.tabBodies.length,
        children: widget.tabBodies,
      ),
    );
  }
}

class _TabsNavigator extends StatelessWidget {
  /// must be between 1 and 1;
  final int variation;
  final int? selectedTab;
  final List<String> tabNames;
  final void Function() onCurrentTabSelect;
  final void Function(int i) onAnotherTabSelect;

  const _TabsNavigator({
    required this.variation,
    required this.tabNames,
    this.selectedTab,
    required this.onCurrentTabSelect,
    required this.onAnotherTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _variation1(context);
  }

  Widget _variation1(BuildContext context) {
    List<Widget> buttons = [];

    for (int i = 0; i < tabNames.length; i++) {
      late Widget button;
      final tabName = tabNames[i];

      if (selectedTab == i) {
        button = FilledButton(
          onPressed: onCurrentTabSelect,
          child: Text(tabName),
        );
      } else {
        button = ElevatedButton(
          onPressed: () => onAnotherTabSelect(i),
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
