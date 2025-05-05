import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/home/top_artist.dart';
import 'package:memecloud/components/home/featured_section.dart';
import 'package:memecloud/components/home/new_release_section.dart';

Map getHomePage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Welcome!'),
    'bgColor': MyColorSet.purple,
    'body': SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: const [
          SizedBox(height: 5),
          FeaturedSection(),
          NewReleasesSection(),
          TopArtistsSection(),
        ],
      ),
    ),
  };
}
