import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/core/getit.dart';

class SongControllerView extends StatefulWidget {
  const SongControllerView({super.key});

  @override
  State<SongControllerView> createState() => _SongControllerViewState();
}

class _SongControllerViewState extends State<SongControllerView> {
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  late StreamSubscription<Duration> _positionSub;
  late StreamSubscription<Duration?> _durationSub;
  final SongPlayerCubit playerCubit = getIt<SongPlayerCubit>();
  
  @override
  void initState() {
    super.initState();

    final audioPlayer = playerCubit.audioPlayer;

    _positionSub = audioPlayer.positionStream.listen((position) {
      setState(() => songPosition = position);
    });
    _durationSub = audioPlayer.durationStream.listen((duration) {
      setState(() => songDuration = duration ?? songDuration);
    });
  }

  @override
  void dispose() async {
    _positionSub.cancel();
    _durationSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _progressSlider(context),
        _progressPosition(),
        SizedBox(height: 20),
        _songControllerButtons(),
      ],
    );
  }

  SliderTheme _progressSlider(BuildContext context) {
    return SliderTheme(
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
        value: songPosition.inSeconds.toDouble(),
        min: 0,
        max: songDuration.inSeconds.toDouble(),
        onChanged: (value) async {
          await playerCubit.seekTo(Duration(seconds: value.toInt()));
        },
      ),
    );
  }

  Row _progressPosition() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatDuration(songPosition)),
        Text(_formatDuration(songDuration)),
      ],
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
    final colorScheme = AdaptiveTheme.of(context).theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () async => await playerCubit.toggleShuffleMode(),
          iconSize: 35,
          icon: Icon(
            Icons.shuffle_rounded,
            color:
                playerCubit.shuffleMode
                    ? colorScheme.primary
                    : colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () async => await playerCubit.seekToPrevious(),
          iconSize: 35,
          icon: Icon(Icons.skip_previous),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.secondaryContainer,
          ),
          child: IconButton(
            padding: const EdgeInsets.all(18.0),
            onPressed: () => playerCubit.playOrPause(),
            iconSize: 30,
            color: colorScheme.onSecondaryContainer,
            icon: Icon(
              playerCubit.audioPlayer.playing
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
        ),
        IconButton(
          onPressed: () async => await playerCubit.seekToNext(),
          icon: Icon(Icons.skip_next),
          iconSize: 35,
        ),
        SizedBox(
          width: 50,
          child: Center(
            child: GestureDetector(
              onTap: () async => await playerCubit.toggleSongSpeed(),
              child: Text(
                '${playerCubit.currentSongSpeed}x',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        )
      ],
    );
  }
}