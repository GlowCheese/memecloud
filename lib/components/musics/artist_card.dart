import 'package:flutter/material.dart';
import 'package:memecloud/components/musics/default_music_card.dart';
import 'package:memecloud/models/artist_model.dart';


class ArtistCard extends StatelessWidget {
  // must be between 1 and 1.
  final int variation;
  final ArtistModel artist;

  const ArtistCard({
    super.key,
    required this.variation,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return _variation1(context);
  }

  Widget _variation1(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      // onTap: () => context.push('/playlist_page', extra: playlist.id),
      child: DefaultMusicCard(
        thumbnailUrl: artist.thumbnailUrl,
        title: artist.name,
        subTitle: 'Nghệ sĩ'
      )
    );
  }
}
