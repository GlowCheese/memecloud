import 'package:flutter/material.dart';
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
      default:
        return _variant3(context);
    }
  }

  Widget _variant1(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist.id),
      child: MusicCard(
        variant: 1,
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Danh sách phát • ${playlist.artistsNames}',
      ),
    );
  }

  Widget _variant2(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist),
      child: MusicCard(
        variant: 3,
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Danh sách phát • ${playlist.artistsNames}',
      ),
    );
  }

  Widget _variant3(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: playlist.id),
      child: MusicCard(
        variant: 3,
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Danh sách phát • ${playlist.artistsNames}',
      ),
    );
  }
}
