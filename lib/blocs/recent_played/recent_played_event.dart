import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';

class RecentPlayedEvent {}

class RecentSongPlayedEvent extends RecentPlayedEvent {
  final SongModel song;
  RecentSongPlayedEvent(this.song);
}

class RecentPlaylistPlayedEvent extends RecentPlayedEvent {
  final PlaylistModel playlist;
  RecentPlaylistPlayedEvent(this.playlist);
}
