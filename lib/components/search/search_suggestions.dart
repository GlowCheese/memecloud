import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/search_suggestion_model.dart';

class SearchSuggestions extends StatefulWidget {
  final String searchKeyword;
  final void Function(String query) onSelect;

  const SearchSuggestions({
    super.key,
    required this.searchKeyword,
    required this.onSelect,
  });

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  List<String> data = getIt<ApiKit>().getRecentSearches().toList();

  @override
  Widget build(BuildContext context) {
    if (widget.searchKeyword.isEmpty) {
      return _suggestionItemList(data, deletable: true);
    } else {
      return defaultFutureBuilder<SearchSuggestionModel?>(
        future: getIt<ApiKit>().getSearchSuggestions(widget.searchKeyword),
        onData: (context, data) {
          return _suggestionItemList(data!.keywords ?? []);
        },
      );
    }
  }

  Widget _suggestionItemList(List<String> items, {bool? deletable}) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 22, top: 30),
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _suggestionItem(items[index], deletable: deletable);
        },
      ),
    );
  }

  Widget _suggestionItem(String item, {bool? deletable}) {
    final body = GestureDetector(
      onTap: () {
        widget.onSelect(item);
      },
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
            child: Icon(
              deletable == true ? Icons.history : Icons.search_rounded,
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Text(
              item,
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (deletable != true) return body;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: body),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () {
              getIt<ApiKit>().removeRecentSearch(item);
              setState(() {
                data.remove(item);
              });
            },
            icon: const Icon(size: 22, Icons.close),
          ),
        ),
      ],
    );
  }
}
