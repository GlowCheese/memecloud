import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';

Map getBlacklistSongPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Blacklist Songs'),
    'bgColor': MyColorSet.redAccent,
    'body': BlacklistSongPage(key: ValueKey("blacklist song page")),
  };
}

class BlacklistSongPage extends StatefulWidget {
  const BlacklistSongPage({super.key});

  @override
  State<BlacklistSongPage> createState() => _BlacklistSongPageState();
}

class _BlacklistSongPageState extends State<BlacklistSongPage> {
  @override
  Widget build(BuildContext context) {
    final songs = getIt<ApiKit>().getBlacklistedSongs();
    return _SongListView(likedSongs: List<SongModel>.from(songs));
  }
}

class _SongListView extends StatefulWidget {
  final List<SongModel> likedSongs;

  const _SongListView({required this.likedSongs});

  @override
  State<_SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<_SongListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.likedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.white.withAlpha(140)),
            const SizedBox(height: 16),
            Text(
              'Danh sách trống',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withAlpha(200),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các bài hát trong sổ đen sẽ xuất hiện ở đây.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${widget.likedSongs.length} Blacklisted Songs',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.likedSongs.length,
              itemBuilder: (context, index) {
                final song = widget.likedSongs[index];
                return _BlacklistedSongItem(
                  song: song,
                  onRemoveFromBlacklist: () {
                    _removeFromBlacklist(song);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromBlacklist(SongModel song) async {
    try {
      await getIt<ApiKit>().setIsBlacklisted(song, false);
      setState(() {
        widget.likedSongs.removeWhere((s) => s.id == song.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${song.title} removed from blacklist'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from blacklist: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _BlacklistedSongItem extends StatelessWidget {
  final SongModel song;
  final VoidCallback onRemoveFromBlacklist;

  const _BlacklistedSongItem({
    required this.song,
    required this.onRemoveFromBlacklist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(80), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Dismissible(
          key: Key(song.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.green,
            child: const Icon(Icons.restore_from_trash, color: Colors.white),
          ),
          onDismissed: (_) => onRemoveFromBlacklist(),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  song.thumbnailUrl.isNotEmpty
                      ? Image.network(
                        song.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white54,
                        ),
                      ),
            ),
            title: Text(
              song.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.artistsNames,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withAlpha(125),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(song.duration),
                      style: TextStyle(
                        color: Colors.white.withAlpha(125),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white.withAlpha(125),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM yyyy').format(song.releaseDate),
                      style: TextStyle(
                        color: Colors.white.withAlpha(125),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.not_interested, color: Colors.red),
              onPressed: onRemoveFromBlacklist,
              tooltip: 'Remove from blacklist',
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
