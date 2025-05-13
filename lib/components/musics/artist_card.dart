import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/components/musics/music_card.dart';

class ArtistCard extends StatelessWidget {
  /// must be between 1 and 2.
  final int variation;
  final ArtistModel artist;
  final bool pushReplacement;

  const ArtistCard({
    super.key,
    required this.variation,
    required this.artist,
    this.pushReplacement = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (pushReplacement) {
          context.pushReplacement('/artist_page', extra: artist.alias);
        } else {
          context.push('/artist_page', extra: artist.alias);
        }
      },
      child: MusicCard(
        variation: variation,
        thumbnailUrl: artist.thumbnailUrl,
        title: artist.name,
        subTitle: 'Nghệ sĩ',
      ),
    );
  }
}
