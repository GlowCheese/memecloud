import 'dart:async';

class SongBlackListEvent {
  final String songId;
  final bool isBlacklisted;

  SongBlackListEvent({required this.songId, required this.isBlacklisted});
}

class BlacklistedSongsStream {
  final _controller = StreamController<SongBlackListEvent>.broadcast();

  Stream<SongBlackListEvent> get stream => _controller.stream;

  void setIsBlacklisted(String songId, bool isBlacklisted) {
    _controller.add(
      SongBlackListEvent(songId: songId, isBlacklisted: isBlacklisted),
    );
  }

  void dispose() {
    _controller.close();
  }
}
