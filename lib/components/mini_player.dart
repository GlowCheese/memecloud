import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_cubit.dart';
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

class _MiniPlayer extends StatefulWidget {
  final SongPlayerCubit playerCubit;
  final bool isSongLoaded;
  final SongModel song;

  const _MiniPlayer(
    this.playerCubit, {
    required this.isSongLoaded,
    required this.song,
  });

  @override
  State<_MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<_MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final adaptiveTheme = AdaptiveTheme.of(context);
    return getIt<ApiKit>().paletteColorsWidgetBuider(widget.song.thumbnailUrl, (
      List<Color> paletteColors,
    ) {
      late final domBg, subDomBg;
      if (adaptiveTheme.mode.isDark) {
        domBg = adjustLightness(paletteColors.first, 0.2);
        subDomBg = adjustLightness(paletteColors.last, 0.3);
      } else {
        domBg = adjustLightness(paletteColors.first, 0.5);
        subDomBg = adjustLightness(paletteColors.last, 0.6);
      }

      Color onBgColor = getTextColor(domBg);
      Color playButtonColor = getTextColor(paletteColors.first);

      return Positioned(
        bottom: 10,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () async {
            if (widget.isSongLoaded) {
              if (context.mounted) {
                context.push('/song_play');
              }
            }
          },
          child: miniPlayerSongDetails(
            domBg,
            subDomBg,
            onBgColor,
            playButtonColor,
          ),
        ),
      );
    });
  }

  Container miniPlayerSongDetails(
    Color domBg,
    Color subDomBg,
    Color onBgColor,
    Color playButtonColor,
  ) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [domBg, subDomBg],
          stops: [0.0, 0.8],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          miniThumbnail(playButtonColor),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bọc Column trong Flexible
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.title,
                        style: TextStyle(
                          color: onBgColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        widget.song.artistsNames,
                        style: TextStyle(
                          color: onBgColor.withAlpha(180),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Row(
                  children: [
                    IconButton(
                      icon:
                          widget.song.isLiked!
                              ? Icon(Icons.favorite_rounded, color: Colors.red)
                              : (Icon(
                                Icons.favorite_outline_rounded,
                                color: onBgColor,
                              )),
                      onPressed: () {
                        if (widget.isSongLoaded) {
                          setState(
                            () => getIt<LikedSongsCubit>().toggleSongIsLiked(
                              widget.song,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      color: onBgColor,
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        if (widget.isSongLoaded) {
                          widget.playerCubit.seekToNext();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  Stack miniThumbnail(Color playButtonColor) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
          child: CachedNetworkImage(
            imageUrl: widget.song.thumbnailUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.isSongLoaded) {
              widget.playerCubit.playOrPause();
            }
          },
          child: Icon(
            widget.playerCubit.isPlaying ? Icons.pause : Icons.play_arrow,
            color: playButtonColor,
          ),
        ),
      ],
    );
  }
}
