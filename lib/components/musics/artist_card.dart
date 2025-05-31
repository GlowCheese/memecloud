import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/components/musics/music_card.dart';

class ArtistCard extends StatelessWidget {
  /// must be between 1 and 2.
  final int variant;
  final ArtistModel artist;
  final bool pushReplacement;

  const ArtistCard({
    super.key,
    required this.variant,
    required this.artist,
    this.pushReplacement = false,
  });

  Widget gestureDectectorWrapper(BuildContext context, Widget child) {
    return GestureDetector(
      onTap: () {
        if (pushReplacement) {
          context.pushReplacement('/artist_page', extra: artist.alias);
        } else {
          context.push('/artist_page', extra: artist.alias);
        }
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case 1:
        return _variation1(context);
      default:
        return _variation2(context);
    }
  }

  Widget anotIcon() {
    return FaIcon(
      size: 16,
      color: Colors.green.shade200,
      FontAwesomeIcons.microphoneLines
    );
  }

  // with subtitle 'Nghệ sĩ'
  Widget _variation1(BuildContext context) {
    return MusicCard(
      variant: 1,
      icon: anotIcon(),
      thumbnailUrl: artist.thumbnailUrl,
      title: artist.name,
      subTitle: 'Nghệ sĩ',
    );
  }

  // without subtitle
  Widget _variation2(BuildContext context) {
    return MusicCard(
      variant: 2,
      thumbnailUrl: artist.thumbnailUrl,
      title: artist.name,
    );
  }
}
