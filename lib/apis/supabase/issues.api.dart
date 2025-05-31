import 'dart:developer';

import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/issue.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseIssueApi {
  final SupabaseClient _client;
  final _connectivity = getIt<ConnectivityStatus>();
  

  SupabaseIssueApi(this._client);

  Future<void> sendIssue({
    required IssueType type,
    required String description,
  }) async {
    try {
      _connectivity.ensure();
      IssueModel issue = IssueModel(
        userId: _client.auth.currentUser!.id,
        type: type,
        description: description,
        createdAt: DateTime.now(),
      );
      await _client.from('issues').insert(issue.toJson());
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to report issue!', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }
}
