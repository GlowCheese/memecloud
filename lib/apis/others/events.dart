import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEvents {
  final ApiKit apiKit; 
  final supabase = getIt<SupabaseApi>();
  final storage = getIt<PersistentStorage>();

  late final StreamSubscription authStateStream;

  SupabaseEvents(this.apiKit) {
    unawaited(_loadZingCookie());
    authStateStream = apiKit.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      debugPrint('Event: $event');
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.initialSession:
          unawaited(_onUserLoggedIn());
          break;
        default:
          break;
      }
    });
  }

  Future<void> _loadZingCookie() async {
    final cookieStr = await supabase.config.getZingCookie();
    await storage.setCookie(cookieStr);
  }

  Future<void> _onUserLoggedIn() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    debugPrint('Loading user data...');
    await Future.wait([
      _loadUserProfile(),
      _loadUserLikedSongs(),
      _loadUserBlacklistedSongs()
    ]);
  }

  Future<void> _loadUserProfile() async {
    final f = supabase.profile.getProfile;
    supabase.profile.myProfile = await f();
  }

  Future<void> _loadUserLikedSongs() async {
    final songs = await supabase.songs.getLikedSongs();
    await storage.preloadUserLikedSongs(songs);
  }

  Future<void> _loadUserBlacklistedSongs() async {
    final songs = await supabase.songs.getBlacklistSongs();
    await storage.preloadUserBlacklistedSongs(songs);
  }

  Future<void> _loadVipSongs() async {
    debugPrint('Loading vip songs...');
    final songIds = await supabase.songs.getVipSongIds();
    await storage.preloadVipSongs(songIds);
  }

  void dispose() {
    authStateStream.cancel();
  }
}