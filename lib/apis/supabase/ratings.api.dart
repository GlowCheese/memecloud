import 'dart:developer';

import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/rating.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseRatingApi {
  final SupabaseClient _client;
  final _connectivity = getIt<ConnectivityStatus>();

  SupabaseRatingApi(this._client);

  Future<void> sendRatings({
    required double musicRating,
    required double uiRating,
    required double uxRating,
  }) async {
    try {
      _connectivity.ensure();
      RatingModel rating = RatingModel(
        userId: _client.auth.currentUser!.id,
        musicRating: musicRating,
        uiRating: uiRating,
        uxRating: uxRating,
        createdAt: DateTime.now(),
      );
      await _client.from('ratings').insert(rating.toJson());
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to rate app!', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }
}
