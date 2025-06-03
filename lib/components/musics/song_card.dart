import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:memecloud/core/getit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/components/musics/music_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/song/song_download_button.dart';

class SongCard extends StatelessWidget {
  /// must be between 1 and 5.
  final int variant;
  final bool dimmed;
  final double? width;
  final double? height;
  final SongModel? song;
  final ChartSong? chartSong;
  final PlaylistModel? playlist;
  final List<SongModel>? songList;
  final playerCubit = getIt<SongPlayerCubit>();
  final Function()? onUnblacklistButtonPressed;
  late final audioPlayer = playerCubit.audioPlayer;

  SongCard({
    super.key,
    required this.variant,
    this.song,
    this.chartSong,
    this.songList,
    this.playlist,
    this.width,
    this.height,
    this.dimmed = false,
    this.onUnblacklistButtonPressed,
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
      case 4:
        return _variant4(context);
      default:
        return _variant5(context);
    }
  }

  Widget anotIcon() {
    return FaIcon(
      size: 16,
      color: Colors.lightBlue.shade100,
      FontAwesomeIcons.music,
    );
  }

  Widget gestureDectectorWrapper(
    BuildContext context, {
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () async {
        await playerCubit.loadAndPlay(
          context,
          song ?? chartSong!.song,
          playlist: playlist,
          songList: songList,
        );
      },
      child: child,
    );
  }

  // general purpose
  Widget _variant1(BuildContext context) {
    return gestureDectectorWrapper(
      context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: MusicCard(
              variant: 1,
              dimmed: dimmed,
              thumbnailUrl: song!.thumbnailUrl,
              title: song!.title,
              icon: anotIcon(),
              subTitle: song!.artistsNames,
            ),
          ),
          StreamBuilder(
            stream: audioPlayer.currentSongStream,
            builder: (context, snapshot) {
              return Offstage(
                offstage: snapshot.data?.id != song!.id,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GifView.asset(
                    'assets/gifs/eq_accent.gif',
                    width: 30,
                    height: 30,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// used in top chart page
  Widget _variant2(BuildContext context) {
    final song = chartSong!.song;
    final status = chartSong!.rankingStatus;
    final ranking = chartSong!.weeklyRanking;

    late final Color color;
    late final double fontSize;
    late final FontWeight fontWeight;

    if (ranking == 1) {
      color = Colors.yellow;
    } else if (ranking == 2) {
      color = Colors.grey;
    } else if (ranking == 3) {
      color = Colors.brown;
    } else {
      color = Colors.white;
    }

    if (ranking! <= 3) {
      fontSize = 30;
      fontWeight = FontWeight.bold;
    } else {
      fontSize = 22;
      fontWeight = FontWeight.normal;
    }

    late final Widget statusWidget;
    if (status == 0) {
      statusWidget = Divider(
        height: 4,
        indent: 6,
        endIndent: 6,
        color: Colors.white.withAlpha(156),
      );
    } else {
      late final Icon icon;
      if (status > 0) {
        icon = const Icon(Icons.arrow_drop_up, color: Colors.green);
      } else {
        icon = const Icon(Icons.arrow_drop_down, color: Colors.red);
      }
      statusWidget = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(offset: const Offset(0, 2), child: icon),
          Transform.translate(
            offset: const Offset(0, -2),
            child: Text(
              status.abs().toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    }

    return gestureDectectorWrapper(
      context,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              // Display the rank number
              '${chartSong!.weeklyRanking}',
              style: GoogleFonts.ribeyeMarrow(
                color: color,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(width: 22, child: statusWidget),
          const SizedBox(width: 10),
          Expanded(
            child: MusicCard(
              variant: 1,
              thumbnailUrl: song.thumbnailUrl,
              title: song.title,
              icon: anotIcon(),
              subTitle: song.artistsNames,
            ),
          ),
          StreamBuilder(
            stream: audioPlayer.currentSongStream,
            builder: (context, snapshot) {
              return Offstage(
                offstage: snapshot.data?.id != song.id,
                child: GifView.asset(
                  'assets/gifs/eq_accent.gif',
                  width: 30,
                  height: 30,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// used in blacklisted songs page
  Widget _variant3(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onUnblacklistButtonPressed,
            child: MusicCard(
              variant: 1,
              dimmed: true,
              icon: anotIcon(),
              thumbnailUrl: song!.thumbnailUrl,
              title: song!.title,
              subTitle: song!.artistsNames,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.block, color: Colors.red),
          onPressed: onUnblacklistButtonPressed,
        ),
      ],
    );
  }

  // used in playlist page for synchronous download
  Widget _variant4(BuildContext context) {
    return gestureDectectorWrapper(
      context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: MusicCard(
              variant: 1,
              thumbnailUrl: song!.thumbnailUrl,
              title: song!.title,
              icon: anotIcon(),
              subTitle: song!.artistsNames,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SongDownloadButton(song: song!, dimmed: true),
          ),
        ],
      ),
    );
  }

  // big thumbnail, best in grid
  Widget _variant5(BuildContext context) {
    return gestureDectectorWrapper(
      context,
      child: MusicCard(
        variant: 4,
        dimmed: dimmed,
        thumbnailUrl: song!.thumbnailUrl,
        title: song!.title,
        subTitle: song!.artistsNames,
        width: width!,
        height: height!,
      ),
    );
  }
}
