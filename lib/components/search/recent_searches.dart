import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';

class RecentSearches extends StatefulWidget {
  final void Function(String query)? onSelect;

  const RecentSearches({super.key, this.onSelect});

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  List<String> data = getIt<ApiKit>().getRecentSearches();

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox();

    final List<Widget> items = [];
    for (var item in data) {
      items.add(
        GestureDetector(
          onTap: () {
            if (widget.onSelect != null) {
              widget.onSelect!(item);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 18,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300.withAlpha(60),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(Icons.history, color: Colors.white),
                    ),
                    Flexible(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  onPressed: () {
                    getIt<ApiKit>().removeSearch(item);
                    setState(() {
                      data.remove(item);
                    });
                  },
                  icon: Icon(
                    size: 22,
                    Icons.close
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 22, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: items,
      ),
    );
  }
}
