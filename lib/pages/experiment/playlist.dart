import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class PlaylistScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getPlaylistInfo(widget.playlistId),
      onNull: (context) {
        return Center(
          child: Text("Playlist with id ${widget.playlistId} doesn't exist!"),
        );
      },
      onData: (context, data) {
        final playlist = data!;
        return CustomScrollView(
          slivers: [
            _appBar(context),
            _generalDetails(playlist),
            _playlistDescription(playlist),

            if (playlist.songs != null && playlist.songs!.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = playlist.songs![index];
                  return GestureDetector(
                    onTap: () {
                      getIt<SongPlayerCubit>().loadAndPlay(
                        context,
                        song,
                        songList: playlist.songs!,
                      );
                    },
                    child: SongListTile(song: song, index: index),
                  );
                }, childCount: playlist.songs!.length),
              ),
          ],
        );
      },
    );
  }

  SliverToBoxAdapter _playlistDescription(PlaylistModel playlist) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.teal.shade500,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            playlist.description!,
            style: GoogleFonts.mali(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontStyle: FontStyle.italic
            )
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _generalDetails(PlaylistModel playlist) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: playlist.thumbnailUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      playlist.followed == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          playlist.followed == true
                              ? Colors.white
                              : Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '100,7K',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Thông tin playlist
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Playlist • ${playlist.songs?.length ?? 0} Tracks • ${_formatDuration(playlist.songs)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'By ${playlist.artistsNames ?? "Trending Music"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  _playlistControlButtons(playlist),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _playlistControlButtons(PlaylistModel playlist) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow, color: Colors.black),
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          constraints: BoxConstraints(minWidth: 35, minHeight: 35),
          padding: const EdgeInsets.all(4),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
          onPressed: () {
            // Hiển thị menu tùy chọn cho bài hát
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.grey[900],
              builder: (context) => SongOptionsSheet(song: playlist.songs![0]),
            );
          },
        ),
      ],
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.grey.shade900,
                ),
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(height: 40, child: MySearchBar(variation: 2)),
            ),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  String _formatDuration(List<SongModel>? songs) {
    if (songs == null || songs.isEmpty) return '0:00';
    int totalSeconds = 0;
    for (var song in songs) {
      // sum up all song durations
      totalSeconds += song.duration.inSeconds;
    }

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Widget _buildGenreTag(String tag) {
  //   return Container(
  //     margin: const EdgeInsets.only(right: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[900],
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //       child: Text(
  //         tag,
  //         style: const TextStyle(color: Colors.white, fontSize: 14),
  //       ),
  //     ),
  //   );
  // }
}

class SongListTile extends StatelessWidget {
  final SongModel song;
  final int index;

  const SongListTile({Key? key, required this.song, required this.index})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          // Song thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: song.thumbnailUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) =>
                      Container(color: Colors.grey[800], width: 50, height: 50),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[800],
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
            ),
          ),
          const SizedBox(width: 12),

          // Song info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Row(
                  children: [
                    Text(
                      song.artistsNames,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    //Icon star if
                    // Icon(Icons.star_border, color: Colors.grey[400], size: 14),
                  ],
                ),
                // Row(
                //   children: [
                //     Icon(Icons.play_arrow, color: Colors.grey[400], size: 14),
                //     const SizedBox(width: 4),
                //     Text(
                //       '${_formatPlays(index)}',
                //       style: TextStyle(color: Colors.grey[400], fontSize: 12),
                //     ),
                //     const SizedBox(width: 8),
                //     Text(
                //       '•  ${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                //       style: TextStyle(color: Colors.grey[400], fontSize: 12),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),

          // More options
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            onPressed: () {
              // Hiển thị menu tùy chọn cho bài hát
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.grey[900],
                builder: (context) => SongOptionsSheet(song: song),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const ArtistCard({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: artist.thumbnailUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) =>
                      Container(color: Colors.grey[800], width: 80, height: 80),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[800],
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SongOptionsSheet extends StatelessWidget {
  final SongModel song;

  const SongOptionsSheet({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_add, color: Colors.white),
            title: const Text(
              'Thêm vào playlist',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.white),
            title: const Text(
              'Tải xuống',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.white),
            title: const Text('Chia sẻ', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Xem nghệ sĩ',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
