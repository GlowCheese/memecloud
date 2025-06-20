import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/blocs/bl_songs/bl_songs_stream.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/utils/images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/components/song/mini_player.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/miscs/search_bar.dart';
import 'package:memecloud/components/miscs/expandable/text.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/pages/song/list_song_paginate_page.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/playlist/playlist_follow_button.dart';
import 'package:memecloud/components/playlist/playlist_download_button.dart';

enum SortPlaylistOptions { duration, releaseDate, title, artist }

class PlaylistPage extends StatelessWidget {
  final String? playlistId;
  final PlaylistModel? playlist;

  const PlaylistPage({super.key, this.playlist, this.playlistId});

  @override
  Widget build(BuildContext context) {
    assert((playlist != null) != (playlistId != null));

    if (playlist != null) {
      return Scaffold(
        body: SafeArea(
          child: GradBackground2(
            imageUrl: playlist!.thumbnailUrl,
            builder:
                (_, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    _PlaylistPageInner(playlist: playlist!),
                    MiniPlayer(floating: true),
                  ],
                ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: defaultFutureBuilder(
          future: getIt<ApiKit>().getPlaylistInfo(playlistId!),
          onNull: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Playlist with id $playlistId doesn't exist!"),
                  ElevatedButton(
                    onPressed: context.pop,
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          },
          onData: (context, data) {
            return GradBackground2(
              imageUrl: data!.thumbnailUrl,
              builder:
                  (_, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      _PlaylistPageInner(playlist: data),
                      MiniPlayer(floating: true),
                    ],
                  ),
            );
          },
        ),
      ),
    );
  }
}

class _PlaylistPageInner extends StatefulWidget {
  final PlaylistModel playlist;

  const _PlaylistPageInner({required this.playlist});

  @override
  State<_PlaylistPageInner> createState() => _PlaylistPageInnerState();
}

class _PlaylistPageInnerState extends State<_PlaylistPageInner> {
  SortPlaylistOptions? _sortOption;
  late List<SongModel> _displaySongs = List.from(widget.playlist.songs ?? []);

  late final StreamSubscription<SongBlackListEvent> streamSub;

  @override
  void initState() {
    super.initState();
    streamSub = getIt<BlacklistedSongsStream>().stream.listen((event) {
      for (var song in widget.playlist.songs ?? []) {
        if (song.id == event.songId) {
          setState(() {
            if (event.isBlacklisted) {
              _displaySongs.remove(song);
            } else {
              _displaySongs.add(song);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    streamSub.cancel();
    super.dispose();
  }

  List<SongModel> get _sortedDisplaySongs {
    var res = List<SongModel>.from(_displaySongs);
    if (_sortOption == SortPlaylistOptions.duration) {
      res.sort((a, b) => a.duration.compareTo(b.duration));
    } else if (_sortOption == SortPlaylistOptions.releaseDate) {
      res.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    } else if (_sortOption == SortPlaylistOptions.title) {
      res.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortOption == SortPlaylistOptions.artist) {
      res.sort((a, b) => a.artistsNames.compareTo(b.artistsNames));
    }
    return res;
  }

  /// Only for user playlist.
  /// Use for refresh playlist after add song to playlist.
  Future<void> refreshPlaylist() async {
    final updatedPlaylist = await getIt<SupabaseApi>().userPlaylist
        .getPlaylistInfo(widget.playlist.id);
    setState(() {
      widget.playlist.songs?.clear();
      widget.playlist.songs?.addAll(updatedPlaylist.songs ?? []);
      _displaySongs = List.from(updatedPlaylist.songs ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _appBar(context),
        _generalDetails(),
        _playlistDescription(),
        _songsSliverList(context),
        const SliverToBoxAdapter(child: SizedBox(height: 72)),
      ],
    );
  }

  SliverList _songsSliverList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final song = _sortedDisplaySongs[index];
        return Padding(
          key: ValueKey(song.id),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: SongCard(
            variant: 4,
            song: song,
            songList: _displaySongs,
            playlist: widget.playlist,
          ),
        );
      }, childCount: _displaySongs.length),
    );
  }

  SliverToBoxAdapter _playlistDescription() {
    if (widget.playlist.description == null ||
        widget.playlist.description!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 18));
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.teal.shade500,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpandableText(
            widget.playlist.description!,
            trimLength: 120,
            textStyle: GoogleFonts.mali(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
            expandTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _generalDetails() {
    Duration playlistDuration = (widget.playlist.songs ?? []).fold(
      Duration.zero,
      (prev, song) => prev + song.duration,
    );
    String playlistDurationStr = formatDuration(playlistDuration);
    int playlistLength = widget.playlist.songs?.length ?? 0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: getImage(widget.playlist.thumbnailUrl, 120),
                ),

                if (widget.playlist.type == PlaylistType.zing)
                  PlaylistFollowButton(
                    playlist: widget.playlist,
                    iconSize: 30,
                    withFolowerCount: true,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playlist.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Playlist • $playlistLength Tracks • $playlistDurationStr',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                        ),

                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.playlist.artistsNames ?? "Trending Music",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  _playlistControlButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _playlistControlButtons() {
    final playerCubit = getIt<SongPlayerCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.playlist.type != PlaylistType.downloaded)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: PlaylistDownloadButton(
              playlist: widget.playlist,
              iconSize: 26,
            ),
          ),

        IconButton(
          onPressed:
              _displaySongs.isEmpty
                  ? null
                  : () => playerCubit.loadAndPlay(
                    context,
                    _displaySongs[0],
                    songList: _displaySongs,
                    playlist: widget.playlist,
                  ),
          icon: const Icon(Icons.play_arrow, color: Colors.black),
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
          padding: const EdgeInsets.all(4),
        ),
        if (widget.playlist.type == PlaylistType.user)
          IconButton(
            onPressed: () async {
              final res = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ListSongPaginatePage(playlistId: widget.playlist.id),
                ),
              );
              if (res == true) {
                await refreshPlaylist();
              }
            },
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.grey.shade900,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),
            Expanded(child: SizedBox(height: 40, child: _searchBar())),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.grey[900],
                    builder: (_) => _sortOptionsSheet(),
                  );
                },
                icon: Icon(
                  Icons.swap_vert,
                  size: 20,
                  color: Colors.grey.shade900,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return MySearchBar(
      variant: 2,
      onChanged: (query) {
        if (query.trim().isEmpty) {
          setState(
            () => _displaySongs = List.from(widget.playlist.songs ?? []),
          );
        }

        String lowercasedQuery = query.toLowerCase();
        setState(() {
          _displaySongs =
              (widget.playlist.songs ?? [])
                  .where(
                    (song) =>
                        song.title.toLowerCase().contains(lowercasedQuery),
                  )
                  .toList();
        });
      },
    );
  }

  Widget _sortOptionsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.white),
            title: const Text(
              'Sắp xếp theo thời lượng',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => _sortOption = SortPlaylistOptions.duration);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white),
            title: const Text(
              'Sắp xếp theo ngày phát hành',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => _sortOption = SortPlaylistOptions.releaseDate);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.title, color: Colors.white),
            title: const Text(
              'Sắp xếp theo tên bài hát',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => _sortOption = SortPlaylistOptions.title);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Sắp xếp theo nghệ sĩ',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => _sortOption = SortPlaylistOptions.artist);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
