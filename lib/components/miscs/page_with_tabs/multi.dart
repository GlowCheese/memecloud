import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/tabs_navigator.dart';

class PageWithMultiTab extends StatefulWidget {
  /// must be between 1 and 1;
  final int variant;
  final Widget? nullTab;
  final List<String> tabNames;
  final Widget Function(List<int> selectedTabs) tabBuilder;
  final Widget Function(Widget tabsNavigator, Widget tabContent) widgetBuilder;

  const PageWithMultiTab({
    super.key,
    required this.variant,
    required this.tabNames,
    required this.widgetBuilder,
    this.nullTab,
    required this.tabBuilder,
  });

  @override
  State<PageWithMultiTab> createState() => _PageWithMultiTabState();
}

class _PageWithMultiTabState extends State<PageWithMultiTab> {
  late List<int> selectedTabs = [if (widget.nullTab == null) 0];

  void onTabSelect(int tabIdx) {
    if (selectedTabs.contains(tabIdx)) {
      if (selectedTabs.length > 1 || widget.nullTab != null) {
        setState(() => selectedTabs.remove(tabIdx));
      }
    }
    else {
      setState(() => selectedTabs.add(tabIdx));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetBuilder(
      TabsNavigator(
        variant: widget.variant,
        tabNames: widget.tabNames,
        selectedTabs: selectedTabs,
        onTabSelect: onTabSelect,
      ),
      tabContent(context),
    );
  }

  Widget tabContent(BuildContext context) {
    if (selectedTabs.isEmpty) {
      return widget.nullTab!;
    }
    return widget.tabBuilder(selectedTabs);
  }
}