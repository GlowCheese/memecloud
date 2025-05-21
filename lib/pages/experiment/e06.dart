import 'package:flutter/material.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/pages/dashboard/blacklist_songs_page.dart';
import 'package:memecloud/pages/library/followed_artist.dart';

class E06 extends StatelessWidget {
  const E06({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<SupabaseApi>().artists.getFollowedArtists(),
      onData: (context, artists) {
        return FollowedArtistPage(artists: artists);
      },
      onError: (context, error) {
        return const Center(child: Text('Error loading followed artists'));
      },
    );
  }
}
