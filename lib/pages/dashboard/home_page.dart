// ignore_for_file: camel_case_types

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/musics/playlist_card.dart';
import 'package:memecloud/components/miscs/data_inspector.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/sections/section_card.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

Map getHomePage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Welcome!'),
    'bgColor': MyColorSet.purple,
    'body': const _HomePage(),
  };
}

const double horzPad = 24;

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
            itemCount: json['items'].length,
            itemBuilder: (context, index) {
              final section = json['items'][index];
              if (section['sectionId'] == 'hQuickPlay') {
                return hQuickPlaySection(section);
              } else if (section['sectionId'] == 'hSongRadio') {
                return hSongRadioSection(title: section['title']);
              } else if ((const ['hRecent']).contains(section['sectionId'])) {
                return const SizedBox();
              } else if (section['sectionId'] == 'hNewrelease') {
                final items = SongModel.fromListJson<ZingMp3Api>(
                  section['items'],
                );

                Future<List<Widget>> genFunc() async {
                  final chart = await getIt<ApiKit>().getNewReleaseChart();
                  return [
                    for (var chartSong in chart.chartSongs.take(30))
                      Padding(
                        key: Key(chartSong.song.id),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SongCard(
                          variant: 2,
                          chartSong: chartSong,
                          songList: chart.songs,
                        ),
                      ),
                    const SizedBox(),
                  ];
                }

                return SectionCard(title: section['title']).variant3(
                  height: 221,
                  titlePadding: const EdgeInsets.only(
                    left: horzPad,
                    right: horzPad,
                    bottom: 4,
                  ),
                  listViewPadding: const EdgeInsets.symmetric(horizontal: 18),
                  spacing: 16,
                  itemBuilder: (context, index) {
                    return SongCard(
                      variant: 5,
                      song: items[index],
                      songList: items,
                      width: 130,
                      height: 130,
                    );
                  },
                  itemCount: min(7, items.length),
                  showAllBuilder: (context) {
                    return SimpleScrollablePage(
                      title: section['title'],
                      bgColor: MyColorSet.indigo,
                      spacing: 12,
                    ).variant2(genFunc: genFunc);
                  },
                );
              } else if ((const [
                'h100',
                'hEditorTheme',
                'hAlbum',
              ]).contains(section['sectionId'])) {
                return SectionCard(title: section['title']).variant3_1(
                  playlists: PlaylistModel.fromListJson<ZingMp3Api>(
                    section['items'],
                  ),
                );
              } else {
                return DataInspector(section, name: section['sectionId']);
              }
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
        for (var json in section['items'])
          PlaylistCard(
            key: Key(json['id']),
            // for some reason the json format work
            // pretty well with my Supabase format
            playlist: PlaylistModel.fromJson<SupabaseApi>({
              ...json,
              'thumbnail_url': json['thumbnail'],
            }),
          ).variant4(gap: 12, height: 152, tag: json['tag']),
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
  @override
  Widget build(BuildContext context) {
    return SectionCard(title: widget.title).variant3_3(
      songs: widget.songs,
      songsPerCol: 3,
      showAllButton: TextButton(
        onPressed: widget.refresh,
        child: const Text('Làm mới'),
      ),
    );
  }
}
