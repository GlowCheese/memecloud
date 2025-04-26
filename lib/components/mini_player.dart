import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/core/getit.dart';

Widget getMiniPlayer() {
  final playerCubit = getIt<SongPlayerCubit>();
  return BlocBuilder<SongPlayerCubit, SongPlayerState>(
    bloc: playerCubit,
    builder: (context, state) {
      if (playerCubit.currentSong == null) {
        return SizedBox();
      } else {
        return _MiniPlayer(playerCubit, state);
      }
    },
  );
}

class _MiniPlayer extends StatelessWidget {
  final SongModel song;
  final bool isSongLoaded;
  final SongPlayerCubit playerCubit;

  _MiniPlayer(this.playerCubit, SongPlayerState state)
    : song = playerCubit.currentSong!,
      isSongLoaded = state is SongPlayerLoaded;

  @override
  Widget build(BuildContext context) {
    final themeData = AdaptiveTheme.of(context).theme;
    final colorScheme = themeData.colorScheme;

    return GestureDetector(
      onTap: () async {
        if (isSongLoaded) {
          await song.loadIsLiked();
          if (context.mounted) {
            context.push('/song_play');
          }
        }
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
            child: CachedNetworkImage(
              imageUrl: song.thumbnailUrl,
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
            song.artistsNames,
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
                  if (isSongLoaded) {
                    playerCubit.playOrPause();
                  }
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
