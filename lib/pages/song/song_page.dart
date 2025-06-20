import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/components/song/song_lyric.dart';
import 'package:memecloud/components/song/like_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/song/song_controller.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/miscs/expandable/text.dart';
import 'package:memecloud/components/song/song_bottom_sheet.dart';
import 'package:memecloud/components/song/rotating_song_disc.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/song/song_download_button.dart';
import 'package:memecloud/components/artist/artist_follow_button.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

class SongPage extends StatelessWidget {
  final playerCubit = getIt<SongPlayerCubit>();
  late final audioPlayer = playerCubit.audioPlayer;

  SongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: audioPlayer.currentSongStream,
      builder: (context, snapshot) {
        final song = snapshot.data;
        if (song == null) return const SizedBox();
        return SongPageInner(playerCubit, song);
      },
    );
  }
}

class SongPageInner extends StatelessWidget {
  final SongModel song;
  final SongPlayerCubit playerCubit;
  const SongPageInner(this.playerCubit, this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    return GradBackground2(
      imageUrl: song.thumbnailUrl,
      builder: (domColor, _) {
        domColor = adjustColor(domColor, l: 0.2);
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          child: Scaffold(
            appBar: _appBar(context, domColor),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 72),
                      Center(child: _songCover(domColor)),
                      const SizedBox(height: 72),
                      _songDetails(),
                      const SizedBox(height: 20),
                      SongControllerView(song: song),
                      const SizedBox(height: 50),
                      _songLyric(),
                      const SizedBox(height: 30),
                      if (song.artists.isNotEmpty)
                        _artistCard(context, song.artists[0]),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _songLyric() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.brown.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: defaultFutureBuilder(
        future: getIt<ApiKit>().getSongLyric(song.id),
        onNull: (context) {
          return const Center(child: Text('This song currently has no lyric!'));
        },
        onData: (context, data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Lời bài hát',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push('/song_lyric');
                      },
                      iconSize: 20,
                      icon: const Icon(Icons.open_in_full),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SongLyricWidget(lyric: data!, largeText: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _artistCard(BuildContext context, ArtistModel artist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/artist_page', extra: artist.alias),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: artist.thumbnailUrl,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        defaultFutureBuilder(
                          future: getIt<ApiKit>().artistStreamCount(artist.id),
                          onData: (context, data) {
                            return Text(
                              '$data lượt phát toàn cầu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withAlpha(196),
                                fontSize: 13,
                              ),
                            );
                          },
                          onWaiting: Skeletonizer(
                            child: Text(
                              BoneMock.words(3),
                              style: TextStyle(
                                color: Colors.white.withAlpha(196),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ArtistFollowButton(artistId: artist.id),
                ],
              ),
              defaultFutureBuilder(
                future: getIt<ApiKit>().getArtistInfo(artist.alias),
                onData: (context, data) {
                  final bio = data?.shortBiography;
                  if (bio == null || bio.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: ExpandableText(
                      bio,
                      trimLength: 120,
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(196),
                      ),
                      expandTextStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                onWaiting: Skeletonizer(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(BoneMock.paragraph),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _songCover(Color holeColor) {
    return StreamBuilder<bool>(
      stream: playerCubit.audioPlayer.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data == true;
        return RotatingSongDisc(
          thumbnailUrl: song.thumbnailUrl,
          isPlaying: isPlaying,
          holeColor: holeColor,
          size: MediaQuery.of(context).size.width - 128,
        );
      },
    );
  }

  Row _songDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                song.artistsNames,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SongDownloadButton(song: song, iconSize: 30),
        const SizedBox(width: 8),
        SongLikeButton(song: song, iconSize: 30),
      ],
    );
  }

  AppBar _appBar(BuildContext context, Color domColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: TextButton(
        onPressed: () {
          context.push(
            '/song_history_page',
            extra: playerCubit.currentPlaylist,
          );
        },
        style: const ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        ),
        child: Column(
          children: [
            StreamBuilder<bool>(
              stream: playerCubit.audioPlayer.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data == true;
                final transitionDuration = const Duration(milliseconds: 500);
                return Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: isPlaying ? 1 : 0,
                      duration: transitionDuration,
                      child: const Text(
                        'Playing',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isPlaying ? 0 : 1,
                      duration: transitionDuration,
                      child: const Text(
                        'Paused',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                );
              },
            ),
            Text(
              'Xem danh sách phát',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
      leading: BackButton(
        style: const ButtonStyle(
          iconSize: WidgetStatePropertyAll(22),
          padding: WidgetStatePropertyAll(EdgeInsets.only(left: 12)),
        ),
        onPressed: () {
          try {
            context.pop();
          } catch (e) {
            context.go('/404');
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 22,
            onPressed: () {
              showSongBottomSheet(context, song, bgColor: domColor);
            },
          ),
        ),
      ],
    );
  }
}
