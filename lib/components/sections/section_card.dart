import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:memecloud/components/musics/hub_card.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/musics/artist_card.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';
import 'package:memecloud/components/miscs/grad_background.dart';

class SectionCard {
  final Key? key;
  final String title;

  SectionCard({this.key, required this.title});

  /// `showAllButton` can be any widget
  Widget variant1({
    EdgeInsetsGeometry? titlePadding,
    required Widget child,
    Widget? showAllButton,
  }) {
    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (showAllButton != null) showAllButton,
      ],
    );

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titlePadding == null)
          titleRow
        else
          Padding(padding: titlePadding, child: titleRow),
        child,
      ],
    );
  }

  /// `showAllButton` is a button that open a page
  Widget variant2({
    EdgeInsetsGeometry? titlePadding,
    required Widget child,
    Widget Function(BuildContext context)? showAllBuilder,
  }) {
    late final Widget? showAllButton;
    if (showAllBuilder == null) {
      showAllButton = null;
    } else {
      showAllButton = Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: showAllBuilder));
            },
            child: const Text('Xem tất cả'),
          );
        },
      );
    }

    return variant1(
      titlePadding: titlePadding,
      child: child,
      showAllButton: showAllButton,
    );
  }

  /// tailored to use with horizontal `ListView`
  Widget variant3({
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry listViewPadding = const EdgeInsets.all(0),
    required double height,
    double? spacing,
    required Widget Function(BuildContext context, int index) itemBuilder,
    required int itemCount,
    Widget Function(BuildContext context)? showAllBuilder,
  }) {
    return variant2(
      titlePadding: titlePadding,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: listViewPadding,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: itemBuilder,
            itemCount: itemCount,
            separatorBuilder: (context, index) => SizedBox(width: spacing),
          ),
        ),
      ),
      showAllBuilder: showAllBuilder,
    );
  }

  /// tailored for `List<PlaylistModel>`
  Widget variant3_1({required List<PlaylistModel> playlists, int lim = 7}) {
    return SectionCard(title: title).variant3(
      height: 212,
      titlePadding: const EdgeInsets.only(left: 24, right: 24, bottom: 4),
      listViewPadding: const EdgeInsets.symmetric(horizontal: 18),
      spacing: 16,
      itemCount: min(lim, playlists.length),
      itemBuilder: (context, index) {
        return PlaylistCard(
          playlist: playlists[index],
        ).variant3(width: 130, height: 130);
      },
      showAllBuilder: (context) {
        return SimpleScrollablePage(
          title: title,
          bgColor: MyColorSet.indigo,
          spacing: 14,
        ).variant1(
          children: [
            const SizedBox(),
            for (var playlist in playlists)
              Padding(
                key: Key(playlist.id),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PlaylistCard(playlist: playlist).variant2(size: 70),
              ),
            const SizedBox(),
          ],
        );
      },
    );
  }

  /// tailored for `List<hub>`, where `hub` is a `map`
  /// (i'm too lazy to make a `HubModel`)
  Widget variant3_2({required List<Map<String, dynamic>> hubs, int lim = 7}) {
    return SectionCard(title: title).variant3(
      height: 116,
      titlePadding: const EdgeInsets.only(left: 24, right: 24, bottom: 4),
      listViewPadding: const EdgeInsets.symmetric(horizontal: 18),
      spacing: 18,
      itemCount: min(lim, hubs.length),
      itemBuilder: (context, index) {
        final hub = hubs[index];
        return HubCard(
          hubId: hub['encodeId'],
          title: hub['title'],
          thumbnailHasText: hub['thumbnailHasText'],
        ).variant1(width: 212, height: double.infinity);
      },
    );
  }

  /// tailored for `List<SongModel>`
  Widget variant3_3({
    required List<SongModel> songs,
    int songsPerCol = 3,
    Widget? showAllButton,
    EdgeInsetsGeometry? titlePadding,
  }) {
    int currentPage = 0;

    return variant1(
      titlePadding: titlePadding ?? const EdgeInsets.symmetric(horizontal: 24),
      showAllButton: showAllButton,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              CarouselSlider(
                items: [
                  for (int i = 0; i < songs.length; i += songsPerCol)
                    Column(
                      spacing: 10,
                      key: ValueKey(i),
                      children: [
                        for (
                          int j = i;
                          j < min(songs.length, i + songsPerCol);
                          j++
                        )
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SongCard(
                              key: ValueKey(j),
                              variant: 1,
                              song: songs[j],
                              songList: songs,
                            ),
                          ),
                      ],
                    ),
                ],
                options: CarouselOptions(
                  // SongCard.variant1's height is 53 (i don't know why)
                  height: ((53 + 12) * songsPerCol).toDouble(),
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() => currentPage = index);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 14,
                children: [
                  for (int i = 0; i < songs.length ~/ songsPerCol; i++)
                    Container(
                      key: ValueKey(i),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(
                          currentPage == i ? 255 : 128,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// tailored for `List<ArtistModel>`
  Widget variant3_4({required List<ArtistModel> artists, int lim = 7}) {
    return SectionCard(title: title).variant3(
      height: 187,
      titlePadding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
      listViewPadding: const EdgeInsets.symmetric(horizontal: 18),
      spacing: 18,
      itemCount: min(lim, artists.length),
      itemBuilder: (context, index) {
        return ArtistCard(
          variant: 3,
          size: 130,
          artist: artists[index],
        );
      },
    );
  }
}
