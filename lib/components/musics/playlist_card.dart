import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/musics/music_card.dart';

class PlaylistCard {
  final Key? key;
  final bool fetchNew;
  final PlaylistModel playlist;
  PlaylistCard({this.key, required this.playlist, this.fetchNew = true});

  Widget _anotIcon() {
    return FaIcon(
      FontAwesomeIcons.barsStaggered,
      size: 16,
      color: Colors.amber.shade100,
    );
  }

  Widget _gestureDetectorWrapper({Key? key, required Widget child}) {
    return Builder(
      key: key,
      builder: (context) {
        return GestureDetector(
          onTap:
              () => context.push(
                '/playlist_page',
                extra: fetchNew ? playlist.id : playlist,
              ),
          child: child,
        );
      },
    );
  }

  /// general purpose
  Widget variant1() {
    return _gestureDetectorWrapper(
      key: key,
      child: MusicCard(
        variant: 1,
        icon: _anotIcon(),
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Playlist • ${playlist.artistsNames}',
      ),
    );
  }

  /// almost looks like variant1 except bigger thumbnail
  Widget variant2({required double size}) {
    return _gestureDetectorWrapper(
      key: key,
      child: MusicCard(
        variant: 3,
        width: size,
        icon: _anotIcon(),
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: 'Playlist • ${playlist.artistsNames}',
      ),
    );
  }

  /// biggest thumbnail, suitable in a grid
  Widget variant3({required double width, required double height}) {
    return _gestureDetectorWrapper(
      child: MusicCard(
        variant: 4,
        thumbnailUrl: playlist.thumbnailUrl,
        title: playlist.title,
        subTitle: playlist.artistsNames,
        width: width,
        height: height,
      ),
    );
  }
}
