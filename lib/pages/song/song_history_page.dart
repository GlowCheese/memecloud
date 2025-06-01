import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memecloud/blocs/song_player/custom_audio_player.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/miscs/simple_section.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';

class ScrollableSongHistoryPage extends StatelessWidget {
  final PlaylistModel? playlist;

  const ScrollableSongHistoryPage({super.key, this.playlist});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = getIt<CustomAudioPlayer>();
    return StreamBuilder(
      stream: audioPlayer.upcomingSongsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SpinKitPumpingHeart(color: Colors.blue);
        }

        final listenHistory = audioPlayer.listenHistory.sublist(
          max(0, audioPlayer.listenHistory.length - 5),
        ); // only show the last 5 songs from history

        final upcomingSongs = snapshot.data!;
        return SimpleScrollablePage(
          title: 'Lịch sử phát',
          bgColor: MyColorSet.cyan,
          spacing: 12,
          items: [
            SizedBox(),

            for (int i in listenHistory)
              SongCard(
                key: ValueKey('previous_$i'),
                variant: 1,
                song: audioPlayer.songList[i],
                playlist: playlist,
                dimmed: i != listenHistory.last,
              ),

            SimpleSection(
              title: 'Bài tiếp theo',
              showAllButton: StreamBuilder(
                stream: audioPlayer.shuffleModeEnabledStream,
                builder: (context, snapshot) {
                  return IconButton(
                    onPressed: audioPlayer.toggleShuffleMode,
                    color:
                        snapshot.data == true
                            ? Colors.greenAccent.shade400
                            : Colors.white,
                    icon: FaIcon(size: 24, FontAwesomeIcons.shuffle),
                  );
                },
              ),
              children: [
                for (int i in upcomingSongs)
                  Padding(
                    key: ValueKey('upcoming_$i'),
                    padding: const EdgeInsets.only(top: 12),
                    child: SongCard(
                      variant: 1,
                      song: audioPlayer.songList[i],
                      playlist: playlist,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
