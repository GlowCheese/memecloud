import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';

Widget getMiniPlayer() {
  final playerCubit = getIt<SongPlayerCubit>();
  return BlocBuilder<SongPlayerCubit, SongPlayerState>(
    bloc: playerCubit,
    builder: (context, state) {
      if (state is SongPlayerLoaded) {
        return _MiniPlayer(
          playerCubit,
          isSongLoaded: true,
          song: state.currentSong,
        );
      } else if (state is SongPlayerLoading) {
        return _MiniPlayer(
          playerCubit,
          isSongLoaded: false,
          song: state.currentSong,
        );
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

  const _MiniPlayer(
    this.playerCubit, {
    required this.isSongLoaded,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return getIt<ApiKit>().dominantColorWidgetBuider(song.thumbnailUrl, (
      Color bgColor,
    ) {
      bgColor = adjustLightness(bgColor, 0.4);
      Color onBgColor = getTextColor(bgColor);

      return Positioned(
        bottom: 10,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () async {
            if (isSongLoaded) {
              if (context.mounted) {
                context.push('/song_play');
              }
            }
          },
          child: miniPlayerSongDetails(bgColor, onBgColor),
        ),
      );
    });
  }

  Container miniPlayerSongDetails(Color bgColor, Color onBgColor) {
    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: song.thumbnailUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          Flexible(
            child: ListTile(
              title: Text(
                song.title,
                style: TextStyle(
                  color: onBgColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                song.artistsNames,
                style: TextStyle(color: onBgColor, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    color: onBgColor,
                    icon: Icon(Icons.skip_previous),
                    onPressed: () {
                      if (isSongLoaded) {
                        playerCubit.seekToPrevious();
                      }
                    },
                  ),
                  IconButton(
                    color: onBgColor,
                    icon: Icon(
                      playerCubit.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (isSongLoaded) {
                        playerCubit.playOrPause();
                      }
                    },
                  ),
                  IconButton(
                    color: onBgColor,
                    icon: Icon(Icons.skip_next),
                    onPressed: () {
                      if (isSongLoaded) {
                        playerCubit.seekToNext();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
