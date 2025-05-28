import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';

Map getLibraryPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(
      context,
      title: 'Thư viện',
      iconUri: 'assets/icons/library2.png',
    ),
    'bgColor': MyColorSet.lightBlue,
    'body': LibraryPage(),
  };
}

class LibraryPage extends StatelessWidget {
  static const double horzPad = 24;

  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithSingleTab(
      variant: 2,
      tabNames: const ['🕒 Gần đây', '❤️ Theo dõi', '📥 Tải xuống'],
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(children: [tabsNavigator, Expanded(child: tabContent)]);
      },
      tabBodies: [
        recentlyPlayedTab(context),
        favoriteTab(context),
        downloadedSongsTab(context),
      ],
    );
  }

  Widget recentlyPlayedTab(BuildContext context) {
    final recentlyPlayedSongs =
        getIt<ApiKit>().getRecentlyPlayedSongs().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentlyPlayedSongs.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: horzPad),
                  Text(
                    'Phát gần đây',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              ...recentlyPlayedSongs
                  .sublist(0, min(5, recentlyPlayedSongs.length))
                  .map(
                    (song) => SongCard(
                      variant: 1,
                      song: song,
                      songList: recentlyPlayedSongs,
                    ),
                  ),
            ],
          ),
      ],
    );
  }

  Widget favoriteTab(BuildContext context) {
    final likedSongsPlaylist = PlaylistModel.likedPlaylist();
    final followedPlaylists = getIt<ApiKit>().getFollowedPlaylists();

    return Padding(
      padding: const EdgeInsets.only(left: horzPad, right: horzPad, top: 18),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return PlaylistCard(variant: 2, playlist: likedSongsPlaylist);
          }
          final playlist = followedPlaylists[index - 1];
          return PlaylistCard(variant: 3, playlist: playlist);
        },
        separatorBuilder: (context, index) => SizedBox(height: 18),
        itemCount: followedPlaylists.length + 1,
      ),
    );
  }

  Widget downloadedSongsTab(BuildContext context) {
    final downloadedSongsPlaylist = PlaylistModel.downloadedPlaylist();

    return Padding(
      padding: const EdgeInsets.only(left: horzPad, right: horzPad, top: 18),
      child: ListView.separated(
        itemBuilder: (context, index) {
          return PlaylistCard(variant: 2, playlist: downloadedSongsPlaylist);
        },
        separatorBuilder: (context, index) => SizedBox(height: 18),
        itemCount: 10,
      ),
    );
  }
}
