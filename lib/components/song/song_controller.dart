import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/models/song_model.dart';

class SongControllerView extends StatelessWidget {
  final SongModel song;
  final bool hasSlider;
  final SongPlayerCubit playerCubit = getIt<SongPlayerCubit>();

  SongControllerView({super.key, required this.song, this.hasSlider = true});

  @override
  Widget build(BuildContext context) {
    if (!hasSlider) return _songControllerButtons();
    return Column(
      children: [
        _progressSlider(context),
        SizedBox(height: 20),
        _songControllerButtons(),
      ],
    );
  }

  StreamBuilder _progressSlider(BuildContext context) {
    return StreamBuilder(
      stream: playerCubit.audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data as Duration? ?? Duration.zero;
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.grey.shade700,
                trackHeight: 4.0,

                thumbColor: Colors.white,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
                overlayColor: Colors.blue.withAlpha(32),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),

                trackShape: RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                min: 0,
                max: song.duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  await playerCubit.seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position)),
                Text(_formatDuration(song.duration)),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    // ignore: non_constant_identifier_names
    final minutes_str = minutes.toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60);
    // ignore: non_constant_identifier_names
    final seconds_str = seconds.toString().padLeft(2, '0');
    return '$minutes_str:$seconds_str';
  }

  Widget _songControllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _shuffleButton(),
        _seekPreviousButton(),
        _playOrPauseButton(),
        _seekNextButton(),
        _speedButton(),
      ],
    );
  }

  IconButton _seekNextButton() {
    return IconButton(
      onPressed: () async => await playerCubit.seekToNext(),
      icon: Icon(Icons.skip_next, color: Colors.white),
      iconSize: 35,
    );
  }

  StreamBuilder<bool> _playOrPauseButton() {
    return StreamBuilder<bool>(
      stream: playerCubit.audioPlayer.playingStream,
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.greenAccent.shade700,
          ),
          child: IconButton(
            padding: const EdgeInsets.all(18.0),
            onPressed: () => playerCubit.playOrPause(),
            iconSize: 30,
            color: Colors.white,
            icon: Icon(snapshot.data == true ? Icons.pause : Icons.play_arrow),
          ),
        );
      },
    );
  }

  IconButton _seekPreviousButton() {
    return IconButton(
      onPressed: () async => await playerCubit.seekToPrevious(),
      iconSize: 35,
      icon: Icon(Icons.skip_previous, color: Colors.white),
    );
  }

  StreamBuilder<bool> _shuffleButton() {
    return StreamBuilder<bool>(
      stream: playerCubit.audioPlayer.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        late final Color shuffleIconColor;
        if (snapshot.data == true) {
          shuffleIconColor = Colors.greenAccent.shade400;
        } else {
          shuffleIconColor = Colors.white;
        }
        return IconButton(
          onPressed: () async => await playerCubit.toggleShuffleMode(),
          iconSize: 35,
          icon: Icon(Icons.shuffle_rounded, color: shuffleIconColor),
        );
      },
    );
  }

  Widget _speedButton() {
    return StreamBuilder<double>(
      stream: playerCubit.audioPlayer.speedStream,
      builder: (context, snapshot) {
        final currentSpeed = snapshot.data ?? 1.0;
        return SizedBox(
          width: 50,
          child: Center(
            child: GestureDetector(
              onTap: () async => await playerCubit.toggleSongSpeed(),
              child: Text('${currentSpeed}x', style: TextStyle(fontSize: 18)),
            ),
          ),
        );
      },
    );
  }
}
