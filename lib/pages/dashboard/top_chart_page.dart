import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/components/musics/song_card.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/components/song/song_bottom_sheet.dart';
import 'package:memecloud/components/miscs/page_with_tabs/single.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/generatable_list/list_view.dart';

Map getTopChartPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(context, title: 'Top Charts'),
    'bgColor': MyColorSet.indigo,
    'body': const TopChartPage(),
  };
}

class TopChartPage extends StatelessWidget {
  const TopChartPage({super.key});

  Widget _buildChartTab(Future<WeekChartModel> Function() chartFetcher) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: defaultFutureBuilder<WeekChartModel>(
        future: chartFetcher(),
        onData: (context, chart) {
          final chartSongs = chart.chartSongs;
          return GeneratableListView(
            initialPageIdx: 0,
            loadDelay: const Duration(milliseconds: 300),
            asyncGenFunction: (int page) async {
              const int len = 8;
              return chartSongs
                  .sublist(
                    min(len * page, chartSongs.length),
                    min(len * (page + 1), chartSongs.length),
                  )
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onLongPress:
                            () => showSongBottomSheet(context, e.song),
                        child: SongCard(
                          variant: 2,
                          chartSong: e,
                          songList: chart.songs,
                        ),
                      ),
                    ),
                  )
                  .toList();
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWithSingleTab(
      variant: 2,
      tabNames: const ['V-Pop', 'US-UK', 'K-Pop'],
      widgetBuilder: (tabsNavigator, tabContent) {
        return Column(children: [tabsNavigator, Expanded(child: tabContent)]);
      },
      tabBodies: [
        _buildChartTab(() => getIt<ApiKit>().getVpopWeekChart()),
        _buildChartTab(() => getIt<ApiKit>().getUsukWeekChart()),
        _buildChartTab(() => getIt<ApiKit>().getKpopWeekChart()),
      ],
    );
  }
}
