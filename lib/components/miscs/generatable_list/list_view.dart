import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class GeneratableListView extends StatefulWidget {
  final int initialPageIdx;
  final Duration loadDelay;
  final Future Function(int pageIdx) asyncGenFunction;

  const GeneratableListView({
    super.key,
    required this.initialPageIdx,
    required this.asyncGenFunction,
    this.loadDelay = Duration.zero,
  });

  @override
  State<GeneratableListView> createState() => _GeneratableListView();
}

class _GeneratableListView extends State<GeneratableListView> {
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, idx) {
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
          },
        );
      },
      itemCount: items.length + 1,
    );
  }
}
