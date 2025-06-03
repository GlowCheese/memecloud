import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/apis/supabase/artists.dart';
import 'package:memecloud/apis/supabase/auth.dart';
import 'package:memecloud/apis/supabase/cache.dart';
import 'package:memecloud/apis/supabase/config.dart';
import 'package:memecloud/apis/supabase/issues.api.dart';
import 'package:memecloud/apis/supabase/playlists.dart';
import 'package:memecloud/apis/supabase/profile.dart';
import 'package:memecloud/apis/supabase/ratings.api.dart';
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/apis/supabase/user_playlist.dart';
import 'package:memecloud/apis/supabase/vip_users.api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  late final SupabaseClient client;
  late final SupabaseAuthApi auth;
  late final SupabaseProfileApi profile;
  late final SupabaseCacheApi cache;
  late final SupabaseSongsApi songs;
  late final SupabaseArtistsApi artists;
  late final SupabasePlaylistsApi playlists;
  late final SupabaseUserPlaylistApi userPlaylist;
  late final SupabaseConfigApi config;
  late final SupabaseRatingApi ratingApi;
  late final SupabaseIssueApi issueApi;
  late final SupabaseVipUsersSService vipUsersSService;

  SupabaseApi._() {
    client = Supabase.instance.client;
    auth = SupabaseAuthApi(client);
    profile = SupabaseProfileApi(client);
    cache = SupabaseCacheApi(client);
    songs = SupabaseSongsApi(client);
    artists = SupabaseArtistsApi(client);
    playlists = SupabasePlaylistsApi(client);
    userPlaylist = SupabaseUserPlaylistApi(client);
    config = SupabaseConfigApi(client);
    ratingApi = SupabaseRatingApi(client);
    issueApi = SupabaseIssueApi(client);
    vipUsersSService = SupabaseVipUsersSService(client);
  }

  static Future<SupabaseApi> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'].toString(),
      anonKey: dotenv.env['SUPABASE_ANON_KEY'].toString(),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    return SupabaseApi._();
  }
}
