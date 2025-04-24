import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/core/getit.dart';

class SongPage extends StatefulWidget {
  final SongModel song;

  SongPage({super.key}) : song = getIt<SongPlayerCubit>().currentSong!;

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late bool isSongLiked;

  @override
  void initState() {
    super.initState();
    isSongLiked = widget.song.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = AdaptiveTheme.of(context).theme;

    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 46),
                _songCover(context),
                SizedBox(height: 30),
                songDetails(),
                SizedBox(height: 20),
                _songPlayer(themeData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row songDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                widget.song.artist,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        IconButton(
          onPressed: () {
            widget.song.isLiked = !isSongLiked;
            setState(() {
              isSongLiked = !isSongLiked;
            });
          },
          icon: Icon(
            isSongLiked ? Icons.favorite: Icons.favorite_outline_outlined,
            size: 30,
            color: isSongLiked ? Colors.red.shade400 : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _songPlayer(ThemeData themeData) {
    final playerCubit = getIt<SongPlayerCubit>();

    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is SongPlayerInitial) {
          return const CircularProgressIndicator();
        }
        if (state is SongPlayerLoaded) {
          return Column(
            children: [
              _progressSlider(context, playerCubit),
              _progressPosition(playerCubit),
              SizedBox(height: 20),
              _songControllerButtons(themeData, playerCubit),
            ],
          );
        }
        return Container();
      },
    );
  }

  Container _songControllerButtons(
    ThemeData themeData,
    SongPlayerCubit playerCubit,
  ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: themeData.colorScheme.secondaryContainer,
      ),
      child: IconButton(
        padding: const EdgeInsets.all(18.0),
        onPressed: () async {
          await playerCubit.loadSong(widget.song);
          playerCubit.playOrPause();
        },
        iconSize: 30,
        color: themeData.colorScheme.onSecondaryContainer,
        icon: Icon(
          playerCubit.audioPlayer.playing ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  Row _progressPosition(SongPlayerCubit playerCubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatDuration(playerCubit.songPosition)),
        Text(_formatDuration(playerCubit.songDuration)),
      ],
    );
  }

  SliderTheme _progressSlider(
    BuildContext context,
    SongPlayerCubit playerCubit,
  ) {
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
        value: playerCubit.songPosition.inSeconds.toDouble(),
        min: 0,
        max: playerCubit.songDuration.inSeconds.toDouble(),
        onChanged: (value) {
          playerCubit.seekTo(Duration(seconds: value.toInt()));
        },
      ),
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

  Widget _songCover(BuildContext context) {
    double size = MediaQuery.of(context).size.width - 64;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.song.thumbnailUrl),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text('Now Playing', style: TextStyle(color: Colors.white)),
      leading: BackButton(
        onPressed: () {
          try {
            context.pop();
          } catch (e) {
            context.go('/404');
          }
        },
        color: Colors.white,
      ),
    );
  }
}
