import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/others/storage.dart';

class SupabaseEvents {
  final client = getIt<ApiKit>().client;
  final supabase = getIt<SupabaseApi>();
  final storage = getIt<PersistentStorage>();

  static Future<SupabaseEvents> initialize() async {
    final res = SupabaseEvents();
    await res._loadZingCookie();
    return res;
  }

  Future<void> _loadZingCookie() async {
    final cookieStr = await supabase.config.getZingCookie();
    await storage.setCookie(cookieStr);
  }

  Future<void> loadUserData() async {
    debugPrint('Loading user data...');
    await _loadUserProfile();
    await _loadUserLikedSongs();
    await _loadUserFollowedPlaylists();
    await _loadUserBlacklistedSongs();
  }

  Future<void> _loadUserProfile() async {
    final f = supabase.profile.getProfile;
    supabase.profile.myProfile = await f();
  }

  Future<void> _loadUserLikedSongs() async {
    final songs = await supabase.songs.getLikedSongs();
    await storage.preloadUserLikedSongs(songs);
  }

  Future<void> _loadUserFollowedPlaylists() async {
    final playlists = await supabase.playlists.getFollowedPlaylists();
    await storage.preloadUserFollowedPlaylists(playlists);
  }

  Future<void> _loadUserBlacklistedSongs() async {
    final songs = await supabase.songs.getBlacklistSongs();
    await storage.preloadUserBlacklistedSongs(songs);
  }
}
