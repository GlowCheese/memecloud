import 'package:flutter/material.dart';
import 'package:memecloud/models/song_model.dart';

class SongActionSheet extends StatelessWidget {
  final SongModel song;

  const SongActionSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text('Tải xuống'),
            onTap: () {
              Navigator.pop(context);
              // TODO: a
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Thêm vào yêu thích'),
            onTap: () {
              Navigator.pop(context);
              // TODO: a
            },
          ),
          ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Thêm vào playlist'),
            onTap: () {
              Navigator.pop(context);
              // TODO: a
            },
          ),
          ListTile(
            leading: Icon(Icons.queue_music),
            title: Text('Thêm vào danh sách phát'),
            onTap: () {
              Navigator.pop(context);
              //TODO: a
            },
          ),
          ListTile(
            leading: Icon(Icons.block),
            title: Text('Chặn bài hát'),
            onTap: () {
              Navigator.pop(context);
              // Gọi hàm chặn bài hát
            },
          ),
        ],
      ),
    );
  }
}
