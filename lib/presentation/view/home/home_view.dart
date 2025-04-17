import 'package:flutter/material.dart';
import 'package:memecloud/presentation/ui/default_app_bar.dart';
import 'package:memecloud/presentation/ui/ui_wrapper.dart';
import 'package:memecloud/presentation/view/home/mini_player.dart';
import 'package:memecloud/presentation/view/home/top_artist.dart';
import 'package:memecloud/presentation/view/home/featured_section.dart';
import 'package:memecloud/presentation/view/home/new_release_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
      bottomSheet: const MiniPlayer(),
    );
  }
}
