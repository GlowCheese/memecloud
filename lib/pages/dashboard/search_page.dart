import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/search/album_card.dart';
import 'package:memecloud/components/search/search_result_view.dart';
import 'package:memecloud/components/search/search_suggestions.dart';

Map getSearchPage(BuildContext context) {
  List<AlbumCard> topGenres = AlbumCard.getTopAlbums();
  List<AlbumCard> allGenres = AlbumCard.getAllAlbums();
  final themeData = AdaptiveTheme.of(context).theme;

  return {
    'appBar': defaultAppBar(context, title: 'Search'),
    'bgColor': MyColorSet.cyan,
    'body': SearchPage(
      topGenres: topGenres,
      themeData: themeData,
      allGenres: allGenres,
    ),
  };
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.topGenres,
    required this.themeData,
    required this.allGenres,
  });

  final List<AlbumCard> topGenres;
  final ThemeData themeData;
  final List<AlbumCard> allGenres;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? changeSearchQueryTask;
  String currentSearchKeyword = "";

  String? finalSearchQuery;
  bool searchBarIsFocused = false;
  final TextEditingController searchQueryController = TextEditingController();
  late final searchBar = Padding(
    padding: const EdgeInsets.only(top: 20, left: 35, right: 35),
    child: MySearchBar(
      variation: 1,
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
      body = ListView(
        children: [
          _genreGrid('Your Top Genres', widget.topGenres, widget.themeData),
          _genreGrid('Browse All', widget.allGenres, widget.themeData),
        ],
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
      children: [searchBar, Expanded(child: body)],
    );
  }

  Column _genreGrid(
    String title,
    List<AlbumCard> albumCards,
    ThemeData themeData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40, top: 35),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: themeData.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 25, right: 25, top: 15),
          child: Column(
            spacing: 15,
            children: [
              for (int i = 0; i < albumCards.length; i += 2)
                Row(
                  spacing: 15,
                  children: [
                    Expanded(child: AlbumCardWidget(album: albumCards[i])),
                    i + 1 < albumCards.length
                        ? Expanded(
                          child: AlbumCardWidget(album: albumCards[i + 1]),
                        )
                        : SizedBox(),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
