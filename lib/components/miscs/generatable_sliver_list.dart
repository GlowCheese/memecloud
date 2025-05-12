import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class GeneratableSliverList extends StatefulWidget {
  final int initialPageIdx;
  final Future Function(int pageIdx) asyncGenFunction;

  const GeneratableSliverList({
    super.key,
    required this.initialPageIdx,
    required this.asyncGenFunction,
  });

  @override
  State<GeneratableSliverList> createState() => _GeneratableSliverListState();
}

class _GeneratableSliverListState extends State<GeneratableSliverList> {
  bool hasMore = true;
  late int currentIdx = widget.initialPageIdx;
  List<Widget> items = [];

  Future<void> loadMorePage() async {
    try {
      final newData = await widget.asyncGenFunction(currentIdx);
      assert(newData.isNotEmpty);
      setState(() {
        currentIdx += 1;
        items.addAll(newData);
      });
    } catch (_) {
      setState(() => hasMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, idx) {
          if (idx < items.length) {
            return items[idx];
          }
          if (!hasMore) {
            return SizedBox();
          }

          return defaultFutureBuilder(
            future: loadMorePage(),
            onData: (context, data) {
              return SizedBox();
            }
          );
        },
        childCount: items.length + 1
      ),
    );
  }
}
