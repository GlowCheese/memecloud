import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/models/playlist_model.dart';

import '../../apis/apikit.dart';
import '../../core/getit.dart';

class PlaylistScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistScreen({Key? key, required this.playlistId}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late Future<PlaylistModel?> _playlistFuture;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  void _loadPlaylist() {
    _playlistFuture = getIt<ApiKit>().getPlaylistInfo(widget.playlistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<PlaylistModel?>(
        future: _playlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Không tìm thấy playlist',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final playlist = snapshot.data!;
          return CustomScrollView(
            slivers: [
              // App Bar với nút back và cast
              SliverAppBar(
                backgroundColor: Colors.black,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.cast, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              // Header với thumbnail và thông tin playlist
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: playlist.thumbnailUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[800],
                                width: 110,
                                height: 110,
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[800],
                                width: 110,
                                height: 110,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thông tin playlist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Playlist • ${playlist.songs?.length ?? 0} Tracks • ${_formatDuration(playlist.songs)}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                            // Text(
                            //   '1h ago',
                            //   style: TextStyle(
                            //     color: Colors.grey[400],
                            //     fontSize: 13,
                            //   ),
                            // ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Like, More, Shuffle buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Like button
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
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '100,7K',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // More options
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: () {
                          // Hiển thị menu tùy chọn cho bài hát
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.grey[900],
                            builder:
                                (context) =>
                                    SongOptionsSheet(song: playlist.songs![0]),
                          );
                        },
                      ),
                      const Spacer(),
                      // Shuffle button
                      Icon(Icons.shuffle, color: Colors.grey[400], size: 22),
                      const SizedBox(width: 24),
                      // Play button
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Genre tags
              // SliverToBoxAdapter(
              //   child: Container(
              //     height: 48,
              //     margin: const EdgeInsets.only(top: 16, bottom: 16),
              //     child: ListView(
              //       scrollDirection: Axis.horizontal,
              //       padding: const EdgeInsets.symmetric(horizontal: 16),
              //       children: [
              //         _buildGenreTag('# Electronic'),
              //         _buildGenreTag('# Dubstep'),
              //         _buildGenreTag('# Synthwave'),
              //       ],
              //     ),
              //   ),
              // ),

              // Description
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playlist.description != null &&
                          playlist.description!.isNotEmpty)
                        Text(
                          playlist.description!,
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 14,
                          ),
                        )
                      else
                        Text(
                          'Updates weekly with popular tracks in Vietnam.',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 14,
                          ),
                        ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[400],
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft,
                        ),
                        child: const Text('Show more'),
                      ),
                    ],
                  ),
                ),
              ),

              // Danh sách bài hát
              if (playlist.songs != null && playlist.songs!.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = playlist.songs![index];
                    return SongListTile(song: song, index: index);
                  }, childCount: playlist.songs!.length),
                ),
            ],
          );
        },
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

  Widget _buildGenreTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          tag,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
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
                      song.artistsNames ?? 'Unknown Artist',
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

  String _formatPlays(int index) {
    // Giả lập số lượt nghe
    List<String> plays = ['67,5K', '20,1K', '205K', '35,6K', '89,7K', '112K'];
    return plays[index % plays.length];
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
