import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseVipUsersSService {
  final SupabaseClient _client;

  bool _isVipUser = false;

  bool get isVip => _isVipUser;

  SupabaseVipUsersSService(this._client);

  Future<bool> setVipStatusFromRemote() async {
    try {
      User? user = _client.auth.currentUser;
      if (user == null) throw const AuthException('User not logged in');

      final response =
          await _client
              .from('vip_users')
              .select('end_time')
              .eq('user_id', user.id)
              .gt('end_time', DateTime.now().toIso8601String())
              .maybeSingle();
      _isVipUser = response != null;
      return _isVipUser;
    } catch (e, stackTrace) {
      log('setVipStatusFromRemote error: $e', stackTrace: stackTrace);
    }
    _isVipUser = false;
    return _isVipUser;
  }

  Future<String> updateToVip({int durationDays = 90}) async {
    try {
      log('update vip into supabase');
      User? user = _client.auth.currentUser;
      if (user == null) throw const AuthException('User havent login');
      String userId = user.id;

      await _client.from('vip_users').upsert({
        'user_id': userId,
        'end_time':
            DateTime.now().add(Duration(days: durationDays)).toIso8601String(),
      });
      _isVipUser = true;
      return "success";
    } catch (e, strackTrace) {
      log(e.toString(), stackTrace: strackTrace);
      return 'failed';
    }
  }
}
