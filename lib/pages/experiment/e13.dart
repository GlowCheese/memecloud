import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/multi.dart';
import 'package:memecloud/components/miscs/section_divider.dart';

class E13 extends StatelessWidget {
  const E13({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithMultiTab(
      variation: 1,
      tabNames: ['tab 1', 'tab 2', 'tab 3'],
      nullTab: Center(child: Text('No tab is selected!')),
      widgetBuilder:(tabsNavigator, tabContent) {
        return Column(
          children: [
            tabsNavigator,
            SectionDivider(),
            Expanded(child: tabContent)
          ],
        );
      },
      tabBuilder: (selectedTabs) {
        final s = selectedTabs.join(', ');
        return Center(child: Text('Selected tabs: $s'));
      },
    );
  }
}