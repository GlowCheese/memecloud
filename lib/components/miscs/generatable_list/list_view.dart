import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class GeneratableListView extends StatefulWidget {
  final int initialPageIdx;
  final Duration loadDelay;
  final Future Function(int pageIdx) asyncGenFunction;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  const GeneratableListView({
    super.key,
    required this.initialPageIdx,
    required this.asyncGenFunction,
    this.loadDelay = Duration.zero,
    this.separatorBuilder,
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

  int get itemCount => items.length + (hasMore ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(BuildContext context, int idx) {
      if (idx < items.length) return items[idx];
      return defaultFutureBuilder(
        future: loadMorePage(),
        onData: (_, _) => const SizedBox(),
      );
    }

    if (widget.separatorBuilder == null) {
      return ListView.builder(itemBuilder: itemBuilder, itemCount: itemCount);
    } else {
      return ListView.separated(
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        separatorBuilder: widget.separatorBuilder!,
      );
    }
  }
}
