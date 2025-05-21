import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/artist_model.dart';

class FollowedArtistTile extends StatelessWidget {
  final ArtistModel artist;

  const FollowedArtistTile({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(artist.thumbnailUrl)),
      title: Text(artist.name),
      onTap: () => _toArtistPage(context),
    );
  }

  void _toArtistPage(BuildContext context) {
    context.push('/artist_page', extra: artist.alias);
  }
}
