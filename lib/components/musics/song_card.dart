import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/components/musics/music_card.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';

class SongCard extends StatelessWidget {
  /// must be between 1 and 2.
  final int variant;
  final SongModel? song;
  final ChartSong? chartSong;
  final PlaylistModel? playlist;
  final List<SongModel>? songList;

  const SongCard({
    super.key,
    required this.variant,
    this.song,
    this.chartSong,
    this.songList,
    this.playlist
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case 1:
        return _variant1(context);
      default:
        return _variant2(context);
    }
  }

  /// only show thumbnail, title, artists
  Widget _variant1(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await getIt<SongPlayerCubit>().loadAndPlay(
          context,
          song!,
          playlist: playlist,
          songList: songList,
        );
      },
      child: MusicCard(
        variant: 1,
        thumbnailUrl: song!.thumbnailUrl,
        title: song!.title,
        subTitle: song!.artistsNames,
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

    if (ranking <= 3) {
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
        icon = Icon(Icons.arrow_drop_up, color: Colors.green);
      } else {
        icon = Icon(Icons.arrow_drop_down, color: Colors.red);
      }
      statusWidget = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(offset: Offset(0, 2), child: icon),
          Transform.translate(
            offset: Offset(0, -2),
            child: Text(
              status.abs().toString(),
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () async {
        await getIt<SongPlayerCubit>().loadAndPlay(
          context,
          song,
          playlist: playlist,
          songList: songList,
        );
      },
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
              subTitle: song.artistsNames,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
