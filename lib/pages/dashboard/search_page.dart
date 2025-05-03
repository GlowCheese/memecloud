import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/components/grad_background.dart';
import 'package:memecloud/components/search/album_card.dart';
import 'package:memecloud/components/search/recent_searches.dart';
import 'package:memecloud/components/search/search_result.dart';
import 'package:memecloud/core/getit.dart';

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
  late TextEditingController searchQueryController;

  @override
  void initState() {
    super.initState();
    searchQueryController = TextEditingController();
  }

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
        _searchBar(),
        _genreGrid('Your Top Genres', widget.topGenres, widget.themeData),
        _genreGrid('Browse All', widget.allGenres, widget.themeData),
      ];
    } else if (currentSearchQuery == null) {
      bodyChildren = [_searchBar(), RecentSearches(onSelect: setSearchQuery)];
    } else {
      bodyChildren = [_searchBar(), SearchResult(currentSearchQuery!)];
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

  Widget _searchBar() {
    return Container(
      key: ValueKey("searchBar"),
      height: 60,
      margin: EdgeInsets.only(top: 20, left: 35, right: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 15),
            child: SvgPicture.asset(
              'assets/icons/Search.svg',
              width: 25,
              height: 25,
            ),
          ),
          Expanded(
            child: TextField(
              controller: searchQueryController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Songs, Artists, Podcasts & More',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              onTap: () {
                setState(() {
                  currentSearchQuery = null;
                  searchBarIsFocused = true;
                });
              },
              style: TextStyle(color: Colors.black),
              onSubmitted: setSearchQuery,
            ),
          ),
          SizedBox(width: 16),
        ],
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
