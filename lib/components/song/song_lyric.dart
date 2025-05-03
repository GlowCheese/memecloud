import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/components/song/song_controller.dart';
import 'package:memecloud/core/getit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_lyrics_model.dart';
import 'package:memecloud/components/default_future_builder.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';

class SongLyricPage extends StatelessWidget {
  const SongLyricPage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCubit = getIt<SongPlayerCubit>();

    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      bloc: playerCubit,
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return SizedBox();
        }
        return Scaffold(
          appBar: _appBar(context, state.currentSong.title),
          backgroundColor: Colors.brown.shade700,
          body: Column(
            children: [
              SizedBox(height: 30),
              Expanded(
                child: defaultFutureBuilder(
                  future: getIt<ApiKit>().getSongLyric(state.currentSong.id),
                  onNull: (context) {
                    return Center(
                      child: Text('This song currently has no lyric!'),
                    );
                  },
                  onData: (context, data) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Hero(
                        tag: "lyric",
                        child: SongLyricWidget(lyric: data!, autoScroll: true),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Divider(
                  color: Colors.white,
                  thickness: 1.0,
                  indent: 75,
                  endIndent: 75,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                child: SongControllerView(
                  song: state.currentSong,
                  hasSlider: false,
                ),
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
      stream: getIt<AudioPlayer>().positionStream,
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
                  duration: Duration(milliseconds: 300),
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
                  onTap: () => playerCubit.seekTo(lyricLines[index].time),
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
