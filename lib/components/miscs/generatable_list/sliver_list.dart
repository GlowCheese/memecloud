import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class GeneratableSliverList extends StatefulWidget {
  final int initialPageIdx;
  final Duration loadDelay;
  final Future Function(int pageIdx) asyncGenFunction;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  const GeneratableSliverList({
    super.key,
    required this.initialPageIdx,
    required this.asyncGenFunction,
    this.loadDelay = Duration.zero,
    this.separatorBuilder,
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
      await Future.delayed(widget.loadDelay);
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

  int get itemCount {
    if (widget.separatorBuilder == null) {
      return items.length + (hasMore ? 1 : 0);
    }
    return 2 * (items.length + (hasMore ? 1 : 0)) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, idx) {
          if (widget.separatorBuilder != null) {
            if (idx.isOdd) {
              return widget.separatorBuilder!(context, idx ~/ 2);
            }
            else {
              idx ~/= 2;
            }
          }

          if (idx < items.length) return items[idx];
          return defaultFutureBuilder(
            future: loadMorePage(),
            onData: (context, data) => SizedBox()
          );
        },
        childCount: itemCount
      ),
    );
  }
}
