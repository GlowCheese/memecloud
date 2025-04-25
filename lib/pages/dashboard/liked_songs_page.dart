import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';

Map getLikedSongsPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Liked Songs'),
    'body': LikedSongPage(),
  };
}

class LikedSongPage extends StatefulWidget {
  const LikedSongPage({super.key});

  @override
  State<LikedSongPage> createState() => _LikedSongPageState();
}

class _LikedSongPageState extends State<LikedSongPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dartz.Either>(
      future: getIt<SupabaseSongsApi>().getLikedSongsList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading songs: ${snapshot.error}'));
        }

        final songsEither = snapshot.data!;
        return songsEither.fold(
          (error) => Center(child: Text('Error: $error')),
          (songs) {
            // Filter only liked songs
            final likedSongs =
                (songs as List<dynamic>).where((song) => song.isLiked).toList();

            return _SongListView(likedSongs: likedSongs);
          },
        );
      },
    );
  }
}

class _SongListView extends StatefulWidget {
  const _SongListView({required this.likedSongs});

  final List likedSongs;

  @override
  State<_SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<_SongListView> {
  late List currentLikedSongs;

  @override
  void initState() {
    super.initState();
    currentLikedSongs = widget.likedSongs;
  }

  @override
  Widget build(BuildContext context) {
    if (currentLikedSongs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No liked songs yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.likedSongs.length,
      itemBuilder: (context, index) {
        final SongModel song = widget.likedSongs[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: song.thumbnailUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget:
                    (context, url, err) =>
                        const Icon(Icons.music_note, size: 32),
              ),
            ),
            title: Text(
              song.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              song.artistsNames,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    song.isLiked = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã unlike 1 bài hát!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    setState(() {
                      assert(currentLikedSongs.remove(song));
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed:
                      () async => await getIt<SongPlayerCubit>().loadAndPlay(
                        context,
                        song,
                      ),
                ),
              ],
            ),
            onTap:
                () async =>
                    await getIt<SongPlayerCubit>().loadAndPlay(context, song),
          ),
        );
      },
    );
  }
}
