import 'package:flutter/material.dart';
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
        Placeholder(),
        favoriteTab(context),
        downloadedSongsTab(context),
      ],
    );
  }

  Widget favoriteTab(BuildContext context) {
    final likedSongsPlaylist = PlaylistModel.fromJson<AnonymousPlaylist>({
      "customId": "userLikedSongs",
      "title": "Bài hát đã thích",
      "artistsNames": getIt<ApiKit>().myProfile().displayName,
      "thumbnailUrl": "assets/icons/liked_songs.jpeg",
      "songs": getIt<ApiKit>().getLikedSongs(),
    });

    final followedPlaylists = getIt<ApiKit>().getFollowedPlaylists();

    return Padding(
      padding: const EdgeInsets.only(left: horzPad, right: horzPad, top: 18),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return PlaylistCard(variant: 2, playlist: likedSongsPlaylist);
          }
          final playlist = followedPlaylists[index - 1];
          return PlaylistCard(variant: 2, playlist: playlist);
        },
        separatorBuilder: (context, index) => SizedBox(height: 18),
        itemCount: followedPlaylists.length + 1,
      ),
    );
  }

  Widget downloadedSongsTab(BuildContext context) {
    final downloadedSongsPlaylist = PlaylistModel.fromJson<AnonymousPlaylist>({
      "customId": "userDownloadedSongs",
      "title": "Danh sách tải xuống",
      "artistsNames": getIt<ApiKit>().myProfile().displayName,
      "thumbnailUrl": "assets/icons/downloaded_songs.webp",
      "songs": getIt<ApiKit>().getDownloadedSongs(),
    });

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
