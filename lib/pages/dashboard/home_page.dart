// ignore_for_file: camel_case_types

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/sections/section_card.dart';
import 'package:memecloud/components/sections/section_item_card.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

Map getHomePage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Welcome!'),
    'bgColor': MyColorSet.purple,
    'body': const _HomePage(),
  };
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().getHomeJson(),
      onData: (context, json) {
        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: json['items'].length + 1,
            itemBuilder: (context, index) {
              if (index < json['items'].length) {
                final section = json['items'][index];
                if (section['sectionId'] == 'hQuickPlay') {
                  return hQuickPlaySection(section);
                } else if (section['sectionId'] == 'hSongRadio') {
                  return hSongRadioSection(title: section['title']);
                } else if ((const ['hRecent']).contains(section['sectionId'])) {
                  return const SizedBox();
                } else {
                  return DataInspector(section, name: section['sectionId']);
                }
              }
              return DataInspector(json, name: 'Original');
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        );
      },
    );
  }

  Widget hQuickPlaySection(Map<String, dynamic> section) {
    return CarouselSlider(
      items: [
        for (var sectionItem in section['items'])
          SectionItemCard.variation1(
            playlistId: sectionItem['id'],
            key: ValueKey(sectionItem),
            title: sectionItem['title'],
            description: sectionItem['description'],
            tag: sectionItem['tag'],
            height: 152, // default value
            thumbnailUrl: sectionItem['thumbnail'],
          ),
      ],
      options: CarouselOptions(height: 152, enlargeCenterPage: true),
    );
  }
}

class hSongRadioSection extends StatefulWidget {
  final String title;

  const hSongRadioSection({super.key, required this.title});

  @override
  State<hSongRadioSection> createState() => _hSongRadioSectionState();
}

class _hSongRadioSectionState extends State<hSongRadioSection> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return defaultFutureBuilder(
      future: getIt<ApiKit>().sectionSongStation(force: _counter != 0),
      onNull: (context) => const SizedBox(),
      onData: (context, songs) {
        final songsPerCol = 3;
        songs = songs.sublist(0, songs.length - (songs.length % songsPerCol));
        return _hSongRadioSectionInner(
          key: ValueKey(_counter),
          title: widget.title,
          songs: songs,
          refresh: () => setState(() => _counter = _counter + 1),
        );
      },
    );
  }
}

class _hSongRadioSectionInner extends StatefulWidget {
  const _hSongRadioSectionInner({
    super.key,
    required this.title,
    required this.songs,
    required this.refresh,
  });

  final String title;
  final List<SongModel> songs;
  final void Function() refresh;

  @override
  State<_hSongRadioSectionInner> createState() =>
      _hSongRadioSectionInnerState();
}

class _hSongRadioSectionInnerState extends State<_hSongRadioSectionInner> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final int songsPerCol = 3;
    return Column(
      children: [
        SectionCard.variant1(
          title: widget.title,
          titlePadding: const EdgeInsets.symmetric(horizontal: 24),
          showAllButton: TextButton(
            onPressed: widget.refresh,
            child: const Text('Làm mới'),
          ),
          children: [
            CarouselSlider(
              items: [
                for (int i = 0; i < widget.songs.length; i += songsPerCol)
                  Column(
                    key: Key('${widget.key} songradio $i'),
                    children: [
                      for (
                        int j = i;
                        j < min(widget.songs.length, i + songsPerCol);
                        j++
                      )
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 12,
                          ),
                          child: SongCard(
                            key: Key('${widget.key} songradio $i $j'),
                            variant: 1,
                            song: widget.songs[j],
                            songList: widget.songs,
                          ),
                        ),
                    ],
                  ),
              ],
              carouselController: _controller,
              options: CarouselOptions(
                // SongCard.variant1's height is 53 (i don't know why)
                height: ((53 + 12) * songsPerCol).toDouble(),
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() => _current = index);
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.songs.length / songsPerCol; i++)
              Container(
                key: Key('${widget.key} songradio indicator $i'),
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 8, right: 8, top: 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(_current == i ? 255 : 128),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
