import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/data/models/song/song_dto.dart';
import 'package:memecloud/presentation/view/song_player/bloc/song_player_cubit.dart';
import 'package:memecloud/presentation/view/song_player/bloc/song_player_state.dart';
import 'package:memecloud/core/service_locator.dart';

Widget getMiniPlayer() {
  final playerCubit = serviceLocator<SongPlayerCubit>();
  return BlocBuilder<SongPlayerCubit, SongPlayerState>(
    bloc: playerCubit,
    builder: (context, state) {
      if (playerCubit.currentSong == null) {
        return SizedBox();
      } else {
        return MiniPlayer(playerCubit);
      }
    },
  );
}

class MiniPlayer extends StatelessWidget {
  final SongDto song;
  final SongPlayerCubit playerCubit;

  MiniPlayer(this.playerCubit, {super.key}) : song = playerCubit.currentSong!;

  @override
  Widget build(BuildContext context) {
    final themeData = AdaptiveTheme.of(context).theme;
    final colorScheme = themeData.colorScheme;

    return GestureDetector(
      onTap: () {
        context.push('/play_music');
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              song.coverUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: colorScheme.onTertiaryContainer,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: colorScheme.onTertiaryContainer,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: colorScheme.onTertiaryContainer,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  playerCubit.audioPlayer.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: colorScheme.onTertiaryContainer,
                ),
                onPressed: () {
                  playerCubit.playOrPause();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: colorScheme.onTertiaryContainer,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
