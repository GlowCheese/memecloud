import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';

class LikedPage extends StatefulWidget {
  const LikedPage({super.key});

  @override
  _LikedPageState createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  late List<SongModel> likedSongs;

  @override
  void initState() {
    super.initState();
    likedSongs = getIt<ApiKit>().getLikedSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yêu thích')),
      body: Container(
        padding: EdgeInsets.all(12),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return SongCard(
              variant: 1,
              song: likedSongs[index],
              songList: likedSongs,
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemCount: likedSongs.length,
        ),
      ),
    );
  }
}
