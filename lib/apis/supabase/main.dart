import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/apis/supabase/auth.dart';
import 'package:memecloud/apis/supabase/cache.dart';
import 'package:memecloud/apis/supabase/profile.dart';
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool _initialized = false;

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'].toString(),
    anonKey: dotenv.env['SUPABASE_ANON_KEY'].toString(),
    authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );
  _initialized = true;
}

class SupabaseApi {
  late final SupabaseClient client;
  late final SupabaseAuthApi auth;
  late final SupabaseSongsApi songs;
  late final SupabaseProfileApi profile;
  late final SupabaseCacheApi cache;

  SupabaseApi() {
    assert(
      _initialized,
      'initializeSupabase() must be called before this constructor!',
    );
    client = Supabase.instance.client;
    auth = SupabaseAuthApi(client);
    songs = SupabaseSongsApi(client);
    profile = SupabaseProfileApi(client);
    cache = SupabaseCacheApi(client);
  }
}
