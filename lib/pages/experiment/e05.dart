import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:memecloud/core/getit.dart';

class E05 extends StatefulWidget {
  const E05({super.key});

  @override
  State<E05> createState() => _E05State();
}

class _E05State extends State<E05> {
  int filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    late Box filterData;

    final hiveBoxes = getIt<PersistentStorage>().hiveBoxes;

    final Map<String, Box> filterMap = {
      'apiCache': hiveBoxes.apiCache,
      'vipSongs': hiveBoxes.vipSongs,
      'savedSongsInfo': hiveBoxes.savedSongsInfo,
    };

    filterMap.forEach((label, box) {
      final buttonsLength = buttons.length;
      if (filterIndex == buttonsLength) {
        filterData = box;
      }
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child:
              (filterIndex == buttonsLength)
                  ? (FilledButton(
                    onPressed: () {
                      setState(() => filterIndex = buttonsLength);
                    },
                    child: Text(label),
                  ))
                  : (ElevatedButton(
                    onPressed: () {
                      setState(() => filterIndex = buttonsLength);
                    },
                    child: Text(label),
                  )),
        ),
      );
    });

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5, top: 10),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                children: buttons,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            child: BoxDisplay(box: filterData),
          ),
        ],
      ),
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
