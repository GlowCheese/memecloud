import 'dart:async';

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
  final playerCubit = getIt<SongPlayerCubit>();
  late final audioPlayer = playerCubit.audioPlayer;

  PlayOrPauseButton({
    super.key,
    required this.song,
    this.color = Colors.white,
    this.padding,
    this.iconSize,
  });

  void onPressed(BuildContext context, bool load) {
    if (load) {
      unawaited(playerCubit.loadAndPlay(context, song));
    } else {
      playerCubit.playOrPause();
    }
  }

  Widget _button(BuildContext context, bool load, Icon icon) {
    return IconButton(
      color: color,
      padding: padding,
      iconSize: iconSize,
      onPressed: () => onPressed(context, load),
      icon: icon,
    );
  }

  Widget _playButton(BuildContext context, bool load) {
    return _button(context, load, Icon(Icons.play_arrow));
  }

  Widget _pauseButton(BuildContext context, bool load) {
    return _button(context, load, Icon(Icons.pause));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return _playButton(context, true);
        }

        return StreamBuilder(
          stream: audioPlayer.playingStream,
          builder: (context, snapshot) {
            if (audioPlayer.currentSong?.id != song.id) {
              return _playButton(context, true);
            }
            if (snapshot.data == true) {
              return _pauseButton(context, false);
            }
            return _playButton(context, false);
          },
        );
      },
    );
  }
}
