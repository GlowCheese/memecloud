import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';

class PlayOrPauseButton extends StatelessWidget {
  final SongModel song;
  final Color color;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  late final List<SongModel> songList;
  final playerCubit = getIt<SongPlayerCubit>();

  PlayOrPauseButton({
    super.key,
    required this.song,
    this.color = Colors.white,
    this.padding,
    this.iconSize,
    List<SongModel>? songList,
  }) {
    this.songList = songList ?? [song];
  }

  Widget _loadingButton(BuildContext context) {
    return CircularProgressIndicator();
  }

  Widget _playButton(BuildContext context, {required bool load}) {
    return IconButton(
      color: color,
      padding: padding,
      iconSize: iconSize,
      onPressed: () async {
        if (load) {
          await playerCubit.loadAndPlay(context, song, songList: songList);
        } else {
          playerCubit.playOrPause();
        }
      },
      icon: Icon(Icons.play_arrow),
    );
  }

  Widget _pauseButton(BuildContext context, {required bool load}) {
    return IconButton(
      color: color,
      padding: padding,
      iconSize: iconSize,
      onPressed: () async {
        if (load) {
          await playerCubit.loadAndPlay(context, song, songList: songList);
        } else {
          playerCubit.playOrPause();
        }
      },
      icon: Icon(Icons.pause),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is SongPlayerLoading && state.currentSong.id == song.id) {
          return _loadingButton(context);
        }
        if (state is! SongPlayerLoaded) {
          return _playButton(context, load: true);
        }

        if (state.currentSong.id != song.id) {
          return _playButton(context, load: true);
        }

        return StreamBuilder<bool>(
          stream: playerCubit.audioPlayer.playingStream,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return _pauseButton(context, load: false);
            }
            return _playButton(context, load: false);
          },
        );
      },
    );
  }
}
