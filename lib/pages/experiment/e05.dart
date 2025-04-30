import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memecloud/apis/storage.dart';
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
      'savedSongsInfo': hiveBoxes.savedSongsInfo,
      'apiCache': hiveBoxes.apiCache,
      'vipSongs': hiveBoxes.vipSongs,
      'paletteColors': hiveBoxes.paletteColors,
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
            child: _boxDisplay(filterData),
          ),
        ],
      ),
    );
  }

  Widget _boxDisplay(Box box) {
    return Column(
      spacing: 10,
      children:
          box.keys.map((key) {
            return SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 270,
                    child: Text(
                      key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Text(box.get(key).toString(), style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
    );
  }
}
