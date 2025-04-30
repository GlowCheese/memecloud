import 'dart:developer';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/connectivity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthApi {
  final SupabaseClient _client;
  SupabaseAuthApi(this._client);
  final _connectivity = getIt<ConnectivityStatus>();

  User? currentUser() {
    return _client.auth.currentUser;
  }

  Session? currentSession() {
    return _client.auth.currentSession;
  }

  Future<User> signIn(String email, String password) async {
    try {
      _connectivity.ensure();
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user!;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to login: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<User> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      _connectivity.ensure();
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName},
      );
      return response.user!;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to sign up: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _connectivity.ensure();
      return await _client.auth.signOut();
    } catch(e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to log out: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }
}