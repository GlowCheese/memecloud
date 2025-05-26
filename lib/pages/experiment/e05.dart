import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/section_divider.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';

class E05 extends StatefulWidget {
  const E05({super.key});

  @override
  State<E05> createState() => _E05State();
}

class _E05State extends State<E05> {
  int filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hiveBoxes = getIt<ApiKit>().storage.hiveBoxes;

    final Map<String, Box> filterMap = {
      'likedSongs': hiveBoxes.likedSongs,
      'vipSongs': hiveBoxes.vipSongs,
      'savedInfo': hiveBoxes.savedInfo,
      'apiCache': hiveBoxes.apiCache,
    };

    return PageWithSingleTab(
      variant: 1,
      tabNames: filterMap.keys.toList(),
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(
          children: [
            tabsNavigator,
            SectionDivider(),
            Expanded(child: tabContent),
          ],
        );
      },
      tabBodies:
          filterMap.values.map((filterData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                child: BoxDisplay(box: filterData),
              ),
            );
          }).toList(),
    );
  }
}

class BoxDisplay extends StatefulWidget {
  final Box box;

  const BoxDisplay({super.key, required this.box});

  @override
  State<BoxDisplay> createState() => _BoxDisplayState();
}

class _BoxDisplayState extends State<BoxDisplay> {
  Future _deleteConfirm(key) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm"),
            content: Text("U sure u want to delete $key?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.box.delete(key);
                  });
                },
                child: Text("Sure man"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> boxKeys = List<String>.from(widget.box.keys);
    return Column(
      spacing: 10,
      children:
          boxKeys.map((key) {
            return SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Center(
                    child: IconButton(
                      onPressed: () => _deleteConfirm(key),
                      icon: Icon(Icons.close),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 240,
                      child: Text(
                        key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Center(child: SizedBox(width: 30)),
                  Center(
                    child: Text(
                      widget.box.get(key).toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
