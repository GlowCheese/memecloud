import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/bottom_sheet_dragger.dart';
import 'package:memecloud/components/playlist/create_new_playlist_dialog.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';

Future<void> showAddToPlaylistSheet(
  BuildContext context,
  SongModel song,
) async {
  final playlists =
      await getIt<ApiKit>().supabase.userPlaylist.getUserPlaylists();
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
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
                ...playlists.map((playlist) {
                  return ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(playlist.title),
                    onTap: () async {
                      Navigator.pop(context);
                      await getIt<ApiKit>().supabase.userPlaylist
                          .addSongToPlaylist(
                            songId: song.id,
                            playlistId: playlist.id,
                          );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thêm vào "${playlist.title}"'),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          );
        },
      );
    },
  );
}
