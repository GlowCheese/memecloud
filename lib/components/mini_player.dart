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
      if (state is SongPlayerLoaded) {
        return _MiniPlayer(playerCubit, isSongLoaded: true, song: state.currentSong);
      } else if (state is SongPlayerLoading) {
        return _MiniPlayer(playerCubit, isSongLoaded: false, song: state.currentSong);

      } else {
        return SizedBox();
      }
    },
  );
}

class _MiniPlayer extends StatelessWidget {
  final SongPlayerCubit playerCubit;
  final bool isSongLoaded;
  final SongModel song;

  const _MiniPlayer(this.playerCubit, {required this.isSongLoaded, required this.song});

  @override
  Widget build(BuildContext context) {
    final themeData = AdaptiveTheme.of(context).theme;
    final colorScheme = themeData.colorScheme;

    return GestureDetector(
      onTap: () async {
        if (isSongLoaded) {
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
