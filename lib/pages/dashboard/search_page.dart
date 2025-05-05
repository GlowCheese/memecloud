import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/components/search_bar.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/components/grad_background.dart';
import 'package:memecloud/components/search/album_card.dart';
import 'package:memecloud/components/search/search_result_view.dart';
import 'package:memecloud/components/search/recent_searches_view.dart';

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
  String? currentSearchQuery;
  bool searchBarIsFocused = false;
  final TextEditingController searchQueryController = TextEditingController();
  late final searchBar = Padding(
    padding: const EdgeInsets.only(top: 20, left: 35, right: 35),
    child: MySearchBar(
      variation: 1,
      searchQueryController: searchQueryController,
      onTap: () {
        setState(() {
          currentSearchQuery = null;
          searchBarIsFocused = true;
        });
      },
      onSubmitted: setSearchQuery,
    ),
  );

  @override
  void dispose() {
    searchQueryController.dispose();
    super.dispose();
  }

  void setSearchQuery(String value) {
    getIt<ApiKit>().saveSearch(value);
    FocusScope.of(context).unfocus();
    setState(() => currentSearchQuery = value);
    searchQueryController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    late List<Widget> bodyChildren;
    if (searchBarIsFocused == false) {
      bodyChildren = [
        searchBar,
        _genreGrid('Your Top Genres', widget.topGenres, widget.themeData),
        _genreGrid('Browse All', widget.allGenres, widget.themeData),
      ];
    } else if (currentSearchQuery == null) {
      bodyChildren = [searchBar, RecentSearchesView(onSelect: setSearchQuery)];
    } else {
      bodyChildren = [searchBar, SearchResultView(currentSearchQuery!)];
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bodyChildren,
        ),
      ),
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
