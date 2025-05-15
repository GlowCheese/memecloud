import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/song/play_or_pause_button.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/generatable_list/list_view.dart';

Map getTopChartPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Top Charts'),
    'bgColor': MyColorSet.indigo,
    'body': TopChartPage(),
  };
}

class TopChartPage extends StatefulWidget {
  const TopChartPage({super.key});

  @override
  State<TopChartPage> createState() => _TopChartPageState();
}

class _TopChartPageState extends State<TopChartPage>
    with SingleTickerProviderStateMixin {
  // TabController to control the tabs
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  final ApiKit _apiKit = getIt<ApiKit>();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildChartTab(Future<WeekChartModel> Function() chartFetcher) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: defaultFutureBuilder<WeekChartModel>(
        future: chartFetcher(),
        onData: (context, chart) {
          final chartSongs = chart.chartSongs;
          return GeneratableListView(
            initialPageIdx: 0,
            loadDelay: Duration(milliseconds: 800),
            asyncGenFunction: (int page) async {
              const int len = 8;
              return chartSongs
                  .sublist(
                    min(len * page, chartSongs.length),
                    min(len * (page + 1), chartSongs.length),
                  )
                  .map(
                    (e) => Row(
                      children: [
                        SizedBox(width: 12),
                        Expanded(
                          child: SongCard(
                            variation: 2,
                            chartSong: e,
                            songList: chart.songs,
                          ),
                        ),
                        PlayOrPauseButton(song: e.song, songList: chart.songs),
                        SizedBox(width: 12),
                      ],
                    ),
                  )
                  .toList();
            },
            separatorBuilder: (context, index) => SizedBox(height: 16),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'V-Pop'),
            Tab(text: 'US-UK'),
            Tab(text: 'K-Pop'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChartTab(() => _apiKit.getVpopWeekChart()),
              _buildChartTab(() => _apiKit.getUsukWeekChart()),
              _buildChartTab(() => _apiKit.getKpopWeekChart()),
            ],
          ),
        ),
      ],
    );
  }
}
