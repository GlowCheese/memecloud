import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/snackbar.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memecloud/components/miscs/bottom_sheet_dragger.dart';
import 'package:memecloud/components/playlist/create_new_playlist_dialog.dart';

Future<void> showAddToPlaylistSheet(
  BuildContext context,
  SongModel song,
) async {
  List<PlaylistModel>? playlists;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (playlists == null) {
            getIt<ApiKit>().supabase.userPlaylist.getUserPlaylists().then(
              (data) => setState(() => playlists = data),
            );
            return const SpinKitChasingDots(size: 50, color: Colors.white);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragger(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Chọn danh sách phát',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Tạo danh sách phát mới'),
                onTap: () async {
                  Navigator.pop(context);
                  await showCreatePlaylistDialog(context, song);
                },
              ),
              const Divider(),
              ...playlists!.map((playlist) {
                return ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.title),
                  onTap: () async {
                    await getIt<ApiKit>().supabase.userPlaylist
                        .addSongToPlaylist(
                          songId: song.id,
                          playlistId: playlist.id,
                        );
                    if (context.mounted) {
                      showSuccessSnackbar(
                        context,
                        message: 'Đã thêm vào "${playlist.title}"',
                      );
                      context.pop();
                    }
                  },
                );
              }),
            ],
          );
        },
      );
    },
  );
}
