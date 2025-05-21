import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/bottom_sheet_dragger.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/song/show_song_artists.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';

Future showSongBottomSheetActions(BuildContext context, SongModel song) async {
  return showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return defaultFutureBuilder<bool>(
        future: getIt<ApiKit>().isBlacklisted(song.id),
        onData: (context, isBlacklisted) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragger(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SongCard(variation: 1, song: song),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Divider(),
              ),
              ListTile(
                leading: Icon(Icons.person_rounded),
                title: Text('Chuyển tới nghệ sĩ'),
                onTap: () {
                  context.pop();
                  showSongArtists(context, song.artists);
                },
              ),
              if (isBlacklisted)
                ListTile(
                  leading: Icon(Icons.visibility_rounded),
                  title: Text('Bỏ ẩn bài hát này'),
                  onTap: () {
                    context.pop();
                    getIt<ApiKit>().toggleBlacklist(song.id);
                  },
                )
              else
                ListTile(
                  leading: Icon(Icons.visibility_off_rounded),
                  title: Text('Ẩn bài hát này'),
                  onTap: () {
                    context.pop();
                    getIt<ApiKit>().toggleBlacklist(song.id);
                  },
                ),
              ListTile(
                leading: Icon(Icons.lyrics),
                title: Text('Xem lời bài hát'),
                onTap: () => context.push('/song_lyric'),
              ),
              SizedBox(height: 16),
              // ListTile(
              //   leading: Icon(Icons.playlist_add),
              //   title: Text('Thêm vào danh sách phát khác'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.star),
              //   title: Text('Nghe nhạc không quảng cáo'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.album),
              //   title: Text('Chuyển đến album'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text('Chuyển tới nghệ sĩ'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.share),
              //   title: Text('Chia sẻ'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.timer),
              //   title: Text('Hẹn giờ đi ngủ'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.radio),
              //   title: Text('Chuyển đến radio theo bài hát'),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: Icon(Icons.info_outline),
              //   title: Text('Xem thông tin ghi công của bài hát'),
              //   onTap: () {},
              // ),
            ],
          );
        },
      );
    },
  );
}
