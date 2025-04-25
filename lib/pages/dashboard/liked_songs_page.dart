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
    'body': FutureBuilder<dartz.Either>(
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

            if (likedSongs.isEmpty) {
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
              itemCount: likedSongs.length,
              itemBuilder: (context, index) {
                final song = likedSongs[index];
                return _buildSongListItem(context, song);
              },
            );
          },
        );
      },
    ),
  };
}

Widget _buildSongListItem(BuildContext context, SongModel song) {
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
              (context, url, err) => const Icon(Icons.music_note, size: 32),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              // Toggle like functionality will be implemented here
              // This will use the toggleLike usecase
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed:
                () async => await getIt<SongPlayerCubit>().loadAndPlay(context, song),
          ),
        ],
      ),
      onTap: () async => await getIt<SongPlayerCubit>().loadAndPlay(context, song),
    ),
  );
}
