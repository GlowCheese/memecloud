import 'package:flutter/material.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/utils/common.dart';

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
        const SizedBox(height: 20),
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
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade700,
                trackHeight: 4.0,

                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                overlayColor: Colors.blue.withAlpha(32),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),

                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                min: 0,
                max: song.duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  await playerCubit.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(position)),
                Text(formatDuration(song.duration)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _songControllerButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _shuffleButton(),
          _seekPreviousButton(),
          _playOrPauseButton(),
          _seekNextButton(),
          _speedButton(),
        ],
      ),
    );
  }

  IconButton _seekNextButton() {
    return IconButton(
      onPressed: playerCubit.seekToNext,
      color: Colors.white,
      icon: const Icon(Icons.skip_next),
      iconSize: 35,
    );
  }

  Container _playOrPauseButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.shade500,
      ),
      child: PlayOrPauseButton(
        song: song,
        iconSize: 30,
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }

  Widget _seekPreviousButton() {
    return IconButton(
      onPressed: playerCubit.seekToPrevious,
      iconSize: 35,
      color: Colors.white,
      icon: const Icon(Icons.skip_previous),
    );
  }

  StreamBuilder<bool> _shuffleButton() {
    return StreamBuilder<bool>(
      stream: playerCubit.audioPlayer.shuffleModeEnabledStream,
      initialData: playerCubit.shuffleMode,
      builder: (context, snapshot) {
        late final Color shuffleIconColor;
        if (snapshot.data == true) {
          shuffleIconColor = Colors.greenAccent.shade400;
        } else {
          shuffleIconColor = Colors.white;
        }
        return IconButton(
          onPressed: playerCubit.toggleShuffleMode,
          iconSize: 25,
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
              child: Text(
                '${currentSpeed}x',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}
