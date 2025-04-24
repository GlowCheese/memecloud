import 'package:memecloud/models/album_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:memecloud/components/default_appbar.dart';


Map getSearchPage(BuildContext context) {
  List<AlbumCard> topGenres = AlbumCard.getTopAlbums();
  List<AlbumCard> allGenres = AlbumCard.getAllAlbums();
  final themeData = AdaptiveTheme.of(context).theme;

  return {
    'appBar': defaultAppBar(context, title: 'Search'),
    'body': SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchSection(context),
            _genreGrid('Your Top Genres', topGenres, themeData),
            _genreGrid('Browse All', allGenres, themeData),
            SizedBox(height: 80),
          ],
        ),
      ),
    ),
  };
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

GestureDetector _searchSection(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      context.push('/404');
    },
    child: Container(
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
          Text(
            'Songs, Artists, Podcasts & More',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
