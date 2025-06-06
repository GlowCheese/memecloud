import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/success.dialog.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';

Future<void> showCreatePlaylistDialog(
  BuildContext context,
  SongModel song,
) async {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Tạo danh sách phát'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh sách phát',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (không bắt buộc)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Tạo'),
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isEmpty) return;

              final newPlaylist = await getIt<ApiKit>().supabase.userPlaylist
                  .createNewPlaylist(title: title, description: desc);
              await getIt<ApiKit>().supabase.userPlaylist.addSongToPlaylist(
                songId: song.id,
                playlistId: newPlaylist.id,
              );

              if (context.mounted) {
                showSuccessDialog(
                  context,
                  text: 'Đã tạo "$title" và thêm bài hát ${song.title}.',
                  numOfPopContext: 2,
                );
              }
            },
          ),
        ],
      );
    },
  );
}
