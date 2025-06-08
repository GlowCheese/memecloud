import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';
import 'package:memecloud/components/sections/section_card.dart';
import 'package:memecloud/components/miscs/section_divider.dart';
import 'package:memecloud/components/miscs/bottom_sheet_dragger.dart';
import 'package:memecloud/blocs/song_player/custom_audio_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class ScrollableSongHistoryPage extends StatelessWidget {
  final PlaylistModel? playlist;

  const ScrollableSongHistoryPage({super.key, this.playlist});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = getIt<CustomAudioPlayer>();
    return StreamBuilder(
      stream:
          Rx.combineLatest2<List<int>, List<int>, Tuple2<List<int>, List<int>>>(
            audioPlayer.listenHistoryStream,
            audioPlayer.upcomingSongsStream,
            (history, upcoming) => Tuple2(history, upcoming),
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SpinKitPumpingHeart(color: Colors.blue);
        }

        final upcomingSongs = snapshot.data!.item2;
        final listenHistory = snapshot.data!.item1.sublist(
          max(0, audioPlayer.listenHistory.length - 5),
        ); // only show the last 5 songs from history

        late final List<Widget>? actions;
        if (playlist == null) {
          actions = null;
        } else {
          actions = [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showPlaylistBottomSheet(context);
              },
            ),
          ];
        }

        return SimpleScrollablePage(
          title: 'Lịch sử phát',
          bgColor: MyColorSet.cyan,
          spacing: 12,
          actions: actions,
        ).variant1(
          children: [
            const SizedBox(),

            for (int i in listenHistory)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SongCard(
                  key: ValueKey('previous_$i'),
                  variant: 1,
                  song: audioPlayer.songList[i],
                  playlist: playlist,
                  dimmed: i != listenHistory.last,
                ),
              ),

            SectionCard(title: 'Bài tiếp theo').variant1(
              titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 18),
              child: Column(
                spacing: 12,
                children: [
                  for (var song in upcomingSongs)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SongCard(
                        variant: 1,
                        song: audioPlayer.songList[song],
                        playlist: playlist,
                      ),
                    ),
                ],
              ),
              showAllButton: StreamBuilder(
                stream: audioPlayer.shuffleModeEnabledStream,
                builder: (context, snapshot) {
                  return IconButton(
                    onPressed: audioPlayer.toggleShuffleMode,
                    color:
                        snapshot.data == true
                            ? Colors.greenAccent.shade400
                            : Colors.white,
                    icon: const FaIcon(size: 24, FontAwesomeIcons.shuffle),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future showPlaylistBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.blueGrey.shade700,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragger(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    PlaylistCard(
                      playlist: playlist!,
                      fetchNew: false,
                    ).variant1(),
              ),
              const SectionDivider(),
              ListTile(
                leading: PlaylistCard.anotIcon(),
                title: const Text('Chuyển đến danh sách phát'),
                onTap: () {
                  context.pushReplacement('/playlist_page', extra: playlist!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
