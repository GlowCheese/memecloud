import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/musics/music_card.dart';

class PlaylistCard extends StatelessWidget {
  /// must be between 1 and 3.
  final int variant;
  final PlaylistModel playlist;

  const PlaylistCard({
    super.key,
    required this.variant,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case 1:
        return _variant1(context);
      case 2:
        return _variant2(context);
      case 3:
        return _variant3(context);
      default:
        return _variant4(context);
    }
  }

  Widget anotIcon() {
    return FaIcon(
      FontAwesomeIcons.barsStaggered,
      size: 16,
      color: Colors.amber.shade100,
    );
  }

  Widget _variant1(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist.id),
      child: MusicCard(
        variant: 1,
        icon: anotIcon(),
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Playlist • ${playlist.artistsNames}',
      ),
    );
  }

  Widget _variant2(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist),
      child: MusicCard(
        variant: 3,
        icon: anotIcon(),
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Playlist • ${playlist.artistsNames}',
      ),
    );
  }

  Widget _variant3(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist.id),
      child: MusicCard(
        variant: 3,
        icon: anotIcon(),
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Playlist • ${playlist.artistsNames}',
      ),
    );
  }

  /// Album card using MusicCard variant 4
  Widget _variant4(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist),
      child: MusicCard(
        variant: 4, // Using the new album variant
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: playlist.artistsNames,
      ),
    );
  }
}
