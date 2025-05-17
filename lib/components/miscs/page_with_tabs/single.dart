import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/tabs_navigator.dart';

class PageWithSingleTab extends StatefulWidget {
  /// must be between 1 and 1;
  final int variation;
  final Widget? nullTab;
  final List<String> tabNames;
  final List<Widget>? tabBodies;
  final Widget Function(int selectedTab)? tabBuilder;
  final Widget Function(Widget tabsNavigator, Widget tabContent) widgetBuilder;

  const PageWithSingleTab({
    super.key,
    required this.variation,
    required this.tabNames,
    required this.widgetBuilder,

    this.nullTab,
    this.tabBodies,
    this.tabBuilder,
  });

  @override
  State<PageWithSingleTab> createState() => _PageWithSingleTabState();
}

class _PageWithSingleTabState extends State<PageWithSingleTab> {
  late int? selectedTab = widget.nullTab != null ? null : 0;

  void onTabSelect(int tabIdx) {
    if (tabIdx == selectedTab) {
      if (widget.nullTab == null) return;
      setState(() => selectedTab = null);
    }
    else {
      setState(() => selectedTab = tabIdx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetBuilder(
      TabsNavigator(
        variation: widget.variation,
        tabNames: widget.tabNames,
        selectedTabs: [if (selectedTab != null) selectedTab!],
        onTabSelect: onTabSelect,
      ),
      tabContent(context),
    );
  }

  Widget tabContent(BuildContext context) {
    if (selectedTab == null) {
      return widget.nullTab!;
    }

    if (widget.tabBuilder != null) {
      return widget.tabBuilder!(selectedTab!);
    }

    return widget.tabBodies![selectedTab!];
  }
}