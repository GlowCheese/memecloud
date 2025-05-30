import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
import 'package:memecloud/blocs/recent_played/recent_played_stream.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/pages/library/my_playlist/my_playlist.dart';

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
      variant: 1,
      tabNames: const [
        '🕒 Gần đây',
        '❤️ Theo dõi',
        '🎵 Playlist',
        '📥 Tải xuống',
        '👎 Danh sách đen',
      ],
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        final snackBar = SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Done!',
                            message: 'Đã bỏ chặn 1 bài hát',
                            contentType: ContentType.success,
                          ),
                        );
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
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
                        final snackBar = SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Lỗi!',
                            message: 'Không thể bỏ chặn bài hát: $e',
                            contentType: ContentType.failure,
                          ),
                        );
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
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
          return COLUMN_THAT_IS_USED_TO_DISPLAY_MUSIC_CARDS(
            title: 'Bài hát bị chặn',
            children: <Widget>[
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
                  return _ItemsScrollView(
                    title: 'Phát gần đây',
                    items: [
                      for (var song in recentlyPlayedSongs)
                        SongCard(
                          key: ValueKey(song.id),
                          variant: 1,
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
              COLUMN_THAT_IS_USED_TO_DISPLAY_MUSIC_CARDS(
                title: 'Phát gần đây',
                showAllButton: _showAllRecentlyPlayedSongsButton(context),
                children: <Widget>[
                  for (var i = 0; i < min(5, recentlyPlayedSongs.length); i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horzPad,
                        vertical: 6,
                      ),
                      child: SongCard(
                        variant: 1,
                        song: recentlyPlayedSongs[i],
                        songList: recentlyPlayedSongs,
                      ),
                    ),
                ],
              ),

            if (recentlyPlayedPlaylists.isNotEmpty)
              COLUMN_THAT_IS_USED_TO_DISPLAY_MUSIC_CARDS(
                title: 'Danh sách phát',
                showAllButton: _showAllRecentlyPlayedPlaylistsButton(context),
                children: [
                  for (
                    var i = 0;
                    i < min(5, recentlyPlayedPlaylists.length);
                    i++
                  )
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horzPad,
                        vertical: 6,
                      ),
                      child: PlaylistCard(
                        variant: 1,
                        playlist: recentlyPlayedPlaylists[i],
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

  Widget myPlaylistTab(BuildContext context) {
    return MyPlaylistPage();
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

// Again, stupid name asf
class COLUMN_THAT_IS_USED_TO_DISPLAY_MUSIC_CARDS extends StatelessWidget {
  final String title;
  final Widget? showAllButton;
  final List<Widget> children;

  const COLUMN_THAT_IS_USED_TO_DISPLAY_MUSIC_CARDS({
    required this.title,
    this.showAllButton,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (showAllButton != null) showAllButton!,
            ],
          ),
        ),
        ...children,
      ],
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
