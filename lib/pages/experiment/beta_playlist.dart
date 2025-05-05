import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/playlist_model.dart';

class PlaylistPage extends StatefulWidget {
  final String playlistId;

  const PlaylistPage({super.key, required this.playlistId});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SongModel> _filteredSongs = [];
  bool _isLiked = false;
  int _likeCount = 0;

  String _formatDuration(List<SongModel>? songs) {
    if (songs == null || songs.isEmpty) return '0 phút';

    int totalSeconds = 0;
    for (var song in songs) {
      totalSeconds += song.duration.inSeconds;
    }

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours giờ $minutes phút';
    } else {
      return '$minutes phút';
    }
  }

  void _filterSongs(String query, List<SongModel>? songs) {
    if (songs == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredSongs = List.from(songs);
      } else {
        _filteredSongs =
            songs
                .where(
                  (song) =>
                      song.title.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _toggleLike(PlaylistModel playlist) {
    // Call API
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLiked ? 'Đã thích playlist' : 'Đã bỏ thích playlist'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadPlaylist(PlaylistModel playlist) {
    // ADD LOGIC DOWNLOAD PLAYLIST HERE
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tải xuống playlist...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getPlaylistInfo(widget.playlistId),
      onData: (context, data) {
        final playlist = data!;
        final songs = playlist.songs ?? [];
        if (_filteredSongs.isEmpty && songs.isNotEmpty) {
          _filteredSongs = List.from(songs);
        }

        if (_likeCount == 0) {
          _likeCount = 1000;
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(playlist),
            SliverToBoxAdapter(child: _buildPlaylistHeader(playlist, songs)),
            SliverToBoxAdapter(child: _buildSearchBar(songs)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= _filteredSongs.length) return null;
                return _buildSongItem(_filteredSongs[index], index);
              }),
            ),
          ],
        );
      },
      onNull: (context) {
        return Center(
          child: Text("Playlist with id ${widget.playlistId} doesn't exist!"),
        );
      },
    );
  }

  Widget _buildAppBar(PlaylistModel playlist) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      backgroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        expandedTitleScale: 1.2,
        title: Text(
          playlist.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(playlist.thumbnailUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistHeader(PlaylistModel playlist, List<SongModel> songs) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (playlist.artistsNames != null &&
              playlist.artistsNames!.isNotEmpty)
            Text(
              playlist.artistsNames!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${songs.length} bài hát',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Text(
                _formatDuration(songs),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_likeCount',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          if (playlist.description != null &&
              playlist.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Text(
            //   // playlist.description!,
            //   style: const TextStyle(color: Colors.white, fontSize: 14),
            //   maxLines: 3,
            //   overflow: TextOverflow.ellipsis,
            // ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.play_circle_filled,
                label: 'Phát',
                onTap: () {
                  // Thêm logic phát nhạc
                },
                isPrimary: true,
              ),
              _buildActionButton(
                icon: Icons.shuffle,
                label: 'Ngẫu nhiên',
                onTap: () {
                  // Thêm logic phát ngẫu nhiên
                },
              ),
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: 'Thích',
                onTap: () => _toggleLike(playlist),
              ),
              _buildActionButton(
                icon: Icons.download,
                label: 'Tải về',
                onTap: () => _downloadPlaylist(playlist),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.blue : Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.blue : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(List<SongModel> songs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[850],
      child: TextField(
        controller: _searchController,
        onChanged: (query) => _filterSongs(query, songs),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài hát',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSongItem(SongModel song, int index) {
    return Container(
      color: index.isEven ? Colors.grey[900] : Colors.grey[850],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            song.thumbnailUrl ?? 'https://via.placeholder.com/60',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[700],
                child: Icon(Icons.music_note, color: Colors.grey[400]),
              );
            },
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artistsNames ?? 'Unknown Artist',
          style: TextStyle(color: Colors.grey[400]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (song.duration != null)
              Text(
                _formatSongDuration(song.duration.inSeconds),
                style: TextStyle(color: Colors.grey[400]),
              ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
              color: Colors.grey[800],
              onSelected: (value) {
                // Xử lý các tùy chọn
                switch (value) {
                  case 'download':
                    _downloadSong(song);
                    break;
                  case 'add_to_playlist':
                    _addToPlaylist(song);
                    break;
                  case 'share':
                    _shareSong(song);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Text(
                        'Tải xuống',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'add_to_playlist',
                      child: Text(
                        'Thêm vào playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Text(
                        'Chia sẻ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
            ),
          ],
        ),
        onTap: () {
          // Xử lý khi chọn bài hát
          print('Phát bài hát: ${song.title}');
        },
      ),
    );
  }

  String _formatSongDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _downloadSong(SongModel song) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang tải xuống: ${song.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToPlaylist(SongModel song) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${song.title} vào playlist'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareSong(SongModel song) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia sẻ: ${song.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
