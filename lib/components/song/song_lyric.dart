import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_lyrics_model.dart';
import 'package:memecloud/components/song/song_controller.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/custom_audio_player.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class SongLyricPage extends StatelessWidget {
  const SongLyricPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = getIt<CustomAudioPlayer>();

    return StreamBuilder(
      stream: audioPlayer.currentSongStream,
      builder: (context, snapshot) {
        final song = snapshot.data;
        if (song == null) return const SizedBox();

        return Scaffold(
          appBar: _appBar(context, song.title),
          backgroundColor: Colors.brown.shade600,
          body: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: defaultFutureBuilder(
                  future: getIt<ApiKit>().getSongLyric(song.id),
                  onNull: (context) {
                    return const Center(
                      child: Text(
                        'This song currently has no lyric!',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                  onData: (context, data) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: SongLyricWidget(lyric: data!, autoScroll: true),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(
                  color: Colors.white,
                  thickness: 1.0,
                  indent: 75,
                  endIndent: 75,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                child: SongControllerView(song: song, hasSlider: false),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _appBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Text(title, overflow: TextOverflow.fade),
      ),
      leading: BackButton(onPressed: context.pop),
    );
  }
}

class SongLyricWidget extends StatefulWidget {
  final bool autoScroll;
  final bool largeText;
  final SongLyricsModel lyric;

  const SongLyricWidget({
    super.key,
    required this.lyric,
    this.autoScroll = false,
    this.largeText = true,
  });

  @override
  State<SongLyricWidget> createState() => _SongLyricWidgetState();
}

class _SongLyricWidgetState extends State<SongLyricWidget> {
  late final ScrollController? _scrollController =
      widget.autoScroll ? ScrollController() : null;

  int _lastIndex = -1;
  final Map<int, GlobalKey> _lyricItemKeys = {};

  @override
  Widget build(BuildContext context) {
    final lyricLines = widget.lyric.lyricLines;
    final playerCubit = getIt<SongPlayerCubit>();

    return StreamBuilder<Duration>(
      stream: getIt<CustomAudioPlayer>().positionStream,
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

        if (widget.autoScroll) {
          if (_lastIndex != currentIndex && _scrollController!.hasClients) {
            _lastIndex = currentIndex;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final context = _lyricItemKeys[currentIndex]?.currentContext;
              if (context != null) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 300),
                  alignment: 0.5,
                  curve: Curves.easeInOut,
                );
              }
            });
          }
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: lyricLines.length,
          itemBuilder: (context, index) {
            final isActive = index == currentIndex;
            final key = _lyricItemKeys.putIfAbsent(index, () => GlobalKey());
            return Center(
              key: key,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: () => playerCubit.seek(lyricLines[index].time),
                  child: Text(
                    lyricLines[index].text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade400,
                      fontSize:
                          (widget.largeText)
                              ? (isActive ? 23 : 19)
                              : (isActive ? 20 : 16),
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
