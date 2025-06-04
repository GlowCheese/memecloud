import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/musics/music_card.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/utils/images.dart';

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
      key: key,
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

  Widget variant4({
    required double gap,
    required double height,
    required String tag,
  }) {
    Color tlColor = Colors.grey.shade500;
    Color brColor = Colors.grey.shade900;

    return _gestureDetectorWrapper(
      child: StatefulBuilder(
        key: key,
        builder: (context, setState) {
          getDominantColor(playlist.thumbnailUrl).then((data) {
            if (context.mounted) {
              setState(() {
                tlColor = adjustColor(data!, l: 0.6);
                brColor = adjustColor(data, l: 0.2);
              });
            }
          });

          return Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tlColor, brColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(gap),
            alignment: Alignment.center,
            child: Row(
              spacing: gap,
              children: [
                getImage(playlist.thumbnailUrl, height - 2 * gap),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(60),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(
                          tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        playlist.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          playlist.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
