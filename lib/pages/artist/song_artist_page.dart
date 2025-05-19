import 'package:flutter/material.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/components/song_tile.dart';
import 'package:memecloud/utils/common.dart';

class SongArtistPage extends StatelessWidget {
  final ArtistModel artist;
  final List<SongModel> songs;

  const SongArtistPage({super.key, required this.artist, required this.songs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero section with artist info
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Artist image with gradient overlay
                  Image.network(artist.thumbnailUrl, fit: BoxFit.cover),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorScheme.surface.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Artist info
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artist.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (artist.realname != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            artist.realname!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${songs.length} songs',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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

          // Songs list
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = songs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SongTile(
                    song: song,
                    onTap: () {
                      // TODO: Handle song tap
                    },
                  ),
                );
              }, childCount: songs.length),
            ),
          ),
        ],
      ),
    );
  }
}
