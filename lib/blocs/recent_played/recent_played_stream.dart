import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/recent_played/recent_played_event.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';

class RecentPlayedStream {
  final _controller = StreamController<RecentPlayedEvent>.broadcast();

  Stream<RecentPlayedEvent> get stream => _controller.stream;

  void addSong(SongModel song) {
    _controller.add(RecentSongPlayedEvent(song));
  }

  void addPlaylist(PlaylistModel playlist) {
    _controller.add(RecentPlaylistPlayedEvent(playlist));
  }

  void dispose() {
    _controller.close();
  }
}

class RecentPlayedStreamBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    List<SongModel> recentlyPlayedSongs,
    List<PlaylistModel> recentlyPlayedPlaylists,
  )
  builder;

  const RecentPlayedStreamBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    List<SongModel> recentlyPlayedSongs =
        getIt<ApiKit>().getRecentlyPlayedSongs();
    List<PlaylistModel> recentlyPlayedPlaylists =
        getIt<ApiKit>().getRecentlyPlayedPlaylists().toList();

    return StreamBuilder(
      stream: getIt<RecentPlayedStream>().stream,
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event is RecentSongPlayedEvent) {
          recentlyPlayedSongs.removeWhere((song) => song.id == event.song.id);
          recentlyPlayedSongs.insert(0, event.song);
        }
        if (event is RecentPlaylistPlayedEvent) {
          recentlyPlayedPlaylists.removeWhere(
            (playlist) => playlist.id == event.playlist.id,
          );
          recentlyPlayedPlaylists.insert(0, event.playlist);
        }
        return builder(context, recentlyPlayedSongs, recentlyPlayedPlaylists);
      },
    );
  }
}
