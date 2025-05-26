import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/miscs/section_divider.dart';
import 'package:memecloud/components/miscs/page_with_tabs/multi.dart';

Map getLibraryPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(
      context,
      title: 'Thư viện',
      iconUri: 'assets/icons/library2.png',
    ),
    'bgColor': MyColorSet.green,
    'body': LibraryPage(),
  };
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithSingleTab(
      variant: 2,
      tabNames: const ['🕒 Gần đây', '❤️ Theo dõi', '📥 Tải xuống'],
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(
          children: [
            tabsNavigator,
            Expanded(child: tabContent),
          ],
        );
      },
      tabBodies: [Placeholder(), likedSongsTab(context), Placeholder()],
    );
  }

  Widget likedSongsTab(BuildContext context) {
    final likedSongs = getIt<ApiKit>().getLikedSongs();
    return ListView.separated(
      itemBuilder: (context, index) {
        return SongCard(
          variant: 1,
          song: likedSongs[index],
          songList: likedSongs,
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemCount: likedSongs.length,
    );
  }
}
