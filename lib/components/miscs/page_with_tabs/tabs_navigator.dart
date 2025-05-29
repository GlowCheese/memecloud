import 'package:flutter/material.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class TabsNavigator extends StatelessWidget {
  /// must be between 1 and 1;
  final int variant;
  final TabController? tabController;
  late final List<int> selectedTabs;
  final List<String> tabNames;
  final void Function(int tabIdx)? onTabSelect;

  TabsNavigator({
    super.key,
    required this.variant,
    required this.tabNames,
    List<int>? selectedTabs,
    this.onTabSelect,
    this.tabController,
  }) : selectedTabs = selectedTabs ?? [];

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case 1:
        return _variant1(context);
      default:
        return _variant2(context);
    }
  }

  Widget _variant1(BuildContext context) {
    List<Widget> buttons = [];

    for (int i = 0; i < tabNames.length; i++) {
      late Widget button;
      final tabName = tabNames[i];

      if (selectedTabs.contains(i)) {
        button = FilledButton(
          onPressed: () => onTabSelect?.call(i),
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 15),
            ),
            backgroundColor: WidgetStatePropertyAll(
              Colors.amber.shade100, // Change to your desired color
            ),
          ),
          child: Text(tabName),
        );
      } else {
        button = ElevatedButton(
          onPressed: () => onTabSelect?.call(i),
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 15),
            ),
            backgroundColor: WidgetStatePropertyAll(
              Colors.blueGrey.shade300.withAlpha(108),
            ),
          ),
          child: Text(tabName, style: TextStyle(color: Colors.white)),
        );
      }

      buttons.add(button);
    }

    return SizedBox(
      height: 30,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: buttons.length,
        separatorBuilder: (context, index) => SizedBox(width: 10),
        itemBuilder: (context, index) => buttons[index],
      ),
    );
  }

  Widget _variant2(BuildContext context) {
    return TabBar(
      isScrollable: tabNames.length >= 5,
      controller: tabController,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      tabs: tabNames.map((e) => Tab(text: e)).toList(),
      dividerHeight: 0,
      indicator: MaterialIndicator(
        height: 3,
        bottomLeftRadius: 5,
        bottomRightRadius: 5,
        color: Colors.white,
      ),
    );
  }
}
