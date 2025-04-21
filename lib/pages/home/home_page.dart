import 'package:flutter/material.dart';
import 'package:memecloud/components/default_app_bar.dart';
import 'package:memecloud/components/ui_wrapper.dart';
import 'package:memecloud/components/mini_player.dart';
import 'package:memecloud/components/home/top_artist.dart';
import 'package:memecloud/components/home/featured_section.dart';
import 'package:memecloud/components/home/new_release_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UiWrapper(
      appBar: defaultAppBar(context, title: 'Welcome!'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            FeaturedSection(),
            NewReleasesSection(),
            TopArtistsSection(),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: getMiniPlayer(),
    );
  }
}
