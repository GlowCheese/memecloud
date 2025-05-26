import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/tabs_navigator.dart';

class PageWithSingleTab extends StatefulWidget {
  /// must be between 1 and 2
  final int variant;
  final Widget? nullTab;
  final List<String> tabNames;
  final List<Widget>? tabBodies;
  final Widget Function(Widget tabsNavigator, Widget tabContent) widgetBuilder;

  const PageWithSingleTab({
    super.key,
    required this.variant,
    required this.tabNames,
    required this.widgetBuilder,

    this.nullTab,
    this.tabBodies,
  });

  @override
  State<PageWithSingleTab> createState() => _PageWithSingleTabState();
}

class _PageWithSingleTabState extends State<PageWithSingleTab> with SingleTickerProviderStateMixin {
  late int? selectedTab;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabNames.length,
      vsync: this,
    );
    selectedTab = widget.nullTab != null ? null : 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        variant: widget.variant,
        tabNames: widget.tabNames,
        selectedTabs: [if (selectedTab != null) selectedTab!],
        onTabSelect: onTabSelect,
        tabController: _tabController,
      ),
      tabContent(context),
    );
  }

  Widget tabContent(BuildContext context) {
    switch (widget.variant) {
      case 1:
        if (selectedTab == null) {
          return widget.nullTab!;
        }
        return widget.tabBodies![selectedTab!];
      default:
        return TabBarView(
          controller: _tabController,
          children: widget.tabBodies!,
        );
    }
  }
}