import 'dart:developer';
import 'package:memecloud/core/getit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memecloud/apis/others/connectivity.dart';

class SupabaseConfigApi {
  final SupabaseClient _client;
  final _connectivity = getIt<ConnectivityStatus>();
  SupabaseConfigApi(this._client);

  Future<String?> getZingCookie<String>() async {
    try {
      final response =
          await _client
              .from('app_config')
              .select('value')
              .eq('name', 'zing_cookie')
              .maybeSingle();
      return response?['value'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log('Failed to get zing cookie', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> setCookie(String cookie) async {
    try {
      return await _client.from('app_config').upsert({
        'name': 'zing_cookie',
        'value': cookie,
        'last_update': DateTime.now().toIso8601String()
      });
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log('Failed to get zing cookie', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }
}
