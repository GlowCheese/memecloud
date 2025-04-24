import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:dartz/dartz.dart' as dartz;

class NewReleasesSection extends StatefulWidget {
  const NewReleasesSection({super.key});

  @override
  State<NewReleasesSection> createState() => _NewReleasesSectionState();
}

class _NewReleasesSectionState extends State<NewReleasesSection> {
  final _getSongList = getIt<SupabaseSongsApi>().fetchSongList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        SizedBox(height: 200, child: _songListFutureDisplay()),
      ],
    );
  }

  FutureBuilder<dartz.Either<dynamic, dynamic>> _songListFutureDisplay() {
    return FutureBuilder<dartz.Either>(
      future: _getSongList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading songs ${snapshot.error}'));
        }

        final songsEither = snapshot.data!;
        return songsEither.fold(
          (error) => Center(child: Text('Error: $error')),
          (songs) => _songListDisplay(songs),
        );
      },
    );
  }

  ListView _songListDisplay(songs) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _songCardDisplay(context, song);
      },
    );
  }

  Padding _songCardDisplay(BuildContext context, song) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async => await getIt<SongPlayerCubit>().loadAndPlay(song),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: song.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, err) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 140,
              child: Text(
                song.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 140,
              child: Text(
                song.artist ?? 'Unknown',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _header() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bài hát mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
        ],
      ),
    );
  }
}
