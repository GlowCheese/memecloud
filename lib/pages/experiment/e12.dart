import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/generatable_list/list_view.dart';
import 'package:memecloud/components/miscs/page_with_tabs.dart';
import 'package:memecloud/components/miscs/section_divider.dart';

Future<List<Text>> genFunc(int page, int key) async {
  if (page >= 10) return [];
  await Future.delayed(const Duration(seconds: 1));

  final len = 10;
  return List.generate(
    len,
    (i) => Text((key + len * (len * page + i)).toString()),
  );
}

class E12 extends StatelessWidget {
  const E12({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithTabs(
      variation: 1,
      tabNames: ['tab_1', 'tab_2', 'tab_3'],
      tabBodies: [
        Text('1'),
        GeneratableListView(
          key: ValueKey('genlist1'),
          initialPageIdx: 0,
          asyncGenFunction: (page) => genFunc(page, 0),
        ),
        GeneratableListView(
          key: ValueKey('genlist2'),
          initialPageIdx: 0,
          asyncGenFunction: (page) => genFunc(page, 1),
        ),
      ],
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(
          children: [
            tabsNavigator,
            SectionDivider(),
            Expanded(child: tabContent),
          ],
        );
      },
    );
  }
}
