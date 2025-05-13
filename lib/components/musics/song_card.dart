import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/musics/music_card.dart';

class SongCard extends StatelessWidget {
  /// must be between 1 and 1.
  final int variation;
  final SongModel song;
  final List<SongModel>? songList;

  const SongCard({
    super.key,
    required this.variation,
    required this.song,
    this.songList,
  });

  @override
  Widget build(BuildContext context) {
    return _variation1(context);
  }

  Widget _variation1(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await getIt<SongPlayerCubit>().loadAndPlay(
          context,
          song,
          songList: songList,
        );
      },
      child: MusicCard(
        variation: 1,
        thumbnailUrl: song.thumbnailUrl,
        title: song.title,
        subTitle: song.artistsNames
      )
    );
  }
}
