import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memecloud/blocs/recent_played/recent_played_event.dart';
import 'package:memecloud/blocs/recent_played/recent_played_stream.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
import 'package:memecloud/models/song_model.dart';

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

const double horzPad = 24;

class LibraryPage extends StatelessWidget {
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

  Widget _showAllRecentlyPlayedSongsButton(BuildContext context) {
    return TextButton(
      child: const Text('Xem tất cả'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return RecentPlayedStreamBuilder(
                builder: (context, recentlyPlayedSongs, _) {
                  return _ItemsScrollView(
                    title: 'Phát gần đây',
                    items: [
                      for (var song in recentlyPlayedSongs)
                        SongCard(
                          key: ValueKey(song.id),
                          variant: 3,
                          song: song,
                          songList: recentlyPlayedSongs,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _showAllRecentlyPlayedPlaylistsButton(BuildContext context) {
    return TextButton(
      child: const Text('Xem tất cả'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return RecentPlayedStreamBuilder(
                builder: (context, _, recentlyPlayedPlaylists) {
                  return _ItemsScrollView(
                    title: 'Danh sách phát gần đây',
                    items: [
                      for (var playlist in recentlyPlayedPlaylists)
                        PlaylistCard(
                          key: ValueKey(playlist.id),
                          variant: 1,
                          playlist: playlist,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget recentlyPlayedTab(BuildContext context) {
    return RecentPlayedStreamBuilder(
      builder: (context, recentlyPlayedSongs, recentlyPlayedPlaylists) {
        return ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            if (recentlyPlayedSongs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: horzPad,
                      right: horzPad,
                      top: 18,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Phát gần đây',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _showAllRecentlyPlayedSongsButton(context),
                      ],
                    ),
                  ),
                  ...recentlyPlayedSongs
                      .sublist(0, min(5, recentlyPlayedSongs.length))
                      .map(
                        (song) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: horzPad,
                            vertical: 6,
                          ),
                          child: SongCard(
                            variant: 3,
                            song: song,
                            songList: recentlyPlayedSongs,
                          ),
                        ),
                      ),
                ],
              ),

            if (recentlyPlayedPlaylists.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: horzPad,
                      right: horzPad,
                      top: 18,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh sách phát',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _showAllRecentlyPlayedPlaylistsButton(context),
                      ],
                    ),
                  ),
                  ...recentlyPlayedPlaylists
                      .sublist(0, min(5, recentlyPlayedPlaylists.length))
                      .map(
                        (playlist) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: horzPad,
                            vertical: 6,
                          ),
                          child: PlaylistCard(variant: 1, playlist: playlist),
                        ),
                      ),
                ],
              ),
          ],
        );
      },
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

// TODO: this is a stupid name, change it later
class _ItemsScrollView extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ItemsScrollView({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return GradBackground(
      color: MyColorSet.lightBlue,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horzPad),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: items[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
