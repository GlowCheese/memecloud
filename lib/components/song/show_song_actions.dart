import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/song/show_song_artists.dart';
import 'package:memecloud/components/miscs/bottom_sheet_dragger.dart';
import 'package:memecloud/components/playlist/show_add_to_playlist_sheet.dart';

Future showSongBottomSheetActions(BuildContext context, SongModel song) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      final isBlacklisted = getIt<ApiKit>().isBlacklisted(song.id);
      final isLiked = getIt<ApiKit>().isSongLiked(song.id);

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.38,
        minChildSize: 0.2,
        maxChildSize: 0.5,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const BottomSheetDragger(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SongCard(variant: 1, song: song),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Divider(),
                ),
                const ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Tải về'),
                ),
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text('Chuyển tới nghệ sĩ'),
                  onTap: () {
                    context.pop();
                    showSongArtists(context, song.artists);
                  },
                ),
                if (isLiked)
                  ListTile(
                    leading: const Icon(Icons.favorite_rounded),
                    title: const Text('Bỏ thích bài hát này'),
                    onTap: () {
                      context.pop();
                      getIt<ApiKit>().setIsSongLiked(song, false);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded),
                    title: const Text('Thích bài hát này'),
                    onTap: () {
                      context.pop();
                      getIt<ApiKit>().setIsSongLiked(song, true);
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Thêm vào danh sách phát'),
                  onTap: () {
                    showAddToPlaylistSheet(context, song);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Chia sẻ bài hát'),
                  onTap: () {
                    context.pop();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      builder: (context) {
                        getIt<ApiKit>().shareSong(song).whenComplete(() {
                          if (context.mounted) context.pop();
                        });
                        return const FractionallySizedBox(
                          heightFactor: 0.3,
                          widthFactor: 1.0,
                          child: SpinKitWaveSpinner(color: Colors.white),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                if (isBlacklisted)
                  ListTile(
                    leading: const Icon(Icons.visibility_rounded),
                    title: const Text('Bỏ ẩn bài hát này'),
                    onTap: () {
                      context.pop();
                      getIt<ApiKit>().setIsBlacklisted(song, false);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.visibility_off_rounded),
                    title: const Text('Ẩn bài hát này'),
                    onTap: () {
                      context.pop();
                      getIt<ApiKit>().setIsBlacklisted(song, true);
                    },
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
