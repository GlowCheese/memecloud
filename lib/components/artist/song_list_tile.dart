import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/components/song/like_button.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';
import 'package:memecloud/components/song/show_song_actions.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';

/// variant:
/// 1: play or pause button,
/// 2: add to playlist button, and require playlistId.
///
///
class SongListTile extends StatelessWidget {
  final SongModel song;
  final int? variant;
  final String? playlistId;
  final void Function(bool added)? onSongAdded;

  const SongListTile({
    super.key,
    required this.song,
    this.variant = 1,
    this.playlistId,
    this.onSongAdded,
  });

  @override
  Widget build(BuildContext context) {
    final playerCubit = getIt<SongPlayerCubit>();
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        final isCurrentSong =
            state is SongPlayerLoaded && state.currentSong.id == song.id;

        return StreamBuilder<Object>(
          stream: playerCubit.audioPlayer.playingStream,
          builder: (context, snapshot) {
            final isPlaying = isCurrentSong;
            return SizedBox(
              height: 90,
              child: Card(
                color: Colors.white10,
                elevation: isPlaying ? 8 : 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side:
                      isPlaying
                          ? BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2,
                          )
                          : BorderSide.none,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onLongPress: () => showSongBottomSheetActions(context, song),
                  onTap: () async {
                    await playerCubit.loadAndPlay(
                      context,
                      song,
                      songList: List<SongModel>.from([song]),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient:
                          isPlaying
                              ? LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.tertiary.withOpacity(0.1),
                                  Theme.of(
                                    context,
                                  ).colorScheme.tertiary.withOpacity(0.05),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                              : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Hero(
                                tag: 'song_${song.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: song.thumbnailUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondaryContainer,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.errorContainer,
                                          child: const Icon(Icons.music_note),
                                        ),
                                  ),
                                ),
                              ),
                              if (isPlaying)
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  song.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        isPlaying
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                    color:
                                        isPlaying
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    song.artistsNames,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SongLikeButton(song: song),
                          if (variant == 1)
                            PlayOrPauseButton(
                              song: song,
                              color:
                                  isPlaying
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                            )
                          else if (variant == 2)
                            IconButton(
                              onPressed: () async {
                                final res = await getIt<ApiKit>()
                                    .supabase
                                    .userPlaylist
                                    .addSongToPlaylist(
                                      playlistId: playlistId!,
                                      songId: song.id,
                                    );
                                onSongAdded?.call(res == "Thêm thành công");
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(res)));
                                }
                              },
                              icon: Icon(Icons.add),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
