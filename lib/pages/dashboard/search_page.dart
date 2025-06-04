import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/search/search_result_view.dart';
import 'package:memecloud/components/search/search_suggestions.dart';

Map getSearchPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Search'),
    'bgColor': MyColorSet.cyan,
    'body': const SearchPage(),
  };
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? changeSearchQueryTask;
  String currentSearchKeyword = "";

  String? finalSearchQuery;
  bool searchBarIsFocused = false;
  final TextEditingController searchQueryController = TextEditingController();

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 35),
      child: MySearchBar(
        variant: 1,
        searchQueryController: searchQueryController,
        onTap: () {
          if (searchBarIsFocused == false || finalSearchQuery != null) {
            setState(() {
              finalSearchQuery = null;
              searchBarIsFocused = true;
            });
          }
        },
        onSubmitted: setSearchQuery,
        onChanged: (p0) {
          changeSearchQueryTask?.cancel();
          changeSearchQueryTask = Timer(
            Duration(milliseconds: p0.isEmpty ? 0 : 500),
            () => setState(() => currentSearchKeyword = p0),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchQueryController.dispose();
    changeSearchQueryTask?.cancel();
    super.dispose();
  }

  void setSearchQuery(String value) {
    getIt<ApiKit>().saveRecentSearch(value);
    FocusScope.of(context).unfocus();
    setState(() => finalSearchQuery = value);
    searchQueryController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    late Widget body;
    if (searchBarIsFocused == false) {
      body = defaultFutureBuilder(
        future: getIt<ApiKit>().getHubHome(),
        onData: (context, data) {
          return ScrollableZingHub(data);
        },
      );
    } else if (finalSearchQuery == null) {
      body = SearchSuggestions(
        searchKeyword: currentSearchKeyword,
        onSelect: setSearchQuery,
      );
    } else {
      body = SearchResultView(finalSearchQuery!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [searchBar(), Expanded(child: body)],
    );
  }
}

class ScrollableZingHub extends StatelessWidget {
  final Map<String, dynamic> hub;

  const ScrollableZingHub(this.hub, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (hub.containsKey('banners'))
          _banner(
            Map.castFrom<dynamic, dynamic, String, String>(
              hub['banners'][Random().nextInt(hub['banners'].length)],
            ),
          ),
        DataInspector(hub),
      ],
    );
  }

  Widget _banner(Map<String, String> banner) {
    String id = banner['link']!.split('/').last.split('.').first;
    String cover = banner['cover']!;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: CachedNetworkImage(
          imageUrl: cover,
          fit: BoxFit.cover,
          height: 120,
          width: double.infinity,
        ),
      ),
    );

    return DataInspector(id, name: 'id');
  }
}
