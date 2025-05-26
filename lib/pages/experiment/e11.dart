import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
import 'package:memecloud/components/miscs/section_divider.dart';
import 'package:memecloud/components/miscs/generatable_list/sliver_list.dart';

Future<List<Text>> genFunc(int page, int key) async {
  if (page >= 10) return [];
  await Future.delayed(const Duration(seconds: 1));

  final len = 5;
  return List.generate(
    len,
    (i) => Text((key + len * (len * page + i)).toString()),
  );
}

class E11 extends StatelessWidget {
  const E11({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithSingleTab(
      variant: 1,
      tabNames: ['tab_1', 'tab_2', 'tab_3'],
      tabBodies: [
        SliverToBoxAdapter(child: Text('1')),
        GeneratableSliverList(
          initialPageIdx: 0,
          asyncGenFunction: (page) => genFunc(page, 0),
        ),
        SliverToBoxAdapter(child: Text('3')),
      ],
      widgetBuilder: (tabsNavigator, tabContent) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: tabsNavigator),
            SliverToBoxAdapter(child: SectionDivider()),
            tabContent,
          ],
        );
      },
    );
  }
}
