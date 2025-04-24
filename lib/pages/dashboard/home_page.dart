import 'package:flutter/material.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/components/home/top_artist.dart';
import 'package:memecloud/components/home/featured_section.dart';
import 'package:memecloud/components/home/new_release_section.dart';

Map getHomePage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Welcome!'),
    'body': SingleChildScrollView(
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
  };
}
