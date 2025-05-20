import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';

import 'package:memecloud/components/song/like_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_stream.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';

class MusicTabsPage extends StatefulWidget {
  const MusicTabsPage({super.key});

  @override
  State<MusicTabsPage> createState() => _MusicTabsPageState();
}

class _MusicTabsPageState extends State<MusicTabsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: MyColorSet.redAccent,
            labelColor: MyColorSet.redAccent,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.favorite), text: 'Đã thích'),
              Tab(icon: Icon(Icons.download), text: 'Đã tải'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [LikedSongPage(), DownloadedSongsPage()],
        ),
      ),
    );
  }
}

class LikedSongPage extends StatefulWidget {
  const LikedSongPage({super.key});

  @override
  State<LikedSongPage> createState() => _LikedSongPageState();
}

class _LikedSongPageState extends State<LikedSongPage> {
  @override
  Widget build(BuildContext context) {
    final likedSongs = getIt<ApiKit>().getLikedSongs();
    return _SongListView(likedSongs: List<SongModel>.from(likedSongs));
  }
}

class _SongListView extends StatefulWidget {
  const _SongListView({required this.likedSongs});

  final List<SongModel> likedSongs;

  @override
  State<_SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<_SongListView>
    with AutomaticKeepAliveClientMixin {
  late List<SongModel> currentLikedSongs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    currentLikedSongs = widget.likedSongs;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: getIt<LikedSongsStream>().stream,
      builder: (context, snapshot) {
        final event = snapshot.data;

        if (event is UserLikeSongEvent) {
          currentLikedSongs.add(event.song);
        } else if (event is UserUnlikeSongEvent) {
          currentLikedSongs.removeWhere((song) => song.id == event.song.id);
        }

        if (currentLikedSongs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có bài hát nào được thích',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final playerCubit = getIt<SongPlayerCubit>();

        return BlocBuilder(
          bloc: playerCubit,
          builder: (context, state) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentLikedSongs.length,
              itemBuilder: (context, index) {
                final SongModel song = currentLikedSongs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: song.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, err) =>
                                const Icon(Icons.music_note, size: 32),
                      ),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      song.artistsNames,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SongLikeButton(song: song, defaultIsLiked: true),
                        PlayOrPauseButton(
                          song: song,
                          songList: currentLikedSongs,
                        ),
                      ],
                    ),
                    onTap: () async {
                      await playerCubit.loadAndPlay(
                        context,
                        song,
                        songList: currentLikedSongs,
                      );
                    },
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

class DownloadedSongsPage extends StatelessWidget {
  const DownloadedSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // Replace with actual implementation
  }
}
