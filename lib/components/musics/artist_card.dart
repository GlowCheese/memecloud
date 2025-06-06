import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/components/musics/music_card.dart';

class ArtistCard extends StatelessWidget {
  /// must be between 1 and 3.
  final int variant;
  final double? size;
  final ArtistModel artist;
  final bool pushReplacement;

  const ArtistCard({
    super.key,
    required this.variant,
    required this.artist,
    this.size,
    this.pushReplacement = false,
  });

  Widget gestureDectectorWrapper(
    BuildContext context, {
    required Widget child,
  }) {
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
        return _variant1(context);
      case 2:
        return _variant2(context);
      default:
        return _variant3(context);
    }
  }

  Widget anotIcon() {
    return FaIcon(
      size: 16,
      color: Colors.green.shade200,
      FontAwesomeIcons.microphoneLines,
    );
  }

  // with subtitle 'Nghệ sĩ'
  Widget _variant1(BuildContext context) {
    return gestureDectectorWrapper(
      context,
      child: MusicCard(
        variant: 1,
        icon: anotIcon(),
        thumbnailUrl: artist.thumbnailUrl,
        title: artist.name,
        subTitle: 'Nghệ sĩ',
      ),
    );
  }

  // without subtitle
  Widget _variant2(BuildContext context) {
    return gestureDectectorWrapper(
      context,
      child: MusicCard(
        variant: 2,
        thumbnailUrl: artist.thumbnailUrl,
        title: artist.name,
      ),
    );
  }

  Widget _variant3(BuildContext context) {
    return Column(
      children: [
        gestureDectectorWrapper(
          context,
          child: MusicCard(
            variant: 4,
            width: size!,
            height: size!,
            thumbnailUrl: artist.thumbnailUrl,
            title: artist.name,
            rounded: true,
          ),
        ),
      ],
    );
  }
}
