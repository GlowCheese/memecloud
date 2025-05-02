import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/components/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';

class E17 extends StatefulWidget {
  const E17({super.key});

  @override
  State<E17> createState() => _E17State();
}

class _E17State extends State<E17> {
  final ScrollController _scrollController = ScrollController();

  int _lastIndex = -1;
  final Map<int, GlobalKey> _lyricItemKeys = {};

  @override
  Widget build(BuildContext context) {
    final playerCubit = getIt<SongPlayerCubit>();

    return BlocBuilder(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return Center(child: Text('Song not loaded!'));
        }

        final String songId = state.currentSong.id;

        return defaultFutureBuilder(
          future: getIt<ApiKit>().getLyricPath(songId),
          onNull: (context) {
            return Center(child: Text('This song has no lyric!'));
          },
          onData: (context, lyrics) {
            final lyricLines = lyrics!.lyricLines;

            return StreamBuilder<Duration>(
              stream: playerCubit.audioPlayer.positionStream,
              builder: (context, snapshot) {
                final currentPosition = snapshot.data ?? Duration.zero;

                int currentIndex = 0;
                for (int i = 0; i < lyricLines.length; i++) {
                  if (lyricLines[i].time <= currentPosition) {
                    currentIndex = i;
                  } else {
                    break;
                  }
                }

                // Scroll nếu có sự thay đổi dòng đang phát
                if (_lastIndex != currentIndex &&
                    _scrollController.hasClients) {
                  _lastIndex = currentIndex;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final context =
                        _lyricItemKeys[currentIndex]?.currentContext;
                    if (context != null) {
                      Scrollable.ensureVisible(
                        context,
                        duration: Duration(milliseconds: 300),
                        alignment: 0.5, // 0.5 = giữa màn hình
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                }

                return Center(
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: lyricLines.length,
                      itemBuilder: (context, index) {
                        final isActive = index == currentIndex;
                        final key = _lyricItemKeys.putIfAbsent(
                          index,
                          () => GlobalKey(),
                        );
                        return Center(
                          key: key,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              lyricLines[index].text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey,
                                fontSize: isActive ? 20 : 16,
                                fontWeight:
                                    isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
