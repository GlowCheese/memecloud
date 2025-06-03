import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/snackbar.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/sections/section_card.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/blocs/dl_status/dl_status_manager.dart';
import 'package:memecloud/pages/library/my_playlist/my_playlist.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
import 'package:memecloud/blocs/recent_played/recent_played_stream.dart';

Map getLibraryPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(
      context,
      title: 'Thư viện',
      iconUri: 'assets/icons/library2.png',
    ),
    'bgColor': MyColorSet.lightBlue,
    'body': const LibraryPage(),
  };
}

const double horzPad = 24;

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithSingleTab(
      variant: 1,
      tabNames: const [
        '🕒 Gần đây',
        '❤️ Theo dõi',
        '🎵 Playlist',
        '📥 Tải xuống',
        '📓 Danh sách đen',
      ],
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: tabsNavigator,
            ),
            Expanded(child: tabContent),
          ],
        );
      },
      tabBodies: [
        recentlyPlayedTab(context),
        favoriteTab(context),
        myPlaylistTab(context),
        downloadedSongsTab(context),
        blacklistTab(context),
      ],
    );
  }

  Future<bool?> onUnblacklistButtonPressed(
    BuildContext context,
    SongModel song,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context2) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text(
            'Bạn có chắc chắn muốn bỏ chặn bài hát: ${song.title}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context2, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                getIt<ApiKit>()
                    .setIsBlacklisted(song, false)
                    .then((_) {
                      if (context.mounted) {
                        showSuccessSnackbar(
                          context,
                          title: 'Done!',
                          message: 'Đã bỏ chặn 1 bài hát',
                        );
                      }
                      if (context2.mounted) {
                        Navigator.pop(context2, true);
                      }
                    })
                    .catchError((e) {
                      if (context2.mounted) {
                        Navigator.pop(context2, false);
                      }
                      if (context.mounted) {
                        showErrorSnackbar(context, message: e.toString());
                      }
                    });
              },
              child: const Text('Bỏ chặn'),
            ),
          ],
        );
      },
    );
  }

  Widget blacklistTab(BuildContext context) {
    final blacklistedSongs = getIt<ApiKit>().getBlacklistedSongs();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StatefulBuilder(
        builder: (context, setState) {
          log('get num of blacklist songs: ${blacklistedSongs.length}');
          return SectionCard.variant1(
            title: 'Bài hát bị chặn',
            titlePadding: const EdgeInsets.only(
              left: horzPad,
              right: horzPad,
              top: 18,
            ),
            children: <Widget>[
              if (blacklistedSongs.isEmpty) ...[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.block,
                        size: 80,
                        color: Colors.white.withAlpha(140),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Danh sách trống',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Các bài hát trong sổ đen sẽ xuất hiện ở đây.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              for (var song in blacklistedSongs)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horzPad,
                    vertical: 6,
                  ),
                  child: SongCard(
                    variant: 3,
                    song: song,
                    onUnblacklistButtonPressed: () {
                      onUnblacklistButtonPressed(context, song).then((result) {
                        if (result == true) {
                          setState(() {
                            blacklistedSongs.remove(song);
                          });
                        }
                      });
                    },
                  ),
                ),
            ],
          );
        },
      ),
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
                  return SimpleScrollablePage(
                    title: 'Phát gần đây',
                    bgColor: Colors.lightBlue,
                    spacing: 6,
                    items: [
                      for (var song in recentlyPlayedSongs)
                        Padding(
                          key: ValueKey(song.id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: horzPad,
                          ),
                          child: SongCard(
                            variant: 1,
                            song: song,
                            songList: recentlyPlayedSongs,
                          ),
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
                  return SimpleScrollablePage(
                    title: 'Danh sách phát gần đây',
                    bgColor: Colors.lightBlue,
                    spacing: 6,
                    items: [
                      for (var playlist in recentlyPlayedPlaylists)
                        Padding(
                          key: ValueKey(playlist.id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: horzPad,
                          ),
                          child: PlaylistCard(variant: 1, playlist: playlist),
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
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            if (recentlyPlayedSongs.isNotEmpty)
              SectionCard.variant1(
                title: 'Phát gần đây',
                titlePadding: const EdgeInsets.only(
                  left: horzPad,
                  right: horzPad,
                  top: 18,
                ),
                showAllButton: _showAllRecentlyPlayedSongsButton(context),
                children: <Widget>[
                  for (var song in recentlyPlayedSongs.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horzPad,
                        vertical: 6,
                      ),
                      child: SongCard(
                        variant: 1,
                        song: song,
                        songList: recentlyPlayedSongs,
                      ),
                    ),
                ],
              ),

            if (recentlyPlayedPlaylists.isNotEmpty)
              SectionCard.variant1(
                title: 'Danh sách phát',
                titlePadding: const EdgeInsets.only(
                  left: horzPad,
                  right: horzPad,
                  top: 18,
                ),
                showAllButton: _showAllRecentlyPlayedPlaylistsButton(context),
                children: [
                  for (var playlist in recentlyPlayedPlaylists.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horzPad,
                        vertical: 6,
                      ),
                      child: PlaylistCard(variant: 1, playlist: playlist),
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
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemCount: followedPlaylists.length + 1,
      ),
    );
  }

  Widget myPlaylistTab(BuildContext context) {
    return const MyPlaylistPage();
  }

  Widget downloadedSongsTab(BuildContext context) {
    final downloadedSongsPlaylist = PlaylistModel.downloadedPlaylist();
    final downloadedPlaylists = getIt<ApiKit>().getDownloadedPlaylists();
    final downloadingPlaylists =
        getIt<PlaylistDlStatusManager>().getDownloadingPlaylists();

    return Padding(
      padding: const EdgeInsets.only(left: horzPad, right: horzPad, top: 18),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return PlaylistCard(variant: 2, playlist: downloadedSongsPlaylist);
          }
          late final PlaylistModel playlist;

          if (index <= downloadingPlaylists.length) {
            playlist = downloadingPlaylists[index - 1];
          } else {
            playlist =
                downloadedPlaylists[index - downloadingPlaylists.length - 1];
          }
          return PlaylistCard(variant: 3, playlist: playlist);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemCount: downloadedPlaylists.length + downloadingPlaylists.length + 1,
      ),
    );
  }
}
