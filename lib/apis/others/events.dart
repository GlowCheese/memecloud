import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEvents {
  final client = getIt<ApiKit>().client;
  final supabase = getIt<SupabaseApi>();
  final storage = getIt<PersistentStorage>();

  late final StreamSubscription authStateStream;

  SupabaseEvents._() {
    unawaited(_loadZingCookie());
    authStateStream = client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      debugPrint('Event: $event');
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.tokenRefreshed:
          unawaited(_onUserLoggedIn());
          break;
        case AuthChangeEvent.initialSession:
          if (client.auth.currentUser != null) {
            unawaited(_onUserLoggedIn());
          }
          break;
        default:
          break;
      }
    });
  }

  static Future<SupabaseEvents> initialize() async {
    final res = SupabaseEvents._();
    await res._loadZingCookie();
    return res;
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

  void dispose() {
    authStateStream.cancel();
  }
}