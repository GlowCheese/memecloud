import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/home/top_artist.dart';
import 'package:memecloud/components/home/featured_section.dart';
import 'package:memecloud/components/home/new_release_section.dart';
import 'package:memecloud/components/sections/section_item_card.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/utils/images.dart';

Map getHomePage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Welcome!'),
    'bgColor': MyColorSet.purple,
    'body': _HomePage(),
  };
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getHomeJson(),
      onData: (context, json) {
        return ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Builder(
              builder: (context) {
                final section = json['items'][0];

                return Column(
                  children: [
                    CarouselSlider(
                      items: [
                        for (var sectionItem in section['items'])
                          SectionItemCard.variation1(
                            key: ValueKey(sectionItem),
                            title: sectionItem['title'],
                            description: sectionItem['description'],
                            tag: sectionItem['tag'],
                            height: 152, // default value
                            thumbnailUrl: sectionItem['thumbnail'],
                          ),
                      ],
                      options: CarouselOptions(
                        height: 152,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                      ),
                    ),
                    DataInspector(section, name: section['sectionId']),
                  ],
                );
              },
            ),
            DataInspector(json, name: 'Original'),
          ],
        );
      },
    );
  }
}
